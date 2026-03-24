# Error Recovery Procedures

Procedures for handling failure modes in the Keep Working framework. The lead orchestrator consults this document when an agent behaves unexpectedly, a build fails, or the session encounters an error condition.

For each failure mode, the procedure follows the same structure: Detection, Immediate Response, Recovery Steps, and Prevention.

---

## Unresponsive Agent

An agent is unresponsive when it has been spawned, has not sent any message (TASK DONE, CYCLE DONE, or an intermediate update), and an unusually long time has elapsed without output.

### Detection

- **First idle signal**: Lead spawned an agent and has received no message within the expected working window (typically 10–20 minutes for a well-scoped task)
- **Confirm it is not just a slow task**: Read the task description. If the task is large (e.g., "write 20 test cases", "refactor entire module"), a longer wait is expected
- **Second idle signal**: If no message arrives after waiting an additional full work window, treat the agent as unresponsive

A slow task is not an unresponsive agent. Only escalate after two consecutive idle signals with no output at all.

### Immediate Response

1. Do not spawn a replacement yet
2. Re-read the task that was assigned. Verify it was written clearly and actionably
3. Check `session-log.md` to confirm the agent was actually spawned (look for the spawn log entry)
4. Check whether the project has any blocking issues that would prevent progress (syntax errors in key files, missing dependencies)

### Recovery Steps

1. **Check for a message that was missed**: Re-read the agent's conversation thread if accessible. Some completion messages may have been sent but not noticed by the lead
2. **Log the incident**: Append to `session-log.md`:
   ```
   ### [timestamp] — AGENT UNRESPONSIVE
   **Agent:** [role]-agent
   **Assigned task:** [task description]
   **Time elapsed:** [duration since spawn]
   **Action taken:** [redistribute / respawn]
   ```
3. **Mark the task as un-assigned**: In `backlog.md`, if you used `[~]` to mark the task in-progress, revert it to `[ ]`
4. **Redistribute the task**: The task remains in the backlog as `[ ]` and will be picked up by the next agent spawn
5. **Respawn the agent**: If the work is urgent and the backlog has several pending tasks for this role, spawn a fresh agent for the role. The new agent will read the backlog and pick up the redistributed task

### Prevention

- Always write concrete, scoped tasks (see lead-protocol.md Task Generation Guidelines)
- Avoid assigning tasks that depend on external resources or human input without noting the dependency
- Very large tasks should be broken into subtasks before assignment

---

## Agent Crash / Disconnect

An agent crashes or disconnects when it sends a partial message, an error message, or no message at all after beginning work, and subsequently stops responding entirely.

### Detection

- Agent sends a truncated or malformed message (e.g., cut off mid-sentence, ends without TASK DONE or CYCLE DONE)
- Agent sends an error message referencing a framework-level failure (not a code error in the project — those are expected and the agent should fix them)
- Agent's message indicates it lost context (e.g., references tasks it was not assigned, repeats already-completed work)

### Immediate Response

1. Read the last message from the agent fully, noting what was last reported as in-progress
2. Identify what was partially completed and what was not started

### Recovery Steps

1. **Assess partial work**: Check if any files were modified. If the agent made partial changes that left the codebase in a broken state, this must be resolved before spawning a replacement
   - Run the appropriate quality gates from `quality-gates.md` for the project's stack
   - If the build is broken, add a high-priority task to the backlog: `[Developer] Fix broken state left by crashed agent — [describe the break]`
2. **Log the crash**: Append to `session-log.md`:
   ```
   ### [timestamp] — AGENT CRASH
   **Agent:** [role]-agent
   **Last known task:** [task description]
   **Partial work found:** [yes/no — describe if yes]
   **Codebase state:** [broken / clean / unknown]
   **Action taken:** [description]
   ```
3. **Redistribute incomplete tasks**: Find any tasks that were in-progress (`[~]`) for this agent and revert them to `[ ]` in the backlog
4. **Spawn replacement**: Spawn a fresh agent for the same role. The new agent reads the backlog and picks up from where work is needed. Do not reference the crash in the new agent's prompt — just give it the standard working instructions

### Prevention

- Keep task scope reasonable so agents complete work within a single context window
- Do not assign tasks that require the agent to hold large amounts of context simultaneously

---

## File Conflicts

A file conflict occurs when two agents attempt to modify the same file, or an agent modifies a file that the lead also manages (backlog, session-log).

### Prevention (Primary Strategy)

File conflicts are prevented by design:
- Only the lead edits `backlog.md` and `session-log.md`
- Only one agent of each role is active at a time, so two agents cannot be assigned the same file simultaneously
- Agents should be assigned tasks in different modules, components, or files

