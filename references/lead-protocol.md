# Lead Orchestrator Protocol

This document defines the complete behavior of the lead orchestrator (main session) during the Keep Working infinite work loop. The lead reads this document at session start and references it whenever handling agent messages or deciding next actions.

---

## Forbidden Actions

The lead orchestrator must never perform the following actions. These restrictions exist to prevent file corruption, task duplication, and state inconsistency across concurrent agents.

| Forbidden Action | Reason |
|---|---|
| Editing files in `src/`, `lib/`, `app/`, or any source code directory | Lead is an orchestrator only; source code changes are delegated to agents |
| Running `git commit` or `git push` | Commit strategy is the agent's responsibility; lead committing risks conflicts |
| Running tests directly | Tests are run by agents as part of quality gates after their own changes |
| Installing packages (`npm install`, `pip install`, `cargo add`, etc.) | Dependency changes must go through the backlog so all agents are aware |
| Editing `session-log.md` except during TASK DONE or CYCLE DONE handling | Prevents concurrent write conflicts with agent log writes |
| Editing `backlog.md` while an agent is actively working on a task | Always wait for TASK DONE before modifying the backlog |
| Spawning more than one agent per role simultaneously | Creates file conflicts and duplicated work |
| Deleting files from the project | Destructive operations require explicit human approval |
| Reading or writing `state.json` except during the reschedule protocol | State file is only touched during explicit save/restore procedures |
| Responding to an agent's TASK DONE by spawning a new agent before updating the backlog | Backlog must be updated first so the new agent gets the current state |
| Making assumptions about what an agent completed without reading its message | Always read the full completion message before acting |
| Assigning the same task to two agents | Deduplicate the backlog before every agent spawn |

---

## Session State Files

The lead maintains and reads these files throughout the session:

- `backlog.md` — Master task list. Checkboxes: `[ ]` pending, `[x]` done, `[~]` in-progress (optional)
- `session-log.md` — Append-only log of completed tasks, cycle summaries, and decisions
- `state.json` — Optional. Created during reschedule protocol. Contains full session snapshot for resuming

---

## TASK DONE Handling

When an agent sends a message containing `TASK DONE` (or equivalent completion signal), the lead must perform these steps in order before doing anything else:

### Step 1 — Read the completion message fully

Read the agent's entire message. Note:
- What was actually completed (may differ from what was assigned)
- Any files modified
- Quality gate results (did all checks pass?)
- Any blockers, partial work, or follow-up items the agent flagged
- Any new tasks the agent suggests

### Step 2 — Update backlog.md

Open `backlog.md` and:
1. Find the task that was completed
2. Change `[ ]` to `[x]` — mark it done
3. If the agent flagged follow-up items, add them as new `[ ]` entries at the appropriate priority position
4. Do not change any other entries or reorder tasks beyond inserting new items

### Step 3 — Append to session-log.md

Append one entry in this format:
```
### [ISO timestamp] — TASK DONE
**Agent:** [role] ([agent name if known])
**Task:** [exact task description from backlog]
**Result:** [one sentence summary of what was done]
**Files changed:** [comma-separated list, or "none"]
**Quality gates:** [passed / failed — if failed, describe]
**Follow-up tasks added:** [N tasks added to backlog, or "none"]
```

### Step 4 — Determine next action

- If focus mode is active, check whether the completed task was in the focus area. Log a note if it was not.
- Check whether any pending tasks exist in the backlog. If yes, proceed to spawn the agent again with the next task.
- If the backlog has fewer than 3 pending tasks, trigger a mini CYCLE DONE to generate more before spawning.
- If the backlog is empty, trigger a full CYCLE DONE.

### Step 5 — Continue

Send the agent back to work (see Agent Spawning Specification) or wait if a CYCLE DONE is in progress.

---

## CYCLE DONE Handling

An agent sends `CYCLE DONE` when it has exhausted all tasks in the backlog that are assigned to its role. The lead must perform the full 7-step procedure:

### Step 1 — Read current state

Read these files in full:
1. `backlog.md` — What is done, what is pending, what was recently added
2. `session-log.md` — Recent completed work and decisions
3. Any design handoff or specification documents in the project (e.g., `DESIGN_HANDOFF.md`, `SPEC.md`, `README.md`)

Do not rely on memory. Always re-read these files because agents may have updated them.

### Step 2 — Analyze gaps

Based on what has been completed and the project's current state, identify areas that still need work. Ask:
- What features are implemented but not tested?
- What tests exist but have no documentation?
- What UI components exist but lack error/loading/empty states?
- What API endpoints lack validation or error handling?
- What is technically complete but not polished?
- What would a code reviewer flag as incomplete?
- What is in the project spec that has not been started?

Write this gap analysis as a brief internal note (not logged anywhere, just for the next step).

### Step 3 — Generate 5 or more new tasks

