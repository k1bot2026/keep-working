# Stop Keep Working

Gracefully stop the autonomous agent team and generate a session summary.

## Procedure

### 1. Broadcast Stop Signal

```
SendMessage type="broadcast"
content="Stop — finish your current task, commit your work, and go idle."
summary="Session stopping"
```

### 2. Wait for Agents to Idle

Wait for idle notifications from all teammates. They will finish their current task, commit, and stop.

### 3. Collect Results

Read these files to compile the summary:
- `.keep-working/BACKLOG.md` — completed and remaining tasks
- `.keep-working/SESSION-LOG.md` — cycle history
- `.keep-working/PROGRESS.md` — cycle counter and stats
- `.keep-working/PENDING-QUESTIONS.md` — parked decisions (if exists)
- `.keep-working/config.json` — session configuration

Also run:
```bash
git log --oneline --since="<session start time>" 2>/dev/null
```

### 4. Write Session Summary

Append to `.keep-working/SESSION-LOG.md`:

```markdown
---

## Session Summary — [DATE]
**Status:** Completed
**Duration:** [start] → [end]
**Cycles completed:** [N]
**Total tasks completed:** [count from backlog]

### Per Agent
- **[Agent 1 — role]:** [list of completed work]
- **[Agent 2 — role]:** [list of completed work]
- **[Agent 3 — role]:** [list of completed work]

### Git Commits This Session
[output of git log --oneline]

### Remaining Backlog
[count] tasks remaining. Top 3 priorities:
1. [task]
2. [task]
3. [task]

### Recommended Next Steps
1. [step]
2. [step]
3. [step]
```

### 5. Update Progress File

Edit `.keep-working/PROGRESS.md`:
- Set Status to "Stopped"
- Update final stats

### 6. Present Summary to User

Show the user:
- Cycles completed and total tasks done
- What each agent accomplished
- Git commits made
- Remaining backlog count
- Top recommended next steps

### 7. Show Pending Questions

If `.keep-working/PENDING-QUESTIONS.md` exists and is not empty, present it to the user so they can review decisions that agents made autonomously.

### 8. Ask About State Preservation

If `.keep-working/config.json` exists, ask the user:
- **Keep state** — for resuming later with `/keep-working:resume`
- **Clean up** — remove `.keep-working/` directory

### 9. Shutdown Teammates

```
SendMessage type="shutdown_request" to each teammate (by name)
```

### 10. Delete Team

```
TeamDelete
```
