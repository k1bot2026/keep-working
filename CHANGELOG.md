# Changelog

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