Write at minimum 5 new tasks. Each task must be:
- Assigned to a specific role (Developer, Tester, Designer, Docs Writer, Content Writer, Creative)
- Concrete and actionable (see Task Generation Guidelines below)
- Scoped to one agent-session's worth of work (not too large, not trivial)
- Different from any already-completed tasks
- Prioritized: list most important first

Append these tasks to `backlog.md` as new `[ ]` entries under an appropriate section heading or at the end of the pending list. Do not reformat the entire backlog.

### Step 4 — Update progress in session-log.md

Append a CYCLE DONE entry:
```
### [ISO timestamp] — CYCLE DONE (#[cycle number])
**Completed this cycle:** [N] tasks
**Tasks completed overall:** [total from backlog]
**New tasks generated:** [N] tasks
**Gap analysis summary:** [2–3 sentences on what drove the new tasks]
**Focus area:** [active focus area name, or "none"]
**Next cycle focus:** [same or changed focus area, and why]
```

### Step 5 — Send the agent back to work

Spawn the agent again using the Agent Spawning Specification. Include the agent's role-appropriate task from the newly written backlog.

### Step 6 — Increment cycle counter

Update the cycle counter. See Cycle Counter Management below.

### Step 7 — Optionally save state (reschedule protocol)

If any of these conditions are true, run the Reschedule Protocol:
- The session has been running for more than 90 minutes
- More than 20 cycles have completed
- The human has indicated they may close the session soon
- Total pending tasks exceed 50 (state is too large to hold in context reliably)

---

## Cycle Counter Management

The cycle counter tracks how many full CYCLE DONE procedures have occurred. It is stored in `session-log.md` as part of each CYCLE DONE entry (e.g., `CYCLE DONE (#1)`, `CYCLE DONE (#2)`).

To determine the current cycle number before appending:
1. Read `session-log.md`
2. Search for the most recent `CYCLE DONE (#N)` entry
3. The next cycle number is N+1
4. If no previous CYCLE DONE entries exist, this is cycle #1

The cycle counter is not stored in a separate variable. It is always derived from the log. This prevents desync if the log is the source of truth.

---

## Task Generation Guidelines

Good tasks are concrete, testable, and scoped. Bad tasks are vague, too large, or already covered.

### GOOD task examples

- `Write unit tests for the validateEmail() function in src/utils/validation.ts — test empty string, malformed, valid, and Unicode inputs`
- `Add error state UI to the LoginForm component — show inline message below the password field on 401 response`
- `Refactor the getUserById() database call in src/services/user.service.ts to use connection pooling`
- `Write JSDoc comments for all exported functions in src/api/orders.ts`
- `Add a 404 page to the WordPress theme with a search widget and links to the 5 most recent posts`

### BAD task examples

| Bad task | Problem | Fix |
|---|---|---|
| "Improve the code" | Not actionable, no target | Name the file and the specific improvement |
| "Write tests" | Too vague, no scope | Name the module and what to test |
| "Fix bugs" | No specific bug named | Link to a specific error or describe the failure |
| "Update the UI" | No component named, no change described | Name the component and the exact visual change |
| "Refactor everything" | Too large for one session | Break into 3–5 specific refactoring tasks |
| "Make it faster" | No measurement, no target | Name the operation and a target latency/metric |
| "Add documentation" | Unscoped | Name the file or module and the documentation type |

### Task sizing

- **Too small** (< 5 minutes): trivial rename, add one variable — combine with a related task
- **Right size** (15–60 minutes): one function, one component, one test file, one doc section
- **Too large** (> 2 hours): full feature, entire module rewrite — split into subtasks

---

## Reschedule Protocol

The reschedule protocol saves full session state to `state.json` so the session can be resumed later without loss of context. Run this during CYCLE DONE step 7 when triggered.

### When to run

- Session running > 90 minutes
- > 20 cycles completed
- Pending tasks > 50
- Human signals upcoming session end
- Token budget is approaching exhaustion (lead notices context is getting large)

### Procedure

1. Read `backlog.md` in full
2. Read the last 10 entries in `session-log.md`
3. Identify the current cycle number from the log
4. Write `state.json` with this structure:

```json
{
  "saved_at": "[ISO timestamp]",
  "cycle_number": [N],
  "session_summary": "[2–3 sentence summary of progress so far]",
  "focus_area": "[active focus area or null]",
  "active_agents": [],
  "pending_task_count": [N],
  "completed_task_count": [N],
  "resume_instructions": "[What the lead should do first when resuming: which agent to spawn, which task to assign]",
  "project_snapshot": {
    "tech_stack": "[detected stack]",
    "quality_gates_section": "[which section of quality-gates.md applies]",
    "key_files": ["[list of most important project files for context]"]
  }
}
```

5. Append to `session-log.md`:
```
### [ISO timestamp] — STATE SAVED
**Reason:** [why the reschedule was triggered]
**Resume from:** [cycle number, pending task count, next suggested action]
```

