# Keep Working — Suggest Actions

Suggest specific approaches, choices, or actions to the team without disrupting their workflow. Unlike `/keep-working:feed` (which shares information), this gives the team directional guidance on HOW to do things.

Use this when you want to steer the team's approach — suggest a library, a design pattern, a specific implementation strategy, or nudge them toward a particular solution.

## Usage
```
/keep-working:suggest <suggestion>
```

## Arguments
$ARGUMENTS

## Examples
```
/keep-working:suggest Use Tailwind CSS instead of custom CSS for the styling
/keep-working:suggest Try the repository pattern for the database layer
/keep-working:suggest The hero section should use a full-width background image
/keep-working:suggest Prioritize mobile layout first, desktop can wait
/keep-working:suggest Use Zod for input validation instead of manual checks
```

## Procedure

### 1. Validate Session

Check that `.keep-working/STATE.md` exists.
- If not: "No active Keep Working session. Use `/keep-working` to start one."

### 2. Classify the Suggestion

Determine the nature:
- **Technical approach** — Use a specific library, pattern, or architecture ("use Redis for caching")
- **Design direction** — Visual or UX preference ("make buttons rounded", "use dark theme")
- **Priority guidance** — What to focus on next ("skip tests for now, focus on core features")
- **Quality preference** — Standards to apply ("all functions need JSDoc", "100% test coverage")
- **Tooling preference** — Which tools to use ("use pnpm not npm", "deploy with Docker")

### 3. Determine Binding Level

Suggestions are **advisory by default** — agents should follow them but can deviate if there's a strong technical reason. Note this distinction:

| Level | When | Agent behavior |
|-------|------|---------------|
| **Suggestion** (default) | "Try X", "Consider Y", "I'd prefer Z" | Follow unless technically problematic; log if deviating |
| **Direction** | "Use X", "Switch to Y", "Must be Z" | Follow as requirement; only deviate via Rule 4 (ask lead) |

Detect from the user's language which level applies.

### 4. Log to STATE.md

Append to `.keep-working/STATE.md` under `## Decisions Made`:

```markdown
### [TIMESTAMP] — User Suggestion: [type]
**Suggestion:** [the full suggestion]
**Binding:** [advisory / directive]
**Affects:** [which roles]
**Applied from:** [now / next cycle / specific task]
```

### 5. Notify Relevant Agent(s)

Send a targeted message:

```
SendMessage type="message", recipient="<agent-name>"
content="USER SUGGESTION: [the suggestion]

Binding level: [advisory — follow unless technically problematic / directive — treat as requirement]

How to apply:
- If you're mid-task: finish current approach, apply suggestion to remaining work
- If this changes your current task: adapt your approach accordingly
- If you disagree technically: log your reasoning in PENDING-QUESTIONS.md and follow the suggestion anyway (unless it would break something)"
summary="User suggests: [short description]"
```

### 6. Update Backlog If Needed

If the suggestion implies changes to existing or new tasks:
- Add new tasks with `(per user suggestion)` tag
- Update existing task descriptions to reflect the new approach
- Re-prioritize if the suggestion implies urgency

### 7. Confirm to User

Tell the user:
"Suggestion shared with [agent name(s)] as [advisory/directive]. They'll apply it to their current and future work."

## Important

- This does NOT stop the work loop
- Agents receive the suggestion as a message and adapt
- If agents are mid-task, they finish current work first then apply
- Suggestions are logged in STATE.md for session continuity
- Conflicting suggestions: latest one wins (noted in STATE.md)
