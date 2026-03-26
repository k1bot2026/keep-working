# Keep Working — Resume Session

Resume a previous Keep Working session from saved state.

## Prerequisites

- `.keep-working/config.json` must exist in the project root
- `.keep-working/BACKLOG.md` must exist with remaining tasks

## Procedure

### 1. Load State

Read these files:
- `.keep-working/config.json` — session configuration (roles, model, focus, cycles)
- `.keep-working/BACKLOG.md` — remaining tasks
- `.keep-working/SESSION-LOG.md` — what was already done
- `.keep-working/STATE.md` — decisions and context

### 2. Validate State

Verify:
- `config.json` has valid `version`, `team_name`, `roles`
- `BACKLOG.md` has unchecked tasks remaining
- If no tasks remain: run project analysis to generate new ones (same as fresh start Phase 2)

### 3. Update State Files

- Edit `.keep-working/PROGRESS.md` — Set Status to "Active (resumed)"
- Edit `.keep-working/SESSION-LOG.md` — Add new section:
  ```markdown
  ---
  ## Resumed Session — [TIMESTAMP]
  Previous cycles: [N]
  Remaining tasks from previous session: [count]
  ```
- Update `config.json` — reset `started` to current timestamp (keep `cycles_completed`)

### 4. Recreate Team

```
TeamCreate: team_name = "<team_name from config>"
```

### 5. Spawn Agents

Use the same roles from `config.json`. Spawn with same parameters:

```
Task:
  subagent_type: "general-purpose"
  team_name: "<team_name>"
  name: "<role from config>"
  mode: "dontAsk"
  model: "<model from config>"
```

Use the teammate prompt template from `@templates/teammate-prompt.md`, filled with project details from config.

### 6. Send Resume Instructions

Send each agent a message:
```
SendMessage type="message", recipient="<agent-name>"
content="Resuming session. There are pending tasks in .keep-working/BACKLOG.md.
Pick up where the previous session left off. Read the backlog and start
with the highest priority unchecked tasks assigned to your role."
summary="Session resumed, check backlog"
```

### 7. Clean Up Token State & Restart Guard

If `.keep-working/.token-state.json` exists:
- Read it to note the pause reason (log in SESSION-LOG.md)
- Delete the file: `rm .keep-working/.token-state.json`

If `token_guard.enabled` in config:
- Kill any existing guard: read `.guard.pid`, `kill` if alive
- Start a fresh guard:
  ```bash
  nohup bash ~/.claude/keep-working/bin/token-guard.sh "<project-path>" > /dev/null 2>&1 &
  ```
- Update `guard_pid` in config.json

### 8. Continue Normal Loop

From here, follow the standard lead behavior from `@references/lead-protocol.md`.
The infinite cycle continues as normal.

## If No State Exists

If `.keep-working/config.json` does not exist, inform the user:
"No previous session found. Use `/keep-working` to start a new session."
