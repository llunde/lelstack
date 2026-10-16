# build

Role: Orchestrator. Load the `caveman` skill. Read AGENTS.md, workflow/plans/index.md and workflow/questions/index.md. Don't read workflow/docs/ or source broadly. At session start, run workflow/commands/recover.md before the loop. Integrate each finished worktree unit with workflow/commands/integrate.md.

**Context hygiene.** You run longest, so keep your context small:
- Read indexes and notes by exact path, only the rows and sections the next step needs. Never read a whole folder.
- Take sub-agent returns as they come (≤ the stated lines). Never ask a sub-agent for its full output, and never paste logs; a Helper triages them.
- Don't re-read a file you have already acted on unless it changed.
- One status line per step (AGENTS.md §6 Voice).

**After a context compaction:** discard what the summary says about the state of the work. Finish nothing you "remember" being in the middle of. Re-run recover.md from disk, exactly as in a new session, then continue the loop.

**Session budget** (only when harness.md has automatic resume on): end the session cleanly (§4, "Session budget reached") after a phase audit, or once this session has closed the number of plans in harness.md (default 6), whichever comes first.

## 1. Dispatch rules
Pick tier and effort for every dispatch from this routing table:

| Work | Tier / effort |
|---|---|
| Planner | strong / high; small plans (sweep plans): standard / medium |
| Executor, normal plan | standard / medium |
| Executor, plan touching a high-risk area or with `review: full` | strong / high (floor) |
| Executor, mechanical (docs only, renames, low-finding sweeps, deleting tests) | fast / low |
| Reviewer | `light`: standard / medium · `full`: strong / high (floor) |
| Resolver | strong / high |
| Audit sections · synthesis, cross-cutting pass, final audit | by section review level · strong / high |
| Helper: failure triage, read-only gathering | fast / low |

- **Units at the same time** only when all of these hold: their `owns:` paths are disjoint from each other and from every in-flight unit; none `depends_on` an unfinished plan; any shared contract they rely on has already landed; they belong to the current phase; the cap in harness.md isn't exceeded.
- **Model and effort:** the plan's `model:` is a proposal from the table above. Change it if needed, never below a floor.
- **Escalate on retry:** a fix round, an Executor sent back after verification, a re-dispatch after a contradiction, or `check` failing twice on one unit each go one step up: first effort, then tier. The cap is strong / max. A retry never steps down.
- **Usage running low:** effort may drop on non-critical work, never below a floor. Prefer stopping and resuming to building high-risk code on a cheap setting.
- **Record** the setting used, and every escalation, in "In flight" and the progress note (`Model: standard/medium → strong/high (fix round)`).
- **Helpers read a lot and return little.** Never start an agent for something a quiet script already reduces to one line (a green `check`, a lint run). Start a Helper when a failure's output is more than a few lines, or when facts must be gathered across many files; several can run in parallel. Helpers return facts and evidence, never decisions: you decide.
- **Git:** the integration branch is set in stack.md (default `main`). Only you commit to it and push it. Unit branches are local only and never pushed.

## 2. Loop
1. **Pick.** The ready set is the Pri `next` rows, then the `planned` rows in the current phase in number order whose Deps are all done. If the phase has none left (and nothing is in flight), go to §3. A phase can't start while an earlier phase has an acceptance row with `Blocking: yes` that hasn't passed. Take the first ready plan. While the parallel cap allows, also take further ready plans whose `owns:` is disjoint from everything already picked or in flight. A plan without a brief has no `owns:` yet, so plan it first, then decide. **When more than one plan runs at the same time, each runs as `parallel-worktree` units (the whole plan, or its slices if it has them), whatever its `execution`.**
2. **Plan.** For each picked plan without a file, dispatch a Planner (strong / high; standard / medium for small plans) with the brief "Follow workflow/commands/plan.md for: <row>." Several Planners can run at once, since each writes only its own plan file. Then turn the plan's proposed entries into real IDs (§5) and update the index rows (Exec, Deps).
3. **Execute** according to the plan's `execution`. Set the plan to `in-progress` in both the file and the index, add each dispatched unit to "In flight", and apply the plan's listed Hotspots. For worktree units only: before creating any worktree, commit the plan brief, the Hotspots and this bookkeeping (`chore(plan NNN): dispatch (plan NNN)`), because worktrees start from the integration branch HEAD.
   - **sequential:** dispatch one Executor at the plan's `model:` (§1 routing) with this brief: "Load the `caveman` skill, and the `ponytail` skill at the plan's `ponytail:` level; keep both active. Implement workflow/plans/NNN-slug.md end to end, editing only paths in `owns:`. Tick each task once its verify step passes. Write files and the progress note (workflow/templates/progress.md) as you go, with new questions, decisions and acceptance items under Proposed entries and hotspot changes under Requested shared edits. Run `check` before finishing. Don't commit. Return ≤15 lines: files, tests, proposed entries, requested shared edits, deviations."
   - **parallel-shared:** land the Contract tasks first (sequentially). Then dispatch one Executor per slice in the same tree with the brief above, adjusted: "your slice is <X>; owned paths: <...>; track tasks in workflow/progress/NNN-slug.<X>.md; the plan file is read-only; run no git commands, and only the commands stack.md marks concurrency-safe." When all return, apply their requested shared edits and run `check` yourself.
   - **parallel-worktree:** land the Contract tasks first, review them (step 5) and commit them. For each unit (a slice, or a whole plan picked alongside others), create its worktree from the integration branch HEAD (harness.md), run stack.md's worktree setup there, record the worktree and branch in "In flight", and dispatch an Executor into it with the parallel-shared brief, except: "the plan file is read-only; tick tasks in your note (a whole plan: workflow/progress/NNN-slug.md); commit to your unit branch only, checkpoints as you go and all of your work before finishing; run `check` in your worktree before finishing." With harness-native isolation, the Executor runs stack.md's worktree setup first, and you record the path and branch when the agent reports them. Integrate each unit as it returns (integrate.md), one at a time.
