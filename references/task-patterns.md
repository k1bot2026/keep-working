# Task Patterns Reference

Task generation templates organized by agent role. The lead orchestrator uses this document when generating new tasks for agents during each CYCLE DONE procedure. Select templates appropriate to the current project type and remaining work. Replace `[placeholder]` values with project-specific details before writing to the backlog.

---

## Developer

Use for backend, frontend, or full-stack implementation work. Prefer specific, testable tasks over broad ones.

1. Write unit tests for `[module/function]` covering the happy path, null inputs, and boundary conditions
2. Add input validation to `[endpoint/function]` — reject malformed requests with descriptive error messages and appropriate HTTP status codes
3. Refactor `[file/module]` to eliminate code duplication — extract shared logic into `[helper/utility name]`
4. Implement retry logic with exponential backoff for `[external API/service]` calls — max 3 attempts, log each retry
5. Add structured logging to `[module]` — log entry/exit for key operations, include request IDs and timing
6. Cache the result of `[expensive operation]` using `[cache strategy]` — TTL of `[duration]`, invalidate on `[event]`
7. Migrate `[feature/table]` from `[old approach]` to `[new approach]` — write migration script and rollback procedure
8. Add error handling to `[function]` — catch `[specific error types]`, transform to domain errors, never leak stack traces
9. Extract configuration from hardcoded values in `[file]` — move to environment variables with documented defaults
10. Optimize `[query/algorithm]` in `[file]` — current complexity is `[O(n)]`, target `[O(log n)]` or better
11. Implement rate limiting on `[endpoint/route]` — `[N]` requests per `[window]` per `[IP/user/key]`
12. Add database connection pooling to `[data layer]` — pool size `[N]`, timeout `[ms]`, handle pool exhaustion gracefully
13. Write integration test for the `[feature]` flow — covers `[step 1]` → `[step 2]` → `[expected state]`
14. Replace `[deprecated API/library]` in `[file]` with `[replacement]` — update all call sites and tests
15. Implement `[design pattern]` for `[component/module]` — document the pattern choice in a code comment
16. Add pagination to `[list endpoint]` — cursor-based preferred, return `next_cursor` and `total_count`
17. Sanitize and escape all user-controlled inputs in `[module]` before `[database write/HTML render/shell exec]`
18. Implement `[webhook/event]` handler for `[external service]` — verify signature, process idempotently, return 200 fast
19. Write a background job for `[long-running task]` — use `[queue system]`, handle failures, emit completion event
20. Consolidate `[N] duplicate implementations` of `[utility]` across `[files]` into a single shared module

---

## Tester

Use to increase coverage, harden edge cases, and verify non-functional requirements. Tasks should reference specific files or modules.

1. Write edge case tests for `[function]` — empty array, single element, max length `[N]`, negative values, and `NaN`
2. Add error path tests for `[module]` — network timeout, 401 unauthorized, 500 server error, malformed JSON response
3. Write a performance test for `[endpoint]` — must respond in under `[Nms]` at `[N]` concurrent users
4. Add accessibility audit tests for `[page/component]` — verify heading hierarchy, landmark roles, and color contrast
5. Create regression tests for bug `[ticket/description]` — reproduce the original failure, then verify the fix
6. Write snapshot tests for `[component]` — capture baseline render for `[props combination]`
7. Write API contract tests for `[endpoint]` — verify response schema matches OpenAPI spec in `[path/to/spec]`
8. Add cross-browser tests for `[feature]` — verify in Chrome, Firefox, and Safari using `[test tool]`
9. Write a memory leak test for `[component/process]` — mount/unmount `[N]` times, assert heap does not grow unboundedly
10. Validate all `[form/API]` inputs — test SQL injection patterns, XSS payloads, oversized values, and Unicode edge cases
11. Add integration tests for `[service]` with a real `[database/redis/queue]` using `[testcontainers/docker-compose]`
12. Write tests for all error messages in `[module]` — assert each error includes a human-readable message and an error code
13. Add load test script for `[critical path]` — `[N]` virtual users ramping over `[duration]`, assert P99 latency under `[Nms]`
14. Test the retry behavior in `[module]` — mock `[upstream service]` to fail `[N]` times, verify recovery on attempt `[N+1]`
15. Write end-to-end test for `[user flow]` — from `[entry point]` through `[action]` to `[expected outcome]`
16. Add boundary tests for `[numeric field]` — test values at min `[N]`, max `[N]`, min-1, max+1, and zero
17. Verify idempotency of `[operation]` — call it `[N]` times with the same input, assert state is unchanged after the first
18. Test authentication guards on `[route set]` — unauthenticated, wrong role, expired token, and valid token
19. Write fuzz tests for `[parser/deserializer]` — use `[tool]` to generate malformed inputs, assert no panics
20. Add test coverage report step to CI — fail build if coverage drops below `[N]%` on `[module]`

