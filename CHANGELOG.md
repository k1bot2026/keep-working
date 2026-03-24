# Changelog

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