6. Inform the human that state has been saved and the session can be safely closed and resumed.

### Resuming from state.json

On session resume:
1. Read `state.json` — get context on where the session left off
2. Read `backlog.md` — get the current task list
3. Read last 20 lines of `session-log.md` — get recent history
4. Follow the `resume_instructions` in `state.json`
5. Do not re-run CYCLE DONE unless the backlog is empty; just spawn the agent and continue

---

## Focus Mode Rules

Focus mode is active when the human has specified a focus area (e.g., "focus on testing", "focus on the checkout flow", "focus on documentation").

When focus mode is active:

1. **At minimum 60% of all new tasks generated must be in the focus area.** If generating 5 tasks, at least 3 must relate directly to the focus area.
2. **Agent spawning priority**: always assign a focus-area task to the agent if one exists in the backlog.
3. **CYCLE DONE gap analysis**: lead must first ask "what is still missing in the focus area?" before considering other gaps.
4. **Focus mode is not exclusive**: the other 40% of tasks may address critical bugs, blockers, or urgent work outside the focus area.
5. **Changing focus**: the human can change the focus area at any time by sending a message. The lead acknowledges the change, notes it in `session-log.md`, and applies it from the next CYCLE DONE onward.
6. **No focus mode**: if no focus is set, distribute tasks evenly across Developer, Tester, Designer, and Docs Writer based on project gaps.

---

## Agent Spawning Specification

Use the Task tool with these exact parameters when spawning an agent. All parameters are required.

```
Task(
  subagent_type = "general-coding-agent",
  team_name     = "[project-name]-team",
  name          = "[role]-agent",
  mode          = "dontAsk",
  model         = "claude-opus-4-5",
  description   = "[The exact task from the backlog, verbatim]",
  prompt        = """
You are a [Role] agent working on [project name].

## Your Task
[Exact task description from backlog, copy verbatim]

## Project Context
- Tech stack: [detected stack from project-profiles.md]
- Active theme / entry point: [file path]
- Quality gates: Apply the "[Stack Name]" section from references/quality-gates.md after every change

## How to Work
1. Read the relevant source files before making any changes
2. Make the change
3. Run quality gates (see references/quality-gates.md — [Stack] section)
4. If quality gates fail, fix the failure before reporting done
5. Check `backlog.md` for any other pending [Role] tasks
6. If more tasks remain: pick the next one, work on it, and repeat
7. If backlog has no more [Role] tasks: send "CYCLE DONE" with a summary

## Completion Format
When you finish ALL available tasks, send:
CYCLE DONE
Summary: [what was accomplished]
Files changed: [list]
Quality gates: [all passed / any failures and how resolved]
Suggested new tasks: [optional list]

When you finish a single task and are continuing:
TASK DONE
Task: [task description]
Result: [what was done]
Files: [list]
Quality gates: [passed/failed]
""",
)
```

### Role name mappings

| Role | `name` parameter | Agent behavior focus |
|---|---|---|
| Developer | `developer-agent` | Code implementation, refactoring, performance |
| Tester | `tester-agent` | Test writing, coverage, edge cases |
| Designer | `designer-agent` | UI components, CSS, accessibility, visual states |
| Docs Writer | `docs-agent` | Inline docs, README, API docs, guides |
| Content Writer | `content-agent` | SEO, copy, UX writing, structured content |
| Creative | `creative-agent` | SVG, diagrams, design tokens, visual assets |

### When to spawn which role

- Spawn the role that has the most pending tasks in the backlog for that role category
- In focus mode: always prioritize spawning the agent whose role matches the focus area
- Never spawn two agents with the same `name` simultaneously
- If an agent returns TASK DONE and more tasks exist for their role, spawn them again immediately

---

## Backlog Management Rules

The backlog is the single source of truth for work to be done. These rules prevent corruption.

1. **Only the lead edits `backlog.md`.** Agents never edit the backlog directly; they report completion via SendMessage.
2. **Agents may suggest new tasks** in their completion message. The lead decides whether to add them.
3. **Task format**: every entry must be a Markdown checkbox with a role tag:
   ```
   - [ ] [Developer] Refactor getUserById() to use connection pooling in src/services/user.service.ts
   - [x] [Tester] Write edge case tests for validateEmail() — done 2024-01-15
   ```
4. **No orphan tasks**: every task must have a role tag. No untagged tasks.
5. **No duplicates**: before adding new tasks at CYCLE DONE, search the backlog for similar items already listed.
6. **Priority ordering**: within each section, list most important tasks first. Do not mix priorities randomly.
7. **Completed tasks stay**: do not delete `[x]` tasks. They form the project history. Archive to a `## Completed` section if the file becomes too long (> 100 entries).
8. **In-progress marker**: optionally use `[~]` to mark a task that an agent is actively working on. Revert to `[ ]` if the agent fails or is reassigned.
