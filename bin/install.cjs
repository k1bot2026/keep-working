#!/usr/bin/env node

/**
 * Keep Working — Interactive Installer
 *
 * Installs the Keep Working framework for Claude Code.
 * Usage: npx keep-working-cc@latest
 *
 * Supports:
 * - Global install (~/.claude/) — available in all projects
 * - Local install (.claude/) — project-specific
 *
 * Non-interactive: npx keep-working-cc --global
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const VERSION = require('../package.json').version;
const PACKAGE_DIR = path.resolve(__dirname, '..');

const CYAN = '\x1b[36m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const RED = '\x1b[31m';
const BOLD = '\x1b[1m';
const DIM = '\x1b[2m';
const RESET = '\x1b[0m';

function log(msg) { console.log(msg); }
function info(msg) { console.log(`${CYAN}${msg}${RESET}`); }
function success(msg) { console.log(`${GREEN}✓${RESET} ${msg}`); }
function warn(msg) { console.log(`${YELLOW}⚠${RESET} ${msg}`); }
function error(msg) { console.log(`${RED}✗${RESET} ${msg}`); }

function banner() {
  log('');
  log(`${BOLD}${CYAN}  ┌─────────────────────────────────────┐${RESET}`);
  log(`${BOLD}${CYAN}  │     Keep Working v${VERSION.padEnd(21)}│${RESET}`);
  log(`${BOLD}${CYAN}  │     Autonomous Agent Teams          │${RESET}`);
  log(`${BOLD}${CYAN}  └─────────────────────────────────────┘${RESET}`);
  log('');
}

function ask(rl, question, options) {
  return new Promise((resolve) => {
    if (options) {
      log('');
      options.forEach((opt, i) => {
        log(`  ${BOLD}${i + 1}${RESET}) ${opt.label}${DIM} — ${opt.desc}${RESET}`);
      });
      log('');
    }
    rl.question(`${CYAN}?${RESET} ${question} `, (answer) => {
      resolve(answer.trim());
    });
  });
}

function copyRecursive(src, dest) {
  if (!fs.existsSync(src)) return 0;
  let count = 0;

  if (fs.statSync(src).isDirectory()) {
    fs.mkdirSync(dest, { recursive: true });
    for (const entry of fs.readdirSync(src)) {
      count += copyRecursive(path.join(src, entry), path.join(dest, entry));
    }
  } else {
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(src, dest);
    count = 1;
  }
  return count;
}

function ensureAgentTeams(settingsPath) {
  let settings = {};
  if (fs.existsSync(settingsPath)) {
    try {
      settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    } catch {
      settings = {};
    }
  }

  if (!settings.env) settings.env = {};

  if (settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS !== '1') {
    settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = '1';
    fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
    return true;
  }
  return false;
}

async function main() {
  const args = process.argv.slice(2);
  const isGlobal = args.includes('--global');
  const isLocal = args.includes('--local');
  const isNonInteractive = isGlobal || isLocal;

  banner();

  let scope;

  if (isNonInteractive) {
    scope = isGlobal ? 'global' : 'local';
  } else {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const answer = await ask(rl, 'Where do you want to install?', [
      { label: 'Global', desc: '~/.claude/ — available in all projects' },
      { label: 'Local', desc: '.claude/ — this project only' },
    ]);

    scope = answer === '2' ? 'local' : 'global';
    rl.close();
  }

  const homeDir = process.env.HOME || process.env.USERPROFILE;
  const targetBase = scope === 'global'
    ? path.join(homeDir, '.claude')
    : path.join(process.cwd(), '.claude');

  log('');
  info(`Installing to: ${targetBase}`);
  log('');

  // Copy commands
  const cmdSrc = path.join(PACKAGE_DIR, 'commands');
  const cmdDest = path.join(targetBase, 'commands');
  const cmdCount = copyRecursive(cmdSrc, cmdDest);
  success(`Commands installed (${cmdCount} files)`);

  // Copy agents
  const agentSrc = path.join(PACKAGE_DIR, 'agents');
  const agentDest = path.join(targetBase, 'agents');
  const agentCount = copyRecursive(agentSrc, agentDest);
  success(`Agent definitions installed (${agentCount} files)`);

  // Copy keep-working support files (templates + references)
  const kwDir = path.join(targetBase, 'keep-working');

  const tplSrc = path.join(PACKAGE_DIR, 'templates');
  const tplDest = path.join(kwDir, 'templates');
  const tplCount = copyRecursive(tplSrc, tplDest);
  success(`Templates installed (${tplCount} files)`);

  const refSrc = path.join(PACKAGE_DIR, 'references');
  const refDest = path.join(kwDir, 'references');
  const refCount = copyRecursive(refSrc, refDest);
  success(`References installed (${refCount} files)`);

  // Copy example config
  const exSrc = path.join(PACKAGE_DIR, 'examples');
  const exDest = path.join(kwDir, 'examples');
  const exCount = copyRecursive(exSrc, exDest);
  success(`Examples installed (${exCount} files)`);

  // Ensure Agent Teams is enabled
  const settingsPath = scope === 'global'
    ? path.join(homeDir, '.claude', 'settings.json')
    : path.join(process.cwd(), '.claude', 'settings.json');

  const teamsEnabled = ensureAgentTeams(settingsPath);
  if (teamsEnabled) {
    success('Enabled CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS in settings');
  } else {
    success('Agent Teams already enabled');
  }

  // Summary
  const totalFiles = cmdCount + agentCount + tplCount + refCount + exCount;
  log('');
  log(`${GREEN}${BOLD}Installation complete!${RESET} (${totalFiles} files)`);
  log('');
  log(`${BOLD}Quick Start:${RESET}`);
  log(`  ${DIM}In any project directory:${RESET}`);
  log(`  ${CYAN}/keep-working${RESET}              Start autonomous team`);
  log(`  ${CYAN}/keep-working:stop${RESET}         Stop and get summary`);
  log(`  ${CYAN}/keep-working:status${RESET}       Check progress`);
  log(`  ${CYAN}/keep-working:resume${RESET}       Resume previous session`);
  log(`  ${CYAN}/keep-working:add-task${RESET}     Add a task mid-session`);
  log('');
  log(`${DIM}Options:${RESET}`);
  log(`  ${CYAN}/keep-working focus:tests${RESET}  Focus on testing`);
  log(`  ${CYAN}/keep-working reschedule:on${RESET} Enable session save`);
  log('');
  log(`${DIM}Docs: https://github.com/YOUR_USERNAME/keep-working${RESET}`);
  log('');
}

main().catch((err) => {
  error(`Installation failed: ${err.message}`);
  process.exit(1);
});