If the project is structured such that many agents naturally work in the same files, restructure the backlog to serialize conflicting tasks: complete all tasks on File A before assigning any tasks on File B to a different role.

### Detection

- An agent reports that a file it tried to edit had unexpected content (different from what was described in the task)
- `git diff` shows changes in files not related to the assigned task
- Two agents both report editing the same file in the same cycle

### Resolution Steps

1. **Do not panic — this is recoverable with git**
2. Read both agents' messages to understand what each changed in the file
3. Determine which version is correct (or whether both changes are valid and need to be merged)
4. If using git:
   ```
   git diff HEAD [filename]       # See current state vs last commit
   git log --oneline -5 [filename] # See recent history
   git show HEAD:[filename]        # See last committed version
   ```
5. Manually reconcile the file: take the correct or combined version
6. Run quality gates on the reconciled file
7. Log the conflict:
   ```
   ### [timestamp] — FILE CONFLICT RESOLVED
   **File:** [path]
   **Agents involved:** [agent 1], [agent 2]
   **Resolution:** [which change was kept / how they were merged]
   ```
8. Add a task to the backlog to review the reconciled file: `[Tester] Verify [filename] after conflict resolution — check for missing logic`

---

## Git Conflicts

A git conflict occurs when a merge or rebase results in conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) in one or more files.

### Detection

- `git merge` or `git rebase` output contains "CONFLICT" lines
- Files contain conflict markers
- `git status` shows files listed under "both modified"

### Resolution Strategy

1. **Identify all conflicted files**:
   ```
   git diff --name-only --diff-filter=U
   ```

2. **For each conflicted file**, choose a resolution strategy:
   - **Accept ours** (current branch wins): `git checkout --ours [file] && git add [file]`
   - **Accept theirs** (incoming branch wins): `git checkout --theirs [file] && git add [file]`
   - **Manual merge**: Open the file, read both conflict sections, write the correct merged version, save, then `git add [file]`

3. **Run quality gates** on every resolved file before committing

4. **Complete the merge or rebase**:
   ```
   git add [all resolved files]
   git merge --continue    # or git rebase --continue
   ```

5. **Run the full test suite** after the merge to ensure nothing was broken by the resolution

6. **Log the conflict**:
   ```
   ### [timestamp] — GIT CONFLICT RESOLVED
   **Files:** [list]
   **Strategy used:** [ours / theirs / manual for each file]
   **Tests after merge:** [passed / failed]
   ```

### How to Proceed

After resolution, add a task to the backlog to review the merged files:
- `[Tester] Run regression tests after git conflict resolution in [files]`
- `[Developer] Review merged logic in [file] — confirm no semantic errors from merge resolution`

---

## Token Exhaustion

Token exhaustion occurs when an agent reaches its context window limit and stops responding mid-task, typically without sending a TASK DONE message.

### Detection

- Agent's last message was an intermediate update or partial work, not a completion signal
- The agent described starting a complex task and then went silent
- Agent output was truncated (message ends abruptly without a closing statement)

### Immediate Response

Token exhaustion is not a failure — it is an expected constraint. The goal is to save progress and resume cleanly.

1. **Do not discard the partial work.** The agent likely made real progress.
2. Read the agent's last message carefully. Note:
   - What was explicitly stated as done
   - What was in-progress but not finished
   - What was not started

### Recovery Steps

1. **Assess the codebase**: Check git status or file modification times to see what was actually changed
   ```
   git diff --name-only
   git diff --stat
   ```
2. **Run quality gates** on any modified files to confirm they are in a valid (if incomplete) state
3. **Split the remaining work**: Take the original task and break it into two parts:
   - Part A: Continue from where the agent left off (describe the specific remaining work)
   - Part B: Any cleanup or verification needed
4. **Update the backlog**:
   - Mark the original task `[x]` only if the partial work is complete and valid on its own
   - Add Part A and Part B as new `[ ]` tasks
   - If the partial work is not usable, leave the original task as `[ ]` and add a note: `(partial work in [file] — agent ran out of context)`
5. **Log the exhaustion**:
   ```
   ### [timestamp] — TOKEN EXHAUSTION
   **Agent:** [role]-agent
   **Task:** [task description]
   **Partial work:** [describe what was done]
   **Files modified:** [list]
   **Quality gate state:** [valid / broken]
   **Backlog updated:** [describe changes to backlog]
   ```
6. **Spawn a new agent** for the continuation tasks

### Prevention

- Keep tasks scoped to 15–60 minutes of work
- Avoid assigning tasks that require the agent to read many large files before making changes
- Split tasks that require both reading a large codebase and writing substantial code

---

## Permission Errors

