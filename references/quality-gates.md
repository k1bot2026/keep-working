# Quality Gates Reference

Quality verification procedures agents must run after every code change. After completing any task, the agent identifies which stack applies (often multiple stacks apply simultaneously), runs the relevant commands, and reports results in its completion message. A task is not complete until all quality gates pass.

**Key principle:** Never report a task done if any command exits non-zero. Fix the failure first, or explicitly document why it is being deferred with a new backlog task created for the fix.

---

## JavaScript / TypeScript (Node.js Backend)

**Detection:** `package.json` exists AND one or more of: `express`, `fastify`, `nestjs`, `koa`, `hapi`, `@hapi`, `restify`, `feathers` in `dependencies` or `devDependencies`. No DOM APIs, no bundler (webpack/vite/parcel) in use.

**After code changes:**
1. `npm run lint` — Checks code style and catches common errors via ESLint; fix all errors, warnings are advisory
2. `npx tsc --noEmit` — Type-checks TypeScript without emitting files; zero errors required
3. `npm test -- --testPathPattern=[changed-file]` — Runs tests related to the changed file; all must pass
4. `node -e "require('./[changed-file]')"` — Confirms the module loads without runtime errors

**After test changes:**
1. `npm test` — Run full test suite; all tests must pass, no skipped tests without documented reason
2. `npm run test:coverage` — Check coverage does not drop; review if any critical path is now uncovered

**Build verification:**
1. `npm run build` (if present) — Confirms the project still compiles to dist/
2. `node dist/[entry-point].js --version` (if applicable) — Confirms the built artifact starts cleanly

---

## JavaScript / TypeScript (Frontend)

**Detection:** `package.json` exists AND one or more of: `react`, `vue`, `angular`, `svelte`, `solid-js`, `preact` in `dependencies`. Bundler present: `webpack`, `vite`, `parcel`, `rollup`, or `esbuild` in `devDependencies`.

**After code changes:**
1. `npm run lint` — ESLint check; zero errors required, address any new warnings introduced
2. `npx tsc --noEmit` — TypeScript type check; zero errors required (skip if pure JS project)
3. `npm test -- --watchAll=false` — Run component and unit tests in CI mode; all must pass
4. `npm run build` — Full production build; zero errors, review bundle size warning if output grows >10%

**After test changes:**
1. `npm test -- --watchAll=false` — Full test suite; all pass, no snapshot mismatches
2. `npm run test:coverage -- --coverageThreshold '{}'` — Verify coverage is not regressing

**Build verification:**
1. `npm run build` — Production build succeeds with no errors
2. `ls -lh dist/` or `ls -lh build/` — Confirm output files exist and are non-zero size
3. `npx serve dist/ -p 3001` (optional manual check) — Serve and visually verify in browser

---

## Python

**Detection:** One or more of: `requirements.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`, `Pipfile` present in project root. Language is Python.

**After code changes:**
1. `python -m py_compile [changed-file.py]` — Syntax check; any syntax error must be fixed immediately
2. `python -m mypy [changed-file.py] --ignore-missing-imports` — Type check; address all errors, note any intentional `type: ignore`
3. `python -m ruff check [changed-file.py]` (or `flake8 [changed-file.py]`) — Lint; zero errors required
4. `python -m ruff format --check [changed-file.py]` (or `black --check`) — Format check; run `ruff format` / `black` to fix

**After test changes:**
1. `python -m pytest [test-file.py] -v` — Run specific test file; all pass
2. `python -m pytest --tb=short` — Full test suite; all pass

**Build verification:**
1. `python -m pytest --tb=short -q` — Full suite in quiet mode
2. `python -m mypy . --ignore-missing-imports` — Project-wide type check
3. If package: `python -m build --no-isolation` — Confirm the package builds without errors

---

## PHP

**Detection:** `composer.json` present, or `.php` files present in project root or `src/`.

**After code changes:**
1. `php -l [changed-file.php]` — Syntax check; "No syntax errors" required; fix any parse errors immediately
2. `./vendor/bin/php-cs-fixer fix [changed-file.php] --dry-run --diff` — Check code style; run without `--dry-run` to auto-fix
3. `./vendor/bin/phpstan analyse [changed-file.php] --level=5` (if phpstan installed) — Static analysis; address all errors
4. `./vendor/bin/phpunit --filter [TestClass]` — Run tests relevant to the changed file

**After test changes:**
1. `./vendor/bin/phpunit` — Full test suite; all pass
2. `./vendor/bin/phpunit --coverage-text` — Review coverage; note any critical paths now uncovered

