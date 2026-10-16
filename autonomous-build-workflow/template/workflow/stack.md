# Stack profile — <project>

Chosen at bootstrap (D-001). Plans and done gates refer to the entry points below, never to raw tool commands. When anything here changes, update it in the same commit.

## Stack
- Language / runtime / framework (version floor): <...>
- Target platform(s): <...>
- Build / package tool: <...> · Test framework: <...> · Lint / format: <...>

## Entry points
| Name | Command | Does | Required for |
|---|---|---|---|
| setup | `scripts/setup` | install or verify toolchain and dependencies | a new machine |
| check | `scripts/check` | build, lint, critical tests and the e2e smoke subset; exits non-zero on failure | every plan |
| check-full | `scripts/check-full` | everything in `check` plus every e2e flow | phase end, final audit |
| run | `scripts/run` | start the app or service locally | tier 2, README |

Scripts detect their environment (toolchain location, versions) themselves. They are **quiet**: on success, only a one-line summary (e.g. `check: pass, 142 tests, 38s`); on failure, only the failing items (test names, first error lines) plus the summary. The full log goes to a gitignored file named in the summary, for when the detail is needed.

## Layout
<directories and what lives where; where the testable core and the shell are>

## E2E
- Outermost headless layer here: <e.g. HTTP API with real DB · CLI · app core with real persistence, no UI>
- Smoke subset (in `check`): <core flows>
- Mocked boundaries only: <third-party APIs, clock, ...>

## Environment
- Verified toolchains / machines: <...>
- Can verify here: <build, test, run, network, ...>
- Cannot verify here (→ tier 3): <device, real hardware, signing, live credentials, visual judgment, ...>
- Mode: normal | static-only
- Tier-2 tools available: <none | e.g. curl probe, UI test runner, screenshot capture>

## Git
- Integration branch: `main` <or the branch the human chose>
- Remote: <origin | none> · Push: at plan close (AGENTS.md §6)

## Concurrency
- Conflict hotspots (Orchestrator-only files): <e.g. *.csproj / *.sln, package.json + lockfile, Package.swift, DI registration, route table>
- Concurrency-safe commands (allowed for `parallel-shared` workers): <none | e.g. a single test file run that writes no shared build output>
- Worktree setup (run in a fresh worktree before work starts): <e.g. `scripts/setup`; dependency install; isolated build output dir>

## Known environment symptoms
| Symptom | Cause | Fix |
|---|---|---|
