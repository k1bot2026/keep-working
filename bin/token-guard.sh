#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Keep Working — Token Guard
#
# Background watchdog that detects token exhaustion and
# auto-resumes the session after the token window resets.
#
# This script uses ZERO Claude API tokens. It runs as a pure
# bash process monitoring file timestamps.
#
# Usage: token-guard.sh <project-path> [window-hours]
# ─────────────────────────────────────────────────────────────

set -euo pipefail

PROJECT_PATH="${1:?Usage: token-guard.sh <project-path> [window-hours]}"
STATE_DIR="$PROJECT_PATH/.keep-working"
CONFIG_FILE="$STATE_DIR/config.json"
PROGRESS_FILE="$STATE_DIR/PROGRESS.md"
TOKEN_STATE_FILE="$STATE_DIR/.token-state.json"
GUARD_PID_FILE="$STATE_DIR/.guard.pid"
GUARD_STOP_FILE="$STATE_DIR/.guard-stop"

# ── Defaults (overridden by config.json if present) ──────────
WINDOW_HOURS="${2:-5}"
INACTIVITY_THRESHOLD=300  # seconds (5 minutes)
AUTO_RESUME=true
NOTIFY=true

# ── Read config if available ─────────────────────────────────
read_config() {
  if [ -f "$CONFIG_FILE" ] && command -v python3 &>/dev/null; then
    WINDOW_HOURS=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    tg = c.get('token_guard', {})
    print(tg.get('window_hours', $WINDOW_HOURS))
except: print($WINDOW_HOURS)
" 2>/dev/null)

    INACTIVITY_THRESHOLD=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    tg = c.get('token_guard', {})
    print(int(tg.get('inactivity_threshold_minutes', 5)) * 60)
except: print($INACTIVITY_THRESHOLD)
" 2>/dev/null)

    AUTO_RESUME=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    tg = c.get('token_guard', {})
    print('true' if tg.get('auto_resume', True) else 'false')
except: print('true')
" 2>/dev/null)

    NOTIFY=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    tg = c.get('token_guard', {})
    print('true' if tg.get('notify', True) else 'false')
except: print('true')
" 2>/dev/null)
  fi
}

# ── Notification helpers ─────────────────────────────────────
notify() {
  local title="$1"
  local message="$2"
  local sound="${3:-Glass}"

  [ "$NOTIFY" != "true" ] && return 0

  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null || true
  elif command -v notify-send &>/dev/null; then
    notify-send "$title" "$message" 2>/dev/null || true
  fi

  # Always log to file as fallback
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $title: $message" >> "$STATE_DIR/.guard.log"
}

# ── File modification time (cross-platform) ──────────────────
file_mtime() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat -f %m "$1" 2>/dev/null || echo 0
  else
    stat -c %Y "$1" 2>/dev/null || echo 0
  fi
}

# ── Calculate resume time ────────────────────────────────────
calc_resume_time() {
  local now
  now=$(date +%s)
  local window_seconds=$((WINDOW_HOURS * 3600))
  echo $((now + window_seconds))
}

# ── Format time for display ──────────────────────────────────
format_time() {
  local epoch="$1"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    date -r "$epoch" "+%H:%M" 2>/dev/null || echo "unknown"
  else
    date -d "@$epoch" "+%H:%M" 2>/dev/null || echo "unknown"
  fi
}

format_iso() {
  local epoch="$1"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    date -u -r "$epoch" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo ""
  else
    date -u -d "@$epoch" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo ""
  fi
}

# ── Write token state file ───────────────────────────────────
write_token_state() {
  local status="$1"
  local paused_at="$2"
  local resume_at="$3"

  cat > "$TOKEN_STATE_FILE" << JSONEOF
{
  "status": "$status",
  "paused_at": "$(format_iso "$paused_at")",
  "resume_at": "$(format_iso "$resume_at")",
  "reason": "token_exhaustion",
  "window_hours": $WINDOW_HOURS,
  "guard_pid": $$
}
JSONEOF
}

# ── Cleanup on exit ──────────────────────────────────────────
cleanup() {
  rm -f "$GUARD_PID_FILE" "$GUARD_STOP_FILE"
}
trap cleanup EXIT

# ── Main ─────────────────────────────────────────────────────

# Prevent duplicate guards
if [ -f "$GUARD_PID_FILE" ]; then
  existing_pid=$(cat "$GUARD_PID_FILE" 2>/dev/null)
  if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null; then
    echo "Guard already running (PID $existing_pid). Exiting."
    exit 0
  fi
