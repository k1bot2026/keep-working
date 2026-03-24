# Keep Working

**Autonomous AI agent teams that continuously work on your project.**

Fire and forget — agents analyze your project, pick up tasks, execute them, and automatically receive new work. The cycle repeats until you say stop.

```
You: /keep-working
  → Lead analyzes project, selects 3 agent roles
  → Creates backlog with 15+ tasks
  → Spawns 3 parallel agents
  → Agents work → report → get new tasks → repeat
  → You: /keep-working:stop → summary → done
```

## Installation

```bash
npx keep-working-cc@latest
```

Options:
- `npx keep-working-cc --global` — Install globally (available in all projects)
- `npx keep-working-cc --local` — Install for current project only

**Requirements:**
- [Claude Code](https://claude.ai/claude-code) with Agent Teams support
- Node.js 18+

## Quick Start

```bash
# Navigate to any project
cd my-project

# Start autonomous work
/keep-working

# Check progress (without stopping)
/keep-working:status

# Stop and get summary
/keep-working:stop
```

## Commands

| Command | Description |
|---------|-------------|
| `/keep-working` | Start autonomous agent team |
| `/keep-working:stop` | Graceful shutdown with session summary |
| `/keep-working:status` | Check progress without interrupting |
| `/keep-working:resume` | Resume a previous session |
| `/keep-working:add-task <desc>` | Inject a task mid-session |

### Options

```bash
/keep-working focus:tests          # Focus 60%+ tasks on testing
/keep-working focus:frontend       # Focus on frontend work
/keep-working focus:docs           # Focus on documentation
/keep-working reschedule:on        # Save state for session continuity
/keep-working focus:api reschedule:on  # Combine options
```

**Available focus areas:** `frontend`, `backend`, `api`, `tests`, `docs`, `refactor`, `performance`, `security`, `ui`, `content`, `creative`

## How It Works

### Adaptive Project Analysis

When you start `/keep-working`, the lead analyzes your project and automatically:

1. **Detects your tech stack** — Reads package.json, requirements.txt, Cargo.toml, etc.
2. **Selects 3 agent roles** — Based on what your project needs most
3. **Generates a backlog** — 15+ concrete, actionable tasks
4. **Spawns the team** — 3 agents working in parallel

### The Infinite Loop

```
┌──────────────────────────────────────────────┐
│  Agent works on tasks from the backlog        │
│  ↓                                           │
│  Agent completes task → commits → reports     │
│  ↓                                           │
│  Lead checks off task, logs progress          │
│  ↓                                           │
│  Agent finishes all tasks → "CYCLE DONE"      │
│  ↓                                           │
│  Lead analyzes project → generates 5+ tasks   │
│  ↓                                           │
│  Lead sends agent back to work                │
│  ↓                                           │
│  Repeat ∞                                    │
└──────────────────────────────────────────────┘
```

### Built-in Agent Roles

| Role | Agent | What It Does |
|------|-------|-------------|
| Developer | `kw-developer` | Code implementation in any language/framework |
| Tester | `kw-tester` | Unit tests, integration tests, edge cases, QA |
| Designer | `kw-designer` | UI/UX, CSS, responsive, accessibility |
| Docs Writer | `kw-docs-writer` | README, API docs, comments, guides |
| Content Writer | `kw-content-writer` | CMS content, SEO, copywriting |
| Creative | `kw-creative` | Visual assets, diagrams, design systems |

The lead selects 3 roles based on your project. You can override this in the config.

### Auto-Detection Examples

| Your Project | Selected Roles |
|-------------|---------------|
| React + Express | Frontend Dev, Backend Dev, Tester |
| Python CLI tool | Developer, Tester, Docs Writer |
| WordPress site | PHP Developer, Content Writer, Designer |
| Rust library | Developer, Tester, Docs Writer |
| Go microservice | Developer, Tester, Docs Writer |
| Godot game | Developer, Creative, Designer |
| Monorepo | Developer A, Developer B, Integration Tester |

## Configuration

Keep Working creates a `.keep-working/` directory in your project root:

```
.keep-working/
├── config.json          — Session configuration
├── BACKLOG.md           — Task backlog (prioritized)
├── PROGRESS.md          — Live progress dashboard
├── SESSION-LOG.md       — Detailed history
├── STATE.md             — Session memory & decisions
└── PENDING-QUESTIONS.md — Parked decisions for your review
```

### Custom Configuration

Edit `.keep-working/config.json` to customize:

```json
{
  "roles": {
    "count": 3,
    "assignments": ["developer", "tester", "designer"]
  },
  "model": {
    "default": "sonnet"
  },
  "workflow": {
    "commit_per_task": true,
    "quality_gates": true,
    "min_tasks_per_cycle": 5
  },
  "focus": "tests"
}
```

### Custom Agent Roles

Create custom agent definitions in `.keep-working/agents/` in your project. These take priority over built-in agents. See `agents/kw-developer.md` for the format.

## Architecture

Keep Working follows the orchestrator pattern inspired by [GSD](https://github.com/gsd-build/get-shit-done) and [Superpowers](https://github.com/obra/superpowers):

- **Commands** — User interface (5 slash commands)
- **Agents** — Worker definitions with GSD-style frontmatter and deviation rules
- **Templates** — Consistent state file initialization
- **References** — Shared knowledge (task patterns, quality gates, protocols)

### Key Design Decisions

| Feature | Implementation |
|---------|---------------|
| Agent autonomy | GSD deviation rules (auto-fix bugs, ask about architecture) |
| File coordination | Only lead edits backlog; agents report via messages |
| Quality | Per-task verification gates adapted to your tech stack |
| Git | Atomic commits per task for traceable history |
| Cost | Sonnet for agents (cost-efficient), configurable |
| Reliability | Error recovery with health checks and agent respawn |

## Troubleshooting

**Loop stops prematurely?**
- The lead must never output text without a follow-up tool call
- Check that `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is in your settings

**Agents not responding?**
- The error recovery protocol will detect and handle this
- If persistent: `/keep-working:stop` and restart

**Too many/wrong tasks generated?**
- Use `focus:<area>` to narrow the scope
- Edit `.keep-working/config.json` to change roles
- Use `/keep-working:add-task` to inject specific work

**Want to change agents mid-session?**
- `/keep-working:stop` → edit config → `/keep-working:resume`

## License

MIT

## Credits

- [GitHub Repository](https://github.com/k1bot2026/keep-working)

Inspired by the architectural patterns of:
- [Get Shit Done (GSD)](https://github.com/gsd-build/get-shit-done) — Orchestrator pattern, deviation rules, state management
- [Superpowers](https://github.com/obra/superpowers) — Skill structure, verification gates, context isolation