---

## Designer

Use for UI polish, accessibility compliance, responsive layout, and visual feedback states. Reference specific components or pages.

1. Make `[component]` fully responsive — test at 320px, 768px, 1024px, and 1200px breakpoints, no horizontal scroll
2. Add loading skeleton for `[data-fetching component]` — match the shape of the loaded content, animate with shimmer
3. Add error state UI to `[form/component]` — inline field errors, summary banner, focus first error on submit
4. Implement hover and focus styles for all interactive elements in `[section]` — visible outline, no outline suppression
5. Audit color contrast in `[component/page]` — all text must meet WCAG 2.1 AA (4.5:1 normal, 3:1 large text)
6. Add CSS transition animations to `[interaction]` — `[N]ms` duration, ease-in-out, respect `prefers-reduced-motion`
7. Design and implement empty state for `[list/dashboard widget]` — illustration or icon, heading, and CTA
8. Implement full keyboard navigation for `[component]` — tab order logical, Enter/Space activate, Escape dismisses
9. Add `aria-label`, `aria-describedby`, and `role` attributes to all interactive elements in `[component]`
10. Audit and normalize typography scale in `[section]` — use CSS custom properties for font sizes, line heights, and weights
11. Create dark mode variants for `[component set]` — use `prefers-color-scheme` media query and CSS custom properties
12. Add form validation feedback to `[form]` — real-time validation after blur, clear errors when user corrects input
13. Implement sticky header behavior for `[nav component]` — compact on scroll, smooth transition, does not jump on mobile
14. Design touch targets for mobile — all interactive elements in `[component]` minimum 44x44px tap area
15. Add print stylesheet for `[page]` — hide navigation and sidebars, expand collapsed content, use black ink
16. Create `[N]` size variants for `[component]` — small/medium/large — using CSS custom property overrides
17. Implement focus trap for `[modal/drawer/dialog]` — Tab cycles within, Escape closes, focus returns to trigger
18. Add visual progress indicator for `[multi-step flow]` — show current step, completed steps, and remaining steps
19. Normalize spacing in `[layout]` — replace hardcoded pixel values with spacing scale tokens from design system
20. Audit and fix z-index stacking context issues in `[overlay components]` — document the z-index scale

---

## Docs Writer

Use for inline documentation, README improvements, API documentation, and developer guides.

1. Add JSDoc/docstring comments to all exported functions in `[file]` — include `@param`, `@returns`, and `@throws`
2. Write a README section for `[feature/module]` — purpose, usage example, configuration options, and known limitations
3. Document the REST API endpoint `[METHOD /path]` — request/response schema, auth requirements, error codes, example curl
4. Write a `CHANGELOG.md` entry for version `[N.N.N]` — group changes as Added, Changed, Deprecated, Removed, Fixed, Security
5. Document all environment variables in `.env.example` — include type, required/optional, default value, and description
6. Write a troubleshooting guide for `[common error/setup problem]` — symptoms, cause, step-by-step resolution
7. Add code examples to the `[feature]` documentation — working snippets that can be copy-pasted and run immediately
8. Write an Architecture Decision Record (ADR) for `[decision]` — context, options considered, decision, and consequences
9. Write a contributing guide `CONTRIBUTING.md` — dev setup, branching strategy, PR process, and code style requirements
10. Document the data model for `[entity]` — field names, types, constraints, relationships, and example JSON
11. Write a `SECURITY.md` policy — how to report vulnerabilities, response timeline, and scope
12. Add inline comments to `[complex algorithm/regex/query]` in `[file]` explaining the logic step by step
13. Write a migration guide from `[version/approach]` to `[version/approach]` — breaking changes and upgrade steps
14. Document the error codes returned by `[module/API]` — code, message, cause, and remediation for each
15. Write `GETTING_STARTED.md` — clone → install → configure → run in under 5 commands, verified on a fresh machine
16. Add type documentation to all interfaces and types in `[file]` — describe each property and its valid values
17. Document the testing strategy for `[project/module]` — what is tested, how, and what is intentionally excluded
18. Write deployment documentation for `[environment]` — prerequisites, steps, rollback procedure, and health checks
19. Update `package.json` / `pyproject.toml` description, keywords, and homepage fields with accurate information
20. Create a glossary of domain terms used in `[project]` — define each term as used within this specific codebase

