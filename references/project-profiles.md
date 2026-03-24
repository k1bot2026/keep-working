# Project Profiles Reference

Automatic project type detection and role/stack mapping. The lead orchestrator reads this document at session start to identify the project type, select the right agent roles, and choose the appropriate quality gates section.

---

## How to Use This Document

1. List all files in the project root: `ls -la` and note key filenames
2. Check for the detection signals in the Detection Signals table
3. Match to a Project Type in the Role Mapping Table
4. Use the mapped roles for agent spawning
5. Use the mapped quality gates section for all agent instructions

If multiple signals are detected, see the Multiple Signal Resolution section at the bottom.

---

## Detection Signals

### Definitive signals (one signal is conclusive)

| File / Pattern | Project Type | Notes |
|---|---|---|
| `wp-content/` directory exists | WordPress | Confirms WordPress installation |
| `wp-config.php` exists | WordPress | WordPress config, even without wp-content/ |
| `wp-includes/` directory exists | WordPress | WordPress core present |
| `Cargo.toml` exists | Rust | Rust package manifest |
| `go.mod` exists | Go | Go module file |
| `pom.xml` exists | Java (Maven) | Maven build system |
| `build.gradle` or `build.gradle.kts` exists | Java/Kotlin (Gradle) | Gradle build system |
| `*.csproj` exists | .NET (C#) | C# project file |
| `*.sln` exists | .NET Solution | Visual Studio solution, may contain multiple projects |
| `*.fsproj` exists | .NET (F#) | F# project file |
| `project.godot` exists | Godot Game | Godot Engine project |
| `*.gdproject` exists | Godot Game | Alternative Godot project file |
| `Gemfile` exists | Ruby | Ruby dependency file |
| `composer.json` exists | PHP | PHP dependency manager |

### Contextual signals (require reading file content)

| File | Signal to Check | Project Type |
|---|---|---|
| `package.json` | `dependencies` contains `react`, `vue`, `@angular/core`, `svelte`, `solid-js`, `preact` AND `devDependencies` contains `vite`, `webpack`, `parcel`, `rollup`, or `esbuild` | Frontend |
| `package.json` | `dependencies` contains `next`, `nuxt`, `remix`, `@remix-run`, `gatsby`, `astro` | Full-Stack JS |
| `package.json` | `dependencies` contains `express`, `fastify`, `@nestjs/core`, `koa`, `hapi`, `@hapi/hapi`, `restify`, `feathers` | Backend API (Node.js) |
| `package.json` | `devDependencies` contains `electron` or `dependencies` contains `electron` | Desktop App |
| `package.json` | `dependencies` contains `react-native`, `expo` | Mobile App |
| `requirements.txt` | File exists (any content) | Python |
| `pyproject.toml` | File exists | Python |
| `setup.py` | File exists | Python Package |
| `setup.cfg` | File exists | Python |
| `Pipfile` | File exists | Python (Pipenv) |
| `.github/workflows/` | Directory exists with `.yml` files | CI/CD |
| `docker-compose.yml` or `compose.yml` | File exists (regardless of other signals) | Docker/DevOps overlay |
| `Dockerfile` | File exists (regardless of other signals) | Docker/DevOps overlay |

### Supplementary signals (help distinguish subtypes)

| Pattern | Indicates |
|---|---|
| `tsconfig.json` present | TypeScript is in use (applies to Frontend, Backend, Full-Stack) |
| `jest.config.js` / `vitest.config.js` present | JavaScript testing configured |
| `.eslintrc*` or `eslint.config.*` present | ESLint configured |
| `prisma/` directory or `drizzle.config.ts` | Database ORM present |
| `src/` with `controllers/`, `services/`, `repositories/` | MVC/layered backend architecture |
| `src/` with `components/`, `pages/`, `hooks/` | Component-based frontend architecture |
| `src/` with `routes/`, `middleware/`, `models/` | Express-style backend |
| Multiple language-specific files (`*.py`, `*.ts`, `*.go`) | Monorepo |
| Only `README.md` and no source files | New or empty project |

---

## Role Mapping Table

For each detected project type, use these three primary roles. Additional roles can be added from the fourth column based on project maturity and remaining work.

| Project Type | Primary Role 1 | Primary Role 2 | Primary Role 3 | Additional Roles |
|---|---|---|---|---|
| Frontend | Developer | Designer | Tester | Docs Writer (if library/component) |
| Backend API (Node.js) | Developer | Tester | Docs Writer | — |
| Full-Stack JS | Developer | Tester | Designer | Docs Writer |
| Python | Developer | Tester | Docs Writer | Creative (for data visualizations) |
| Python Package | Developer | Docs Writer | Tester | — |
| PHP | Developer | Tester | Docs Writer | — |
| WordPress | Developer | Designer | Content Writer | Creative |
| Rust | Developer | Tester | Docs Writer | — |
| Go | Developer | Tester | Docs Writer | — |
| Ruby | Developer | Tester | Docs Writer | — |
| Java (Maven) | Developer | Tester | Docs Writer | — |
| Java/Kotlin (Gradle) | Developer | Tester | Designer (if Android) | Docs Writer |
| .NET (C#) | Developer | Tester | Docs Writer | Designer (if Blazor/MAUI) |
| Godot Game | Developer | Creative | Designer | Tester |
| Desktop App (Electron) | Developer | Designer | Tester | Docs Writer |
| Mobile App (React Native) | Developer | Designer | Tester | Content Writer |
| CI/CD | Developer | Docs Writer | Tester | — |
| Docker/DevOps | Developer | Docs Writer | Tester | — |
| Monorepo | Developer | Tester | Docs Writer | Designer (if UI packages present) |
| New/Empty Project | Docs Writer | Developer | Creative | Designer |

### Role selection rationale

- **WordPress** projects prioritize Designer and Content Writer because the dominant work is visual layout and editorial content, not application logic
- **Godot** projects prioritize Creative because asset creation (sprites, diagrams, UI mockups) is a major workstream
- **New/Empty projects** start with Docs Writer to establish the project spec before any code is written
- **CI/CD** and **Docker/DevOps** projects rarely need a Designer but benefit heavily from documentation

---

## Quality Gate Selection

After detecting the project type, agents reference this table to select the correct section from `quality-gates.md`.

| Project Type | Quality Gates Section |
|---|---|
| Frontend (React, Vue, Angular, Svelte) | `JavaScript / TypeScript (Frontend)` |
| Backend API (Node.js) | `JavaScript / TypeScript (Node.js Backend)` |
| Full-Stack JS (Next.js, Nuxt, Remix) | `JavaScript / TypeScript (Frontend)` AND `JavaScript / TypeScript (Node.js Backend)` |
| Python | `Python` |
| PHP | `PHP` |
| WordPress | `WordPress` AND `PHP` |
| Rust | `Rust` |
| Go | `Go` |
| Ruby | `Ruby` |
| Java (Maven) | `Java / Kotlin` |
| Java/Kotlin (Gradle) | `Java / Kotlin` |
| .NET (C#/F#) | `C# / .NET` |
| Godot | `Generic (Any Stack)` |
| CI/CD | `Generic (Any Stack)` AND `Docker` (if Dockerfile present) |
| Docker/DevOps | `Docker` |
| Monorepo | Apply the section for each sub-project's detected language |
| New/Empty Project | `Generic (Any Stack)` |
| Any project | Always also apply `Generic (Any Stack)` — it supplements all other sections |

---

## Common Tech Stacks Table

A reference mapping from detected files to specific named stacks, tools, and ecosystems.

| Detection File(s) | Stack Name | Primary Language | Key Tools |
|---|---|---|---|
| `package.json` + `react` + `vite` | React + Vite | TypeScript/JavaScript | React, Vite, Vitest or Jest, ESLint, Prettier |
| `package.json` + `react` + `webpack` | React + Webpack | TypeScript/JavaScript | React, Webpack, Jest, ESLint, Babel |
| `package.json` + `vue` | Vue 3 | TypeScript/JavaScript | Vue, Vite, Vitest, ESLint, Pinia |
| `package.json` + `@angular/core` | Angular | TypeScript | Angular CLI, Karma, Jasmine, ESLint |
| `package.json` + `svelte` | Svelte / SvelteKit | TypeScript/JavaScript | Svelte, Vite, Vitest, ESLint |
| `package.json` + `next` | Next.js | TypeScript/JavaScript | Next.js, Jest or Vitest, ESLint |
| `package.json` + `nuxt` | Nuxt 3 | TypeScript/JavaScript | Nuxt, Vitest, ESLint |
| `package.json` + `remix` | Remix | TypeScript/JavaScript | Remix, Vitest, ESLint |
| `package.json` + `express` | Express.js | TypeScript/JavaScript | Express, Jest, Supertest, ESLint |
| `package.json` + `fastify` | Fastify | TypeScript/JavaScript | Fastify, Jest or Tap, ESLint |
| `package.json` + `@nestjs/core` | NestJS | TypeScript | NestJS, Jest, ESLint |
| `package.json` + `electron` | Electron | TypeScript/JavaScript | Electron, Jest, ESLint, electron-builder |
| `package.json` + `react-native` | React Native | TypeScript/JavaScript | React Native, Jest, ESLint, Metro |
| `requirements.txt` + `django` | Django | Python | Django, pytest-django, coverage, ruff, mypy |
| `requirements.txt` + `fastapi` | FastAPI | Python | FastAPI, pytest, httpx, mypy, ruff |
| `requirements.txt` + `flask` | Flask | Python | Flask, pytest, coverage, ruff, mypy |
| `requirements.txt` + `numpy` / `pandas` | Data Science (Python) | Python | Jupyter, pandas, numpy, pytest, ruff, mypy |
| `pyproject.toml` (no framework signals) | Python Package | Python | setuptools or hatch, pytest, mypy, ruff |
| `Cargo.toml` | Rust | Rust | cargo, clippy, rustfmt, cargo-audit |
| `go.mod` | Go | Go | go test, go vet, golangci-lint, gofmt |
| `composer.json` + `laravel` | Laravel | PHP | Artisan, PHPUnit, PHP-CS-Fixer, PHPStan |
| `composer.json` + `symfony` | Symfony | PHP | Symfony CLI, PHPUnit, PHP-CS-Fixer, PHPStan |
| `composer.json` (no framework) | PHP (generic) | PHP | Composer, PHPUnit, PHP-CS-Fixer |
| `wp-config.php` or `wp-content/` | WordPress | PHP | WP-CLI, PHPUnit (via wp-phpunit), PHP-CS-Fixer |
| `Gemfile` + `rails` | Ruby on Rails | Ruby | Rails, RSpec, Rubocop, factory_bot |
| `Gemfile` (no rails) | Ruby (generic) | Ruby | Bundler, RSpec, Rubocop |
| `pom.xml` + Spring annotations | Spring Boot (Maven) | Java | Spring Boot, JUnit 5, Mockito, Checkstyle |
| `build.gradle.kts` + Spring | Spring Boot (Gradle) | Kotlin/Java | Spring Boot, JUnit 5, Mockito, ktlint |
| `*.csproj` + `Microsoft.AspNetCore` | ASP.NET Core | C# | .NET CLI, xUnit, NUnit, or MSTest, dotnet-format |
| `*.csproj` + `Blazor` | Blazor | C# | .NET CLI, bUnit for component tests, dotnet-format |
| `project.godot` | Godot 4 | GDScript/C# | Godot CLI, GUT (Godot Unit Test) |
| `docker-compose.yml` | Docker Compose | YAML/Shell | docker compose, hadolint (Dockerfile linter) |
| `.github/workflows/*.yml` | GitHub Actions CI/CD | YAML | actionlint, GitHub CLI (gh) |
| Multiple: `go.mod` + `package.json` + `*.py` | Monorepo | Mixed | Per-language tools for each sub-project |

---

## Multiple Signal Resolution

When the project root contains signals for more than one project type, use this priority order to determine the primary profile:

### Priority order (highest to lowest)

1. **WordPress** — If `wp-content/` or `wp-config.php` is present, always use WordPress profile regardless of other signals. WordPress projects often have `composer.json` and `package.json` alongside, but WordPress is the defining context.

2. **Full-Stack** — If `package.json` contains a full-stack framework (`next`, `nuxt`, `remix`, `astro`, `gatsby`), use Full-Stack JS profile. The frontend and backend are unified.

3. **Monorepo** — If three or more different language-specific files or directories are present (e.g., `go.mod` AND `package.json` AND `requirements.txt`), and no single framework is dominant, use the Monorepo profile. Spawn separate agents per sub-project language.

4. **Single-language project with Docker overlay** — If a primary language is detected AND `Dockerfile`/`docker-compose.yml` is also present, use the primary language profile for role mapping and quality gates. Apply the Docker quality gates section as a supplementary check.

5. **CI/CD overlay** — If `.github/workflows/` is present alongside a primary language, use the primary language profile. The CI/CD work is secondary unless that is explicitly the focus of the session.

### Monorepo handling

When a Monorepo profile is detected:
1. List all sub-projects: each directory with its own `package.json`, `go.mod`, `Cargo.toml`, etc. is a sub-project
2. For each sub-project, detect the stack independently using this document
3. Create agent tasks that are scoped to a single sub-project (do not mix sub-projects in one task)
4. In agent prompts, specify the sub-project path: "Work only within `packages/api/` — do not modify `packages/web/`"
5. Apply the quality gates for each sub-project's detected stack independently

### Example: Next.js project with a Dockerfile

- Primary signal: `next` in `package.json` → Full-Stack JS
- Secondary signal: `Dockerfile` → Docker overlay
- Decision: Use Full-Stack JS profile for roles and quality gates. Also require agents to run `docker build` check during build verification steps.

### Example: WordPress with a composer.json and package.json

- Primary signal: `wp-content/` → WordPress
- Additional signals: `composer.json` (PHP dependencies), `package.json` (asset pipeline)
- Decision: WordPress profile. The `composer.json` is likely for PHP tools (WooCommerce, ACF Pro). The `package.json` is likely for SCSS/JS compilation. Both are normal in WordPress projects; they do not change the profile.

---

## Empty / New Project Handling

If only a `README.md` exists and no source code or build files are present, this is a new or empty project.

### Default approach for new projects

1. **Roles**: Docs Writer (first), Developer (second), Creative (third)
2. **First agent task**: `[Docs Writer] Read README.md and create a project spec in SPEC.md — define tech stack choice, directory structure, MVP feature list, and development phases`
3. **After spec is written**: Lead reads SPEC.md, detects the planned tech stack, and switches to the appropriate profile for all subsequent work
4. **Quality gates**: Use `Generic (Any Stack)` until the tech stack is established, then switch to the appropriate section

### Bootstrapping sequence for new projects

1. Docs Writer writes the project spec
2. Developer scaffolds the project structure (creates package.json, installs dependencies, sets up config files)
3. Lead re-runs detection after scaffolding — the project now has detection signals
4. Lead switches to the correct profile and resumes with the standard role mapping