**Build verification:**
1. `composer validate` — Confirms `composer.json` and `composer.lock` are consistent
2. `composer install --no-dev --dry-run` — Confirms production dependencies resolve cleanly
3. `php -l` on all files: `find . -name "*.php" -not -path "*/vendor/*" | xargs php -l | grep -v "No syntax errors"`

---

## Rust

**Detection:** `Cargo.toml` present in project root.

**After code changes:**
1. `cargo check` — Fast compile check without producing binaries; fix all errors and warnings
2. `cargo clippy -- -D warnings` — Linter; treat all warnings as errors; address every lint
3. `cargo fmt --check` — Format check; run `cargo fmt` to fix, then re-check
4. `cargo test [module_name]` — Run tests for the affected module

**After test changes:**
1. `cargo test` — Full test suite including doc tests; all must pass
2. `cargo test -- --nocapture` (if debugging failures) — Show stdout from tests

**Build verification:**
1. `cargo build --release` — Full release build; zero errors, zero warnings
2. `cargo test --release` — Run tests against release build to catch optimization-dependent bugs
3. `cargo audit` (if installed) — Check for known security vulnerabilities in dependencies

---

## Go

**Detection:** `go.mod` present in project root.

**After code changes:**
1. `go vet ./...` — Static analysis; zero issues required; fix all reported problems
2. `gofmt -l [changed-file.go]` — Format check; output means file needs formatting; run `gofmt -w [file]` to fix
3. `golangci-lint run ./...` (if installed) — Comprehensive lint; address all issues
4. `go build ./...` — Confirm the package compiles successfully

**After test changes:**
1. `go test ./... -count=1` — Full test suite with cache disabled; all pass
2. `go test -race ./...` — Race condition detection; all pass with no data races

**Build verification:**
1. `go build -v ./...` — Verbose build; confirm all packages compile
2. `go test ./... -cover` — Test with coverage output; review any drop in coverage
3. `go mod tidy` then `git diff go.mod go.sum` — Confirm no unresolved dependency changes

---

## Ruby

**Detection:** `Gemfile` present in project root. May also have `*.gemspec`.

**After code changes:**
1. `ruby -c [changed-file.rb]` — Syntax check; "Syntax OK" required
2. `bundle exec rubocop [changed-file.rb]` — Style and lint check; zero offenses required (use `--auto-correct` for safe fixes)
3. `bundle exec sorbet tc` (if Sorbet is used) — Type check; zero errors

**After test changes:**
1. `bundle exec rspec [spec-file]` — Run the specific spec file; all examples pass
2. `bundle exec rspec` — Full test suite; all examples pass, zero failures

**Build verification:**
1. `bundle exec rspec --format progress` — Full suite in compact format
2. `bundle exec rubocop` — Full codebase lint
3. If gem: `gem build [name].gemspec` — Confirm the gem package builds

---

## Java / Kotlin

**Detection:** `pom.xml` (Maven) or `build.gradle` / `build.gradle.kts` (Gradle) present in project root.

**After code changes (Maven):**
1. `mvn compile -q` — Compile check; zero errors required
2. `mvn checkstyle:check` (if configured) — Style compliance; zero violations
3. `mvn test -pl [module] -Dtest=[TestClass]` — Run tests for affected class

**After code changes (Gradle):**
1. `./gradlew compileJava` or `./gradlew compileKotlin` — Compile check; zero errors
2. `./gradlew ktlintCheck` (Kotlin) or `./gradlew checkstyleMain` (Java) — Lint; zero issues
3. `./gradlew test --tests "[TestClass]"` — Run tests for affected class

**After test changes:**
1. `mvn test -q` or `./gradlew test` — Full test suite; all tests pass, report in `target/surefire-reports/`
2. `mvn verify` or `./gradlew check` — Full verification including integration tests if configured

**Build verification:**
1. `mvn package -DskipTests -q` or `./gradlew build -x test` — Full build without tests
2. `mvn package` or `./gradlew build` — Full build with tests; all pass, artifact produced

---

## C# / .NET

**Detection:** `*.csproj`, `*.sln`, or `*.fsproj` present in project.

**After code changes:**
1. `dotnet build [project.csproj] --no-restore -warnaserror` — Build with warnings as errors; zero issues
2. `dotnet format [project.csproj] --verify-no-changes` — Format check; run `dotnet format` to fix if needed
3. `dotnet test [TestProject.csproj] --filter "FullyQualifiedName~[TestClass]"` — Run tests for changed area