---

## Content Writer

Use for marketing copy, SEO optimization, UX writing, and structured content. Reference specific pages or sections.

1. Write a `<title>` tag and `<meta name="description">` for `[page]` — title under 60 chars, description under 160 chars, include primary keyword
2. Add `application/ld+json` schema markup to `[page]` — use `[Organization/Product/Article/FAQ]` schema type
3. Rewrite the H1 heading on `[page]` — lead with user benefit, include primary keyword naturally, under 70 characters
4. Write error messages for all validation states in `[form]` — specific, actionable, non-blaming, under 15 words each
5. Write the 404 page copy — acknowledge the error without blame, suggest 3 helpful next steps, include search
6. Add descriptive `alt` attributes to all images on `[page]` — describe content and function, empty alt for decorative images
7. Write the breadcrumb labels for `[section]` — concise, match the page H1, capitalize consistently
8. Write the footer legal copy — copyright notice, privacy policy link, terms link, and cookie policy link
9. Rewrite the primary navigation labels for `[site section]` — 1-2 words, parallel structure, verb-noun or noun format
10. Write meta tags for Open Graph and Twitter Card on `[page]` — `og:title`, `og:description`, `og:image`, `twitter:card`
11. Write the onboarding empty state copy for `[feature]` — explain what will appear here, one CTA to get started
12. Audit and rewrite button labels on `[page]` — replace "Submit" / "Click here" with specific action verbs
13. Write tooltip copy for all help icons in `[UI section]` — under 20 words, answer "what does this do?"
14. Write `<link rel="canonical">` and sitemap entries for `[page set]`
15. Add `hreflang` attributes to `[page]` for languages `[en/fr/de/...]`
16. Write the confirmation page copy after `[form/purchase/signup]` — confirm success, next step, support contact
17. Audit heading hierarchy on `[page]` — one H1, logical H2/H3 nesting, no skipped levels
18. Write the cookie consent banner copy — explain what cookies are used for, provide Accept/Decline options clearly
19. Write accessible form labels and placeholder text for `[form]` — labels describe the field, placeholders give examples only
20. Create a content brief for `[blog post/landing page]` — target keyword, search intent, outline, word count, and CTA

---

## Creative

Use for visual assets, diagrams, design system artifacts, and structured visual guides.

1. Create an SVG icon for `[concept/action]` — 24x24px viewBox, single color fill, no hard-coded colors (use `currentColor`)
2. Draw a system architecture diagram in Mermaid — show all services in `[system]`, their connections, and data flow direction
3. Create a Mermaid sequence diagram for `[user flow/API flow]` — actor → system → service interactions with response labels
4. Generate a color palette for `[project/brand]` — primary, secondary, accent, success, warning, error, and neutral scale
5. Define design tokens as CSS custom properties — colors, spacing (4px base), type scale, border radius, shadow levels
6. Create a placeholder hero image using SVG — `[NxN]px, gradient background in `[colors]`, centered `[project name]` wordmark
7. Draw a flowchart in Mermaid for `[decision process/algorithm]` — decision diamonds, process rectangles, start/end terminals
8. Create an entity relationship diagram in Mermaid for `[database schema]` — all tables, primary keys, foreign keys, cardinality
9. Design a component visual guide — show `[component]` in all states: default, hover, focus, active, disabled, error
10. Create a spacing and grid reference visual — illustrate the `[N]px base grid` and all spacing scale values
11. Design a typography specimen — show all type styles (H1–H6, body, caption, code) at their defined sizes and weights
12. Create a Mermaid Gantt chart for `[project phase]` — tasks, durations, dependencies, and milestone markers
13. Generate a SVG illustration for `[empty state/onboarding/error page]` — simple, friendly, matches brand colors
14. Create a `[light/dark]` mode color mapping table — semantic token names mapped to their light and dark hex values
15. Draw a C4 context diagram in Mermaid for `[system]` — users, external systems, and the system boundary
16. Create placeholder avatar SVGs in `[N]` sizes — neutral silhouette, configurable background color via CSS variable
17. Design a status badge component in SVG — variants for `[active/inactive/pending/error]`, legible at 12px font size
18. Create a visual sitemap diagram — all pages, their hierarchy, and navigation paths for `[site/app]`
19. Generate favicon assets — `favicon.svg` (scalable), reference sizes needed at 16px, 32px, 180px
20. Design a loading spinner SVG — pure CSS animation, `currentColor` stroke, accessible with `aria-label` and `role="status"`
