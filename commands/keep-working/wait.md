# Keep Working — Wait for Token Reset

Manually trigger a save-and-wait when you know the token limit is approaching. The Token Guard will automatically resume the session when the window resets.

Use this when you notice your tokens are running low and want to gracefully pause rather than letting the session die mid-task.

## Usage
```
/keep-working:wait
```

## Procedure

### 1. Broadcast Save Signal

```
SendMessage type="broadcast"
content="Token limit approaching. Finish your current task, commit, and report. Session will auto-resume after token reset."
summary="Saving state for token wait"
```

### 2. Wait for Agents to Report

Give agents a moment to finish their current task and send their report.

### 3. Save Full State

Execute the reschedule protocol:
- Update `.keep-working/config.json` with latest cycle count and task counts
- Ensure `.keep-working/BACKLOG.md` is up to date
- Write session summary to `.keep-working/SESSION-LOG.md`

### 4. Write Token State

Read the `token_guard.window_hours` from `.keep-working/config.json` (default: 5).

Calculate resume time: now + window_hours.

Write `.keep-working/.token-state.json`:
```json
{
  "status": "waiting",
  "paused_at": "[ISO timestamp]",
  "resume_at": "[ISO timestamp]",
  "reason": "manual_wait",
  "window_hours": 5,
  "guard_pid": [PID from .guard.pid]
}
```

### 5. Ensure Guard is Running

Check `.keep-working/.guard.pid`:
- If PID exists and process is alive → guard is running, it will pick up the token-state file
- If PID missing or process dead → spawn a new guard:
  ```bash
  nohup bash ~/.claude/keep-working/bin/token-guard.sh "<project-path>" > /dev/null 2>&1 &
  ```

### 6. Update Progress

Edit `.keep-working/PROGRESS.md`:
- Set Status to "Waiting for token reset"
- Add estimated resume time

### 7. Confirm to User

Tell the user:
```
State saved. Token Guard is active.
Estimated resume: [TIME] (in ~[N] hours)
Auto-resume: [enabled/disabled]

You can safely close this session. The guard will:
1. Wait until the token window resets
2. Send a notification
3. Start a new Claude session with /keep-working:resume

To check status: cat .keep-working/.token-state.json
To cancel wait: touch .keep-working/.guard-stop
```

### 8. Shutdown Team (graceful)

```
SendMessage type="shutdown_request" to each teammate
TeamDelete
```

The guard process continues running independently after the Claude session ends.
