# Keep Working — Add Task

Inject a task into the backlog of a running Keep Working session.

## Usage
```
/keep-working:add-task <task description>
```

## Arguments
$ARGUMENTS

## Procedure

### 1. Validate Session

Check that `.keep-working/BACKLOG.md` exists.
- If not: "No active Keep Working session. Use `/keep-working` to start one."

### 2. Parse Task

From `$ARGUMENTS`, extract:
- **Description**: The full task text
- **Priority**: Detect from keywords, default to "Medium"
  - "urgent", "critical", "blocker", "crash", "broken" → Critical
  - "important", "must", "need", "core" → High
  - "nice to have", "polish", "cleanup", "refactor" → Low
  - Everything else → Medium
- **Role**: Detect from task content, default to "developer"
  - Testing/QA keywords → tester
  - UI/CSS/styling/responsive keywords → designer
  - Docs/README/comment keywords → docs-writer
  - Content/SEO/copy keywords → content-writer
  - Asset/diagram/visual keywords → creative
  - Everything else → developer

### 3. Add to Backlog

Edit `.keep-working/BACKLOG.md`:
- Insert the task in the appropriate priority section
- Format: `- [ ] [description] — **Assigned:** [role] — (manually added)`

### 4. Notify Active Agent

If there's an active agent matching the assigned role, send a message:
```
SendMessage type="message", recipient="<agent-name>"
content="New task added to backlog: [description]. Check .keep-working/BACKLOG.md for details."
summary="New task added to backlog"
```

### 5. Confirm to User

Tell the user:
"Task added to backlog as [priority] priority, assigned to [role]."