fi

# Write our PID
echo $$ > "$GUARD_PID_FILE"

# Read configuration
read_config

echo "Token Guard started (PID $$)"
echo "  Project: $PROJECT_PATH"
echo "  Window: ${WINDOW_HOURS}h"
echo "  Inactivity threshold: $((INACTIVITY_THRESHOLD / 60))m"
echo "  Auto-resume: $AUTO_RESUME"
echo "  Notifications: $NOTIFY"

# ── Monitor loop ─────────────────────────────────────────────
while true; do
  sleep 60

  # Exit conditions
  [ ! -d "$STATE_DIR" ] && exit 0
  [ -f "$GUARD_STOP_FILE" ] && exit 0

  # Skip if already in wait mode (managed externally via /keep-working:wait)
  if [ -f "$TOKEN_STATE_FILE" ]; then
    status=$(python3 -c "import json; print(json.load(open('$TOKEN_STATE_FILE')).get('status',''))" 2>/dev/null || echo "")
    if [ "$status" = "waiting" ]; then
      # Read resume_at and sleep until then
      resume_epoch=$(python3 -c "
import json, datetime
ts = json.load(open('$TOKEN_STATE_FILE')).get('resume_at','')
if ts:
    dt = datetime.datetime.fromisoformat(ts.replace('Z','+00:00'))
    print(int(dt.timestamp()))
else:
    print(0)
" 2>/dev/null || echo 0)

      if [ "$resume_epoch" -gt 0 ]; then
        now=$(date +%s)
        wait_secs=$((resume_epoch - now))
        if [ "$wait_secs" -gt 0 ]; then
          sleep "$wait_secs"
        fi
        # Fall through to resume logic below
        break
      fi
    fi
  fi

  # Check activity
  if [ -f "$PROGRESS_FILE" ]; then
    last_mod=$(file_mtime "$PROGRESS_FILE")
    now=$(date +%s)
    inactive=$((now - last_mod))

    if [ "$inactive" -gt "$INACTIVITY_THRESHOLD" ]; then
      # ── Token exhaustion detected ────────────────────────
      resume_at=$(calc_resume_time)
      resume_time=$(format_time "$resume_at")

      write_token_state "waiting" "$now" "$resume_at"

      notify "Keep Working — Paused" \
             "Tokens likely exhausted. Will resume at $resume_time" \
             "Glass"

      echo "[$(date '+%H:%M:%S')] Inactivity detected (${inactive}s). Waiting until $resume_time..."

      # Sleep until reset
      wait_secs=$((resume_at - now))
      if [ "$wait_secs" -gt 0 ]; then
        sleep "$wait_secs"
      fi

      break  # Exit loop to resume
    fi
  fi
done

# ── Resume phase ───────────────────────────────────────────
echo "[$(date '+%H:%M:%S')] Token window should be reset. Initiating resume..."

write_token_state "resuming" "$(date +%s)" "$(date +%s)"

notify "Keep Working — Resuming!" \
       "Token window reset. Starting new session..." \
       "Hero"

if [ "$AUTO_RESUME" = "true" ]; then
  # Find claude CLI
  CLAUDE_BIN=$(which claude 2>/dev/null || echo "")
  if [ -z "$CLAUDE_BIN" ]; then
    # Common locations
    for p in /usr/local/bin/claude "$HOME/.claude/bin/claude" "$HOME/.local/bin/claude"; do
      [ -x "$p" ] && CLAUDE_BIN="$p" && break
    done
  fi

  if [ -n "$CLAUDE_BIN" ]; then
    echo "Auto-resuming with: $CLAUDE_BIN"
    cd "$PROJECT_PATH"

    # Start new Claude session with resume command
    # Use -p for non-interactive print mode
    "$CLAUDE_BIN" -p "/keep-working:resume" --max-turns 200 2>>"$STATE_DIR/.guard.log" &

    notify "Keep Working — Active" \
           "Auto-resume started. Agents are back at work." \
           "Purr"
  else
    notify "Keep Working — Manual Resume Needed" \
           "Could not find claude CLI. Run /keep-working:resume manually." \
           "Basso"
    echo "ERROR: claude CLI not found. Please resume manually."
  fi
else
  notify "Keep Working — Ready to Resume" \
         "Token window reset. Run /keep-working:resume to continue." \
         "Hero"
  echo "Auto-resume disabled. Run /keep-working:resume to continue."
fi

echo "Token Guard exiting."
