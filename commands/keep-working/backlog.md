# Keep Working — View Backlog

Display the current task backlog, schedule, and agent assignments without interrupting the work loop.

This is a **read-only** view. It does NOT stop or interfere with running agents.

## Usage
```
/keep-working:backlog
```

## Procedure

### 1. Validate Session

Check that `.keep-working/BACKLOG.md` exists.
- If not: "No active Keep Working session. Use `/keep-working` to start one."

### 2. Read and Parse Backlog

Read `.keep-working/BACKLOG.md` and compute:
- **Pending tasks** — unchecked `[ ]` items, grouped by priority
- **Completed tasks** — checked `[x]` items, count only (don't list all)
- **Per-role breakdown** — how many pending tasks per agent role
- **Priority distribution** — count per priority level (Critical/High/Medium/Low)

### 3. Read Agent Status

Read `.keep-working/PROGRESS.md` for:
- Which agents are active
- What each agent is currently working on (if tracked)
- Last activity timestamp

### 4. Present to User

Format the output as a clear dashboard:

```
Keep Working — Backlog
━━━━━━━━━━━━━━━━━━━━━━

Completed: [N] tasks
Pending:   [N] tasks

Priority Breakdown:
  🔴 Critical:  [N]
  🟠 High:      [N]
  🟡 Medium:    [N]
  🟢 Low:       [N]

Per Agent:
  developer:      [N] pending
  tester:         [N] pending
  designer:       [N] pending

━━━━━━━━━━━━━━━━━━━━━━

🔴 Critical
  • [task description] — developer
  • [task description] — tester

🟠 High
  • [task description] — developer
  • [task description] — designer

🟡 Medium
  • [task description] — tester
  • [task description] — docs-writer

🟢 Low
  • [task description] — developer
  • [task description] — designer

━━━━━━━━━━━━━━━━━━━━━━
Tip: /keep-working:add-task to add new tasks
     /keep-working:feed to share info with team
     /keep-working:suggest to guide approach
```

### 5. Done

Return to normal operation. The work loop continues unaffected.

## Important

- This is purely informational — read-only
- Do NOT call TeamDelete, shutdown, or modify team state
- Do NOT edit any files in `.keep-working/`
- The work loop continues unaffected
- For a broader status overview (cycles, duration, commits), use `/keep-working:status`
