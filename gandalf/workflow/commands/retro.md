# gandalf-retro

Learn from finished work, so later runs go better. Three depths: light (automatic, end of every intake), project and instance (run by the human).

## Light (intake step 10)
At most three bullets, usually fewer, often none. Only what a future session would otherwise get wrong or waste time on.
- **Project facts** (a command that differs, a gotcha, a convention found, a review finding that keeps coming back): apply straight to the project note (`## Learnings`, or the section it belongs to), within its budget. Log `retro: <what changed>`.
- **Workflow lessons** (a step that wasted time, a default that was wrong, a skill that misbehaved, a question that should have been asked earlier): one `- gandalf: <lesson>` line each under `## Retro` in the session file. Write it so it holds for any project: no names, paths, domains, business terms or stack details that point to one client.
- Nothing worth keeping: write `## Retro` with `none`.

## Project (`/gandalf-retro` inside a repo)
1. `workflow/GANDALF.md` §2 Start. Read the project's `notes/`, and the sessions changed since `last_retro:` in the project note (all if empty): their Log, Review and Retro sections.
2. **Consolidate the note:** merge duplicates, check doubtful facts against the repo and fix or drop them, move detail to `notes/`, drop notes nothing links to and nobody needs. Back under budget.
3. **Patterns:** the same kind of review finding in several sessions → propose a project rule; commands that keep failing → fix the note; skipped findings that came back → say so.
4. Sessions left `active` or `waiting` that look finished or dead: ask, then set `done` or `abandoned`.
5. Show the proposed rules and ask; add the accepted ones as in `workflow/commands/rule.md`. Apply the note edits directly.
6. Set `last_retro:` to today, commit the instance (`workflow/GANDALF.md` §10) as `retro(<slug>)`, and report in at most ten lines.

## Instance (`/gandalf-retro instance`, anywhere below the root)
This is the only command that looks across projects, and it only ever sees the scrubbed `gandalf:` lines.
1. `workflow/GANDALF.md` §2 Start, steps 1 and 2. Read `red-book/gandalf.md`, `lessons.md` and `proposals.md`.
2. `workflow/scripts/retro-lines --since <last_retro from gandalf.md>` prints the `gandalf:` lines from every session updated since then, with the date, without project names. A session resumed after the last retro shows its older lines again: they may already be in `lessons.md`. Never open project or group files.
3. **Lessons:** a lesson seen in two or more sessions, or once at high cost, goes into `lessons.md` (merge with an existing one rather than adding). Drop lessons that no longer hold. At most 30 bullets.
4. **Proposals:** a lesson that needs gandalf itself to change goes into `proposals.md` as a new entry: the date, the file under `lelstack/gandalf/` and the exact edit (a short diff or the new text), the evidence (how many sessions, dates), `status: open`. Never edit lelstack: the human applies proposals there.
5. Run `workflow/scripts/leakcheck` on `lessons.md` and `proposals.md`; fix every hit.
6. Set `last_retro:` in `gandalf.md`, commit the instance as `retro(instance)`, and report the new lessons and proposals.
