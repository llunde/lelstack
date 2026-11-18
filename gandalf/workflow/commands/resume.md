# gandalf-resume

Pick up a task a previous session left: after a crash, a usage limit, a hand-over, or the next day.

1. `workflow/GANDALF.md` §2 Start.
2. `workflow/scripts/sessions <project_dir>` lists this project's open sessions (not `done` or `abandoned`). With an argument, take the session whose file name contains it. Without one: if exactly one is open, take it; otherwise show them (task, step, branch, updated, next) and ask which.
3. Read the session file in full. The rules and the project note were just re-read in Start: they may have changed since the session ran, and they apply as they are now.
4. **Reconcile with git** (git beats the log): current branch against the session's `branch:`, commits on it since `base:`, uncommitted changes, whether it's pushed, whether a PR exists (`pr:`). Switch to the session's branch only with a clean tree; otherwise ask.
5. Show where it stands in at most five lines, then continue `workflow/commands/intake.md` at the session's `step:`. Redo a step that may have been cut off midway rather than trusting it. A `waiting` session was already compacted at wrap-up: continue at what `next:` says, from `## Hand-over` and the diff.
6. Add this harness's session id to `harness_session:` (keep the old ones). If the human wants the old conversation back, tell them how (Claude Code: `claude --resume <id>`).
7. Session abandoned for good: set `status: abandoned` with a one-line reason in `## Outcome`, and commit the instance (`workflow/GANDALF.md` §10).
