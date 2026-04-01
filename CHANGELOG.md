# Changelog

## [1.3.0] - 2026-04-01

### Added
- **Local AI modes** — `local:off` (default), `local:assist` (hybrid), `local:full` (all local)
- **`/keep-working:local-status`** — New command to check LocalAI gateway status and session savings
- **Task delegation** — Simple/moderate tasks automatically delegated to local model in assist mode
- **Confidence-based routing** — High confidence accepted, medium flagged for review, low escalated to paid
- **Cost tracking** — Real-time tracking of local vs paid completions with savings percentage

### Changed
- `/keep-working:status` now shows LocalAI stats when active
- `/keep-working:resume` verifies gateway availability when local mode is active
- Session config includes local AI settings and stats

## [1.2.0] - 2026-03-27

### Added
- **Token Guard** — Background watchdog that detects token exhaustion and auto-resumes after the window resets
- `/keep-working:wait` — Manual save-and-wait trigger for when you know the limit is approaching
- `token_guard` config section — configure window hours, inactivity threshold, auto-resume, notifications
- `bin/token-guard.sh` — Lightweight bash script (zero API token usage) that monitors, waits, and resumes
- Cross-platform notifications (macOS `osascript`, Linux `notify-send`)
- Guard lifecycle management — auto-start at session begin, auto-stop at session end, restart on resume

## [1.1.0] - 2026-03-24

### Added
- `/keep-working:feed` — Share info, data, links, requirements with the team mid-session
- `/keep-working:suggest` — Suggest approaches and actions to agents without disrupting workflow
- `/keep-working:backlog` — View task backlog and priority breakdown (read-only)
- Skills & MCP discovery — agents auto-detect and use installed skills (Superpowers, GSD) and MCP servers (Playwright, Docker, etc.)
- Tools section in agent prompts — agents know what extra capabilities are available
- Tools section in config.json — tracks discovered skills and MCP servers

## [1.0.0] - 2026-03-24

### Added
- Initial release
- Autonomous agent team with continuous work loop
- 5 commands: `/keep-working`, `/keep-working:stop`, `/keep-working:status`, `/keep-working:resume`, `/keep-working:add-task`
- 6 built-in agent roles: developer, tester, designer, docs-writer, content-writer, creative
- Adaptive project analysis — auto-detects tech stack and selects roles
- Configuration system — `.keep-working/config.json` for workflow customization
- State management — `.keep-working/` directory with backlog, progress, session log
- Quality gates per tech stack
- GSD-style deviation rules (Rules 1-4) for autonomous decision making
- Per-task atomic git commits
- Error recovery — agent health checks, task redistribution, respawn
- Session resume — save and restore state across sessions
- Task injection — add tasks mid-session without stopping
- Interactive installer for Claude Code
