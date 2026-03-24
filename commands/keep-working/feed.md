# Keep Working — Feed Information

Share new information, data, sources, requirements, or links with the running team without interrupting their workflow.

Use this when you discover something mid-session that the team should know about — a new API endpoint, updated requirements, a reference design, documentation link, or any context that would improve their work.

## Usage
```
/keep-working:feed <information>
```

## Arguments
$ARGUMENTS

## Procedure

### 1. Validate Session

Check that `.keep-working/STATE.md` exists.
- If not: "No active Keep Working session. Use `/keep-working` to start one."

### 2. Classify the Information

Determine the type from the content:
- **Requirement change** — New or modified requirements ("the API should return XML not JSON")
- **Reference material** — Links, docs, examples ("here's the design spec: [url]")
- **Data/context** — Facts, credentials, config values ("the staging server is at...")
- **Correction** — Fix a misunderstanding ("the auth uses OAuth2 not API keys")
- **Priority shift** — Something became more/less urgent ("the deadline moved up")

### 3. Log to STATE.md

Append to `.keep-working/STATE.md` under the `## Context` section:

```markdown
### [TIMESTAMP] — User Feed: [type]
**Info:** [the full information provided by the user]
**Impact:** [which roles/tasks this affects — assessed by lead]
**Action:** [what the lead will do with this — notify specific agent, update backlog, etc.]
```

### 4. Determine Who Needs This

Based on the information type, decide which agents need to know:
- Affects code implementation → notify developer agent
- Affects tests → notify tester agent
- Affects UI/design → notify designer agent
- Affects documentation → notify docs-writer agent
- Affects content → notify content-writer agent
- Affects visuals/assets → notify creative agent
- Affects everyone → broadcast to all

### 5. Notify Relevant Agent(s)

Send a targeted message to the affected agent(s):

```
SendMessage type="message", recipient="<agent-name>"
content="NEW INFO FROM USER: [the information]

This affects your current work. Please take this into account:
- [specific guidance on how this changes their tasks]
- If you're mid-task: finish current task, then apply this to remaining work
- If this contradicts a previous task: prioritize the new information"
summary="New info from user: [short description]"
```

Only use broadcast if the information genuinely affects all agents.

### 6. Update Backlog If Needed

If the information implies new tasks or invalidates existing ones:
- Add new tasks to `.keep-working/BACKLOG.md`
- Mark obsolete tasks with `[SUPERSEDED]` (don't delete them)

### 7. Confirm to User

Tell the user:
"Information shared with [agent name(s)]. Logged to STATE.md. [Brief note on impact]."

## Important

- This command does NOT stop the work loop
- Agents continue working — they receive the info as a message
- The lead processes the feed and returns to normal cycle handling
- Multiple feeds can be sent in succession
