# Keep Working — Autonomous Agent Team

Start an autonomous AI agent team that continuously works on the current project. Agents analyze the project, pick up tasks, execute them, and automatically receive new tasks. The cycle repeats until you say "stop".

## Activation
$ARGUMENTS

Options:
- `focus:<area>` — Prioritize a specific area (frontend, backend, api, tests, docs, refactor, performance, security, ui, content, creative)
- `reschedule:on` — Save state for session continuity

---

## HOW IT WORKS

```
You: "/keep-working"
  → Lead analyzes project, selects 3 agent roles
  → Creates .keep-working/ with backlog (15+ tasks)
  → Spawns 3 agents via TeamCreate
  → Agents work in parallel on backlog tasks
  → Agent done → sends message → Lead generates new tasks → sends agent back
  → Cycle repeats infinitely
  → You: "/keep-working:stop" → Summary → Team cleanup
```

---

## FORBIDDEN ACTIONS (while keep-working is active)

| Forbidden | Why |
|-----------|-----|
| `TeamDelete` | Kills the team permanently |
| `SendMessage type="shutdown_request"` | Shuts down agents |
| Ask the user questions | Turn ends, loop dies |
| "Want to continue?", "Test it!", "What do you think?" | Implies waiting → loop dies |
| Conclude the work is "done" | A project is NEVER done |
| Present a summary as final result | Only at /keep-working:stop |
| Output text without a follow-up tool call | Turn ends → loop dies |

**What you DO:** Read state → Find gaps → Write 5+ tasks → Send agent back to work.

---

## EXECUTION

### Phase 1: Resume Check

Check if `.keep-working/config.json` exists in the project root.
- If YES → use `/keep-working:resume` flow instead (read config, recreate team, continue)
- If NO → proceed with fresh start below

### Phase 2: Project Analysis

1. Read CLAUDE.md or README for project context
2. Scan directory structure with `Glob` and `ls`
3. Read existing TODOs, issues, or backlog files if they exist
4. Identify the project type and tech stack
5. Load role mapping from `@references/project-profiles.md`
6. Select the 3 most appropriate agent roles for this project
7. If `focus:<area>` is specified, weight role selection toward that area

### Phase 3: Initialize State Directory

Create `.keep-working/` in the project root with these files:

1. **`.keep-working/config.json`** — Session configuration:
   ```json
   {
     "version": 1,
     "team_name": "<project>-team",
     "project_path": "<absolute path>",
     "tech_stack": "<detected stack>",
     "roles": {
       "count": 3,
       "assignments": ["<role1>", "<role2>", "<role3>"]
     },
     "model": { "default": "sonnet", "lead": "inherit" },
     "workflow": {
       "commit_per_task": true,
       "quality_gates": true,
       "min_tasks_per_cycle": 5,
       "reschedule_interval": 3
     },
     "focus": "<area or null>",
     "cycles_completed": 0,
     "tasks_completed": 0,
     "started": "<ISO timestamp>"
   }
   ```

2. **`.keep-working/BACKLOG.md`** — Use template from `@templates/backlog.md`. Fill with **at least 5 tasks per agent** (15+ total). Use `@references/task-patterns.md` for inspiration. Analyze the project thoroughly:
   - What exists? What's missing? What's broken?
   - What can be improved? What tests are missing?
   - What documentation is incomplete?
   - What code needs refactoring?

3. **`.keep-working/PROGRESS.md`** — Use template from `@templates/progress.md`
4. **`.keep-working/SESSION-LOG.md`** — Use template from `@templates/session-log.md`
5. **`.keep-working/STATE.md`** — Use template from `@templates/state.md`

### Phase 4: Spawn Team

```
TeamCreate: team_name = "<project>-team"
```

Spawn 3 teammates via `Task` tool. **Use these exact parameters:**

```
Task:
  subagent_type: "general-purpose"
  team_name: "<team-name>"
  name: "<role-name>"
  mode: "dontAsk"
  model: "sonnet"
```

For each agent's prompt, use the template from `@templates/teammate-prompt.md` and fill in:
- Role name and team name
- Absolute project path
- Detected tech stack
- Reference to the agent's definition file in `@agents/kw-<role>.md`
- Lead name (your team identity)
- Quality gate commands for this tech stack (from `@references/quality-gates.md`)

### Phase 5: Lead Behavior (the infinite loop)

Load the full orchestrator protocol from `@references/lead-protocol.md` and follow it exactly.

**Summary of lead behavior:**

**On "TASK DONE" message from agent:**
1. Edit `.keep-working/BACKLOG.md` — check off the completed task
2. Edit `.keep-working/SESSION-LOG.md` — log what was done
3. Done. Wait for next message.

**On "CYCLE DONE" message from agent:**
1. Read `.keep-working/BACKLOG.md` + 2-3 relevant project files
2. Grep/Glob for gaps (TODOs, FIXMEs, missing tests, etc.)
3. Edit `.keep-working/BACKLOG.md` — add 5+ new concrete tasks for this agent
4. Edit `.keep-working/PROGRESS.md` — increment cycle counter, update activity
5. SendMessage to agent: "New tasks in backlog: [list]. Pick them up."
6. Edit `.keep-working/SESSION-LOG.md` — log cycle completion
7. If `reschedule:on` and cycles % 3 == 0: update config.json with latest state
8. If focus mode: ensure 60%+ of new tasks are in the focus area

**DO NOTHING ELSE.** No summary, no questions, no cleanup.

### Phase 6: Error Recovery

Load error recovery procedures from `@references/error-recovery.md`.

**Quick reference:**
1. Agent silent (idle without message)? → Send check message
2. Still silent after next idle? → Redistribute tasks to other agents
3. All agents down? → Respawn with same config

---

## REFERENCE FILES

These files are loaded by the lead during execution:
- `@references/lead-protocol.md` — Complete orchestrator behavior
- `@references/task-patterns.md` — Task generation inspiration per role
- `@references/quality-gates.md` — Tech-stack verification commands
- `@references/error-recovery.md` — Failure mode handling
- `@references/project-profiles.md` — Project type detection and role mapping

---

## QUICK REFERENCE

```
START:
1. Check resume → Analyze project → Select 3 roles
2. Create .keep-working/ with backlog (15+ tasks)
3. TeamCreate → Spawn 3 agents (mode:dontAsk, model:sonnet)

ON "TASK DONE":
1. Check off in backlog → Log → Done

ON "CYCLE DONE":
1. Read backlog + project files
2. Grep/Glob for gaps
3. Edit backlog: 5+ new concrete tasks
4. Update progress file
5. SendMessage: "new tasks, get to work"
6. Log in session-log
7. (every 3 cycles) Save state if reschedule:on

ERROR RECOVERY:
1. Agent silent? → Send check message
2. Still silent? → Redistribute tasks
3. All down? → Respawn

NEVER: TeamDelete, shutdown, questions, "it's done"
STOP ONLY: User says "stop" or /keep-working:stop
```
