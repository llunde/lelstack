# recover

Role: Orchestrator. Run at the start of every `build` session and after any context compaction, before the loop (build.md §2). It resumes interrupted work from disk; where the repo and an index disagree, the repo wins.

0. **Harness and requirements.** Identify your harness. If harness.md has no section for it, stop (build.md §4, "Unknown harness"). Otherwise check that every required skill in that section is still available. If one is missing, stop (build.md §4) and report it. **Required integrations:** if harness.md lists one that the current phase (the first that isn't `closed`) needs, confirm its tools are reachable in this session; discovering them is not using them. If they aren't, stop (build.md §4, "Integration unavailable"). In-flight units started from another harness are resumed normally in step 3; their worktrees are plain git.
1. `git status`. If the main checkout has a **staged squash merge** for a unit still in "In flight", that unit already passed `check` and review in its worktree: finish integrate.md steps 5–6 (bookkeeping, commit, clean-up). Never reset the main checkout; it may hold uncommitted bookkeeping.
2. **In-progress plans** (in the main checkout; worktree units are step 3). Assume the worker died. Resume each at its first unfinished step, read from disk; where the repo and an index disagree, the repo wins:
   - plan file missing or half-written → a fresh Planner;
   - tasks not all ticked (read from the plan file for `sequential`, from the `## Tasks` in the progress or slice notes otherwise) → compare the ticked tasks with the diff, untick what doesn't hold, note the discrepancy in the progress note, and dispatch a fresh Executor for the rest;
   - all tasks ticked, `check` not yet passing → Verify (build.md §2 step 4);
   - `## Review` empty and `review:` isn't `skip` → Review (build.md §2 step 5);
   - `## Review` ends with `Deep review: yes` and no deep pass ran → the deep pass (build.md §2 step 5);
   - findings with Status exactly `open` → the fix round (build.md §2 step 5), one rung up if any of them is critical or high;
   - otherwise → Close (build.md §2 step 6).
3. **In-flight units.** Compare the "In flight" table with `git worktree list` and local unit branches. For each unit:
   - a worktree with a rebase in progress → `git rebase --abort`, then integrate from integrate.md step 1;
   - finished (all tasks in its note ticked) but not integrated → integrate it from the first unfinished integrate.md step;
   - partway through → dispatch a fresh Executor into the same worktree, or the same owned paths in a shared tree, to finish the remaining tasks;
   - a worktree or branch with no row, or a row with no worktree or branch → if it holds commits not in the integration branch, treat it as partway through; otherwise remove it (`git worktree remove`, `git branch -D`, `git worktree prune`) and drop the row.
4. **Unfinished audits.** An audit is finished only once its `(audit)` commit exists. For any other audit folder, resume at the first missing step, in audit.md order: section files, `section-cross-cutting.md`, `report.md`, plans (its "Plans spawned" section is empty), retro (its "Retro" section is empty), the commit.
5. **Drift check** (a Helper can gather the list). List commits whose subject has no workflow tag and whose SHA isn't in any plan's `adopts:`. If there are any, add a plan "Adopt off-loop changes" (`source: drift YYYY-MM-DD`) with Pri `next` that:
   - records what changed and adds decisions and doc updates;
   - runs `check`;
   - reviews those diffs for defects, turning findings into plans.
   Never revert.
6. For each acceptance row marked `fail` with no plan whose `source:` is that A-NNN, add a remediation plan (`source: A-NNN`) and write `→ plan MMM` in the row's Note. Give it Pri `next` if it breaks a constraint.
7. Run `check` once. If it fails with more than a few lines of output, dispatch a Helper for failure triage: "Read <log file>. Check stack.md 'Known environment symptoms' first. Return ≤10 lines: environment or code; failing tests; first error lines with file:line; failures grouped by likely cause. Don't fix anything." Diagnose environment vs code (AGENTS.md §7) before doing anything else.
8. **Unpushed commits.** If stack.md lists a remote and the integration branch is ahead of it, push (AGENTS.md §6).
