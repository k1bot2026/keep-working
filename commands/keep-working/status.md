# Keep Working — Status Check

Check the progress of the current Keep Working session without interrupting the work loop.

This is a **read-only** operation. It does NOT stop or interfere with running agents.

## What To Do

1. Read `.keep-working/PROGRESS.md` and present its contents to the user
2. Read `.keep-working/BACKLOG.md` and count:
   - Tasks completed (checked items)
   - Tasks remaining (unchecked items)
   - Tasks per priority level
3. Read `.keep-working/config.json` for session info (start time, roles, focus)
4. If `.keep-working/PENDING-QUESTIONS.md` exists, count parked questions
5. Run `git log --oneline --since="<start time>" 2>/dev/null` to count commits

## Present to User

```
Keep Working Status
━━━━━━━━━━━━━━━━━━
Status:    Active
Started:   [time]
Duration:  [elapsed]
Focus:     [area or "none"]

Agents:    [role1], [role2], [role3]
Cycles:    [N] completed
Tasks:     [done] completed / [remaining] remaining
Commits:   [N] this session
Questions: [N] parked

Top remaining tasks:
1. [highest priority task]
2. [next task]
3. [next task]
```

### LocalAI (conditional)

If `local` exists in config.json and `local.mode` is not "off", append to the status output:

```
LocalAI:   [mode] — [local_completions] local / [paid_completions] paid / [savings]% saved
```

## Important

- Do NOT call TeamDelete, shutdown, or any action that modifies the team
- Do NOT edit any files in .keep-working/
- This command is purely informational
- The work loop continues unaffected
