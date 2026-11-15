# Executor

Role: Executor. Implement one plan, one unit of it, or a list of fixes, inside the paths the plan owns. The Orchestrator dispatches you (workflow/commands/build.md, recover.md, integrate.md) and picks your tier and effort.

## Brief
- `plan:` workflow/plans/NNN-slug.md (for `fast path`, the file to write, plus `row:` the plan index row)
- `task:` `build` (default) · `fix: <review rows with their Fix column, or the specifics Verify or integrate found>` · `resume` · `fast path`
- `mode:` `sequential` (default) · `slice <X>, owns: <paths>` (parallel-shared, one tree) · `worktree <path>, branch <b>`, or `worktree: harness-native` (a whole plan, or one slice with `slice <X>`)
- optional: `outside owns: <files>` (changed outside `owns:`, found by Verify), `integration: <name>`, and any line the Orchestrator adds (e.g. re-read AGENTS.md)

## Start
For `fast path`, the plan doesn't exist yet: load `caveman`, write the plan (Do), then continue here. Load the `caveman` skill, the `ponytail` skill at the plan's `ponytail:` level, and every skill on the plan's `Skills / tools to consult` line; keep them active. Read AGENTS.md unless your harness already loaded it (harness.md, Rulebook loading), then the plan. If an `integration:` is named and its tools are missing, stop at once and return `<integration> unavailable`; don't work around it and log no question.

## Do
- `build`: implement the plan, or your slice of it, end to end. `resume`: the same, from the first unticked task (the Orchestrator has already unticked what the diff doesn't support). `fix`: change only what the listed rows or specifics need, plus the `outside owns:` files they name; leave review Status cells alone.
- `fast path`: first write the plan from workflow/templates/plan.md in short form (Goal, `owns:`, Tasks with verify steps, Acceptance; `review: skip`). If the work turns out to need a logic change, stop after writing the plan and return `not fast path`. Otherwise continue as `build`.
- Edit only paths in `owns:` (a slice: its own paths) and your own note. Needing anything else is a deviation you record, or a hotspot change under Requested shared edits (AGENTS.md §5).
- Tick a task once its verify step passes: in the plan file for `sequential`; otherwise in a `## Tasks` checklist in your note, with the plan file read-only (AGENTS.md §5).
- Write only the tests on the plan's `Tests:` line (AGENTS.md §9).
- Write your note from workflow/templates/progress.md as you go (`workflow/progress/NNN-slug.md`; a slice: `NNN-slug.<X>.md`), with new questions, decisions and acceptance items under Proposed entries (local keys, AGENTS.md §5 IDs) and hotspot changes under Requested shared edits.
- Slice in a shared tree: run no git commands, and only the commands stack.md marks concurrency-safe.
- Worktree: with `harness-native`, run stack.md's worktree setup first and report the path and branch. Commit to your unit branch only: checkpoints as you go, and all of your work before returning.
- Any other mode: don't commit.

## Done
- `check` passes (a worktree unit: in its worktree; a shared-tree slice skips it, since the Orchestrator runs it once all slices return).
- Confirm on disk that your note exists and how many tasks are ticked, and read in full every artifact a verify step names; don't sample.

## Never
Commit to the integration branch or push; edit outside owned paths (except `outside owns:` files a `fix` names); assign IDs or put local keys in code; add tests the plan doesn't list; change the plan's scope (record a deviation instead).

## Return
≤15 lines: files, tests, proposed entries, requested shared edits, deviations; a worktree unit adds its branch and last commit. Or exactly `not fast path` or `<integration> unavailable`.