Permission errors should not occur in properly configured Keep Working sessions because agents run with `mode: dontAsk`. If they do occur, use this procedure.

### Detection

- Agent reports "Permission denied" when reading or writing a file
- Agent asks the lead for permission to perform an action
- Agent refuses to perform an action citing permission constraints

### Immediate Response

If the error is a file system permission issue (not a policy issue):
1. Confirm the file path is correct and the file exists
2. Check file permissions: `ls -la [file-path]`
3. If the agent needs write access to a file it should be editing, note this as a project configuration issue

If the agent is asking permission for an action that falls under the lead-protocol.md forbidden actions list:
1. The agent is correct to ask. Do not grant permission for forbidden actions.
2. Reassign the work differently — can the same goal be achieved another way?

### Recovery Steps

For file system permission issues:
1. Log the issue: `### [timestamp] — PERMISSION ERROR — [file path] — [what the agent was trying to do]`
2. If the file should be writable, this is a dev environment configuration issue outside the agent's control. Add a task: `[Developer] Fix file permissions on [path] — agent cannot write to this file`
3. Reassign the agent to a different task while the permission issue is resolved by the human

For policy-level permission questions:
1. Clarify the task description to avoid the ambiguous action
2. Rewrite the task to achieve the goal through allowed means

---

## Build Failures

A build failure occurs when running a build command (e.g., `npm run build`, `cargo build`, `mvn package`) produces errors that prevent a successful output artifact.

### Expected agent behavior

Agents should detect and fix build failures as part of their quality gate procedure. A build failure during an agent's task is the agent's responsibility to resolve before sending TASK DONE. This is normal development work.

### When the lead intervenes

The lead intervenes only when:
- An agent has sent TASK DONE but the build is still broken (the agent missed the failure)
- An agent has been stuck on the same build failure for two or more cycles
- The build failure is caused by a project-wide issue beyond the scope of the assigned task

### Recovery Steps

1. **Read the build output**: Get the exact error message and the file/line causing it
2. **Determine scope**:
   - If it is a small, contained error: add a high-priority task `[Developer] Fix build failure: [exact error] in [file:line]`
   - If it is a systemic issue (e.g., wrong Node version, missing environment variable, dependency conflict): document the root cause and add tasks to address it properly
3. **Prioritize the fix**: Move the fix task to the top of the pending backlog. Spawn a Developer agent for it immediately
4. **Block other tasks if necessary**: If other agents cannot work while the build is broken (e.g., a Tester cannot run tests), add a note to those tasks: `(blocked: waiting for build fix)`
5. **Log the failure**:
   ```
   ### [timestamp] — BUILD FAILURE
   **Stack:** [detected stack]
   **Command:** [command that failed]
   **Error:** [brief description of the error]
   **Root cause:** [known / investigating]
   **Fix task added:** [task description added to backlog]
   ```

---

## All Agents Down

All agents are down when no agents are active, all pending agents have failed or timed out, and the backlog still has work remaining. This is a session-level failure requiring a full respawn.

### Detection

- No agent has sent a message in an extended period
- Previous spawn attempts have not produced any agent output
- Session log shows multiple consecutive crash or timeout events

### Full Respawn Protocol

1. **Do not delete or reset any project files.** The work that was done before the failure is preserved.

2. **Run a health check on the project**:
   - `git status` — Understand the current state of all modified files
   - Run quality gates for the detected stack — Confirm the codebase is in a working state
   - If the codebase is broken, identify the breaking file(s)

3. **Fix any broken state first**: If quality gates fail, add fix tasks to the backlog before spawning agents. The first agent spawned should be a Developer tasked with fixing the broken state.

4. **Read and verify the backlog**: Ensure all in-progress (`[~]`) tasks are reverted to `[ ]`. The failed agents cannot be assumed to have completed any work.

5. **Log the full respawn**:
   ```
   ### [timestamp] — FULL RESPAWN
   **Reason:** All agents down
   **Previous failures:** [N crash/timeout events]
   **Codebase state:** [healthy / broken — describe if broken]
   **Backlog reset:** [N tasks reverted from [~] to [ ]]
   **Action:** Spawning [role]-agent as first priority
   ```

6. **Spawn agents one at a time** starting with the highest-priority role:
   - Spawn Role 1 agent
   - Wait for first TASK DONE or CYCLE DONE
   - Confirm the agent is operating correctly
   - Only then spawn Role 2 agent if needed

7. **Monitor the respawned agents closely** for the first two cycles to confirm stability before returning to the normal work loop

8. **If repeated full respawns occur** (3 or more in one session): stop automatic spawning, log the issue, and notify the human that manual intervention may be needed to diagnose the environment issue.