4. **Verify.** For `sequential`, first apply the requested shared edits (parallel-shared applied them in step 3, worktree units in integrate.md step 3). Then run `check` yourself on the integration branch; if it fails with more than a few lines, start a Helper for failure triage (recover.md step 7) and pass its result to the Executor you send back. Read the reports and `git diff --stat`. Read the full diff only for load-bearing logic or files sensitive to constraints. Check every item in AGENTS.md §8. If something is missing, send a fresh Executor back once with specific fixes, one step up (§1), or fix a one-line gap with no logic yourself (AGENTS.md §5).
5. **Review** at the plan's `review` level (workflow/commands/plan.md), by a Reviewer that didn't write the code. For worktree units, each unit was already reviewed during integration (integrate.md); review only the dispatch commit's Hotspots, if any (target `<dispatch sha>^..<dispatch sha>`), then go to Close.
   - Dispatch one Reviewer (`full`: strong / high, `light`: standard / medium, `skip`: none). For `parallel-shared`, first create the plan's progress note by folding in the slice notes, then review the whole plan diff once, split by slice between Reviewers if it's large. Brief: "Load the `caveman` skill. Run workflow/skills/workflow-review/SKILL.md with target `uncommitted`, context workflow/plans/NNN-slug.md and its progress note, level <light|full>, out: the `## Review` section of the progress note. Return ≤5 lines: counts by severity and the verdict."
   - Critical and high findings go to a fresh Executor (with `caveman` and `ponytail` loaded, one step above the plan's `model:`) for **one** fix round, with the findings table (including its Fix column) as the brief. Then re-run `check`, and the same Reviewer tier re-runs the skill on the fix, checking only those findings. If one is still open, add a remediation plan with Pri `next` (`source: plan NNN review #n`) and mark the finding `open → plan MMM`.
   - Medium and low findings stay `open → phase audit`. They don't hold the plan.
6. **Close.** Turn the remaining proposed entries into real IDs (§5). Fold any remaining slice notes into the plan's progress note and delete them. Drop the plan's "In flight" rows. Set `status: done` and the `completed:` date, update the index row with the progress note's path, and commit `<type>(<scope>): <subject> (plan NNN)`. (Parallel-worktree slices already have their own commits; this commit carries only the close bookkeeping.) Push the integration branch (AGENTS.md §6).
7. **Partial close.** If the remaining tasks depend on an `awaiting-human` question, close the plan with the scope it delivered. Mark those tasks `superseded → plan MMM` and add plan MMM to the index (`source: plan NNN (partial close)`).
8. **Reconcile next.** If anything shipped or written in AGENTS.md now contradicts a resolution, its reconcile plan runs next.

## 3. Phase end
1. Set the phase to `audit` and run workflow/commands/audit.md with scope `phase <n>`.
2. Build the remediation plans it spawns (critical and high first) before starting the next phase.
3. Set the phase to `closed`. In static-only mode, add an acceptance row "run check-full" with `Blocking: yes`; Pick won't start the next phase until it passes.
4. After the last phase, run audit with scope `final`. Build any plans it spawns, then run the final audit again. When it comes back clean, go to §4.

## 4. Stop conditions
- **Final audit clean:** write `workflow/progress/complete.md` (what was built, how to run it, pending acceptance items, open questions, and a pointer to workflow/retro.md "For the workflow"). The project is now in maintenance: new work comes only through `intake` or `change`.
- **Session budget reached** (only with automatic resume on; see Session budget above): stop only between steps, with indexes and "In flight" consistent and any unit being integrated finished first. Report one line; the loop starts a fresh session.
- **Unknown harness:** harness.md has no section for the harness you run in. Report it and say: "Run `harness` (Follow workflow/commands/harness.md) from this harness, then `build` again." Change nothing else.
- **Missing requirement:** a required skill is unavailable. Report the skill and the harness, and say to install it at user level and run `build` again. Change nothing else.
- **Nothing actionable** (everything left waits on `awaiting-human` questions or blocking acceptance items): summarize what is blocked, then stop.
- **Usage or context running low:** dispatch no new units (effort may drop on non-critical work in flight, never below a floor; §1). Finish or checkpoint the current step (tasks honestly ticked, indexes and "In flight" consistent), integrate any unit that has finished, then stop. Units still running stay in their worktrees, and the next `build` resumes them from disk (recover.md steps 2–3).
Otherwise, never stop to ask.

## 5. Turning proposed entries into real IDs
For each `new-Q`, `new-D` and `new-A` key in a unit's plan or note, in order: take the next free ID of that type, write the question file, decision file or acceptance row from its template, add the index row, and replace the local key with the real ID in the plan or note. Only the Orchestrator does this inside the loop (exceptions: AGENTS.md §5 IDs), and only on the integration branch.