**After test changes:**
1. `dotnet test` — Full test suite; all pass
2. `dotnet test --collect:"XPlat Code Coverage"` — Collect coverage; review report for regressions

**Build verification:**
1. `dotnet build --configuration Release -warnaserror` — Release build; zero errors, zero warnings
2. `dotnet test --configuration Release` — Run tests against release build
3. `dotnet publish -c Release -o ./publish` — Confirm publish output succeeds

---

## WordPress

**Detection:** `wp-content/` directory present, or `wp-config.php` present, or `wp-includes/` directory present.

**After code changes:**
1. `php -l [changed-file.php]` — Syntax check every modified PHP file; "No syntax errors" required
2. `find wp-content/themes/[theme] -name "*.php" | xargs php -l | grep -v "No syntax errors"` — Batch syntax check entire theme
3. `bash Claude/scripts/wp-cli.sh [SITENAME] eval 'echo "OK";'` — Confirms WordPress bootstraps without fatal errors after the change
4. `bash Claude/scripts/wp-cli.sh [SITENAME] theme list` — Confirms the active theme is still active (not broken)

**After template / hook changes:**
1. `bash Claude/scripts/wp-cli.sh [SITENAME] eval 'echo get_bloginfo("name");'` — Confirms core functions work
2. `bash Claude/scripts/wp-cli.sh [SITENAME] option get template` — Confirms active theme is correct
3. Browser reload and screenshot — Visual check that the page still renders (no white screen of death)

**After plugin changes:**
1. `php -l [changed-plugin-file.php]` — Syntax check
2. `bash Claude/scripts/wp-cli.sh [SITENAME] plugin status [plugin-name]` — Plugin is active and not in error state
3. `bash Claude/scripts/wp-cli.sh [SITENAME] eval 'do_action("init");'` — Confirms hooks fire without fatal errors

**Build verification (no traditional build, but validate state):**
1. `bash Claude/scripts/wp-cli.sh [SITENAME] doctor` (if WP-CLI doctor is available) — Health checks
2. `bash Claude/scripts/wp-cli.sh [SITENAME] option get siteurl` — Site URL is correct
3. `bash Claude/scripts/wp-cli.sh [SITENAME] post list --post_status=publish --fields=ID,post_title` — Content is accessible

---

## Generic (Any Stack)

**Detection:** Apply these checks to every project regardless of stack. These are universal minimum requirements.

**After any code changes:**
1. `git diff --stat` — Confirm the right files were changed; nothing unexpected should appear
2. `git diff` — Review the diff to catch accidental debug code (`console.log`, `print`, `debugger`, `TODO: remove`, passwords)
3. Manually verify the changed file can be parsed/loaded by its runtime (language-specific syntax check)
4. Confirm no hardcoded credentials, API keys, or secrets were added: `git diff | grep -iE "(api_key|secret|password|token)\s*=" `

**After any test changes:**
1. Run the tests and confirm all pass
2. Confirm no test uses `.skip` or `.only` that was not there before (these should never be committed)

**File existence checks:**
1. Confirm any new file is in the correct directory per project conventions
2. Confirm file permissions are correct: `ls -la [new-file]` — should not be executable unless intentional
3. Confirm no build artifacts were accidentally committed: check for `dist/`, `build/`, `*.pyc`, `node_modules/` in `git diff --name-only`

---

## Docker

**Detection:** `Dockerfile` or `docker-compose.yml` / `docker-compose.yaml` / `compose.yml` present in project root. May also have `.dockerignore`.

**After Dockerfile changes:**
1. `docker build -t [image-name]:test .` — Build succeeds; note any new warnings in build output
2. `docker run --rm [image-name]:test [health-check-command]` — Container starts and basic command works
3. `docker image inspect [image-name]:test | jq '.[0].Config.ExposedPorts'` — Confirm expected ports are exposed

**After docker-compose changes:**
1. `docker compose config` — Validates the compose file syntax; zero errors
2. `docker compose config --services` — Lists all services; confirm expected services are present
3. `docker compose build --no-cache` — All services build successfully

**After .dockerignore changes:**
1. `docker build --no-cache -t [image-name]:test .` — Rebuild from scratch; confirm image size is as expected
2. `docker run --rm [image-name]:test ls /app` — Confirm the right files were included, sensitive files excluded

**Build verification:**
1. `docker compose up -d && sleep 5 && docker compose ps` — All services start and show "running" state
2. `docker compose logs` — No error messages in startup logs
3. `docker compose down` — Clean shutdown; all containers stop without errors
4. `docker compose up -d && docker compose exec [service] [health-check]` — Service responds correctly
