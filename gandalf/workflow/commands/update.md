# gandalf-update

Apply the current `lelstack/gandalf` to this instance. `workflow/` is replaced; `red-book/` is kept and migrated if its layout changed.

1. Find the instance as `workflow/GANDALF.md` §2 step 1 does (only `root`, `gandalf`, `version`, `source` are needed). Read `instance.conf`.
2. If `source` doesn't exist or has no `setup` script, ask the human for the path to their `lelstack/gandalf` folder.
3. Show: installed `version` → the source's `VERSION`. If the source is a git repo, list what changed: `git -C <source> log --oneline <source_commit>..HEAD -- .` (skip if `source_commit` is `unknown`).
4. `git status --short -- workflow` inside the instance folder: local edits to workflow files get replaced (setup commits a snapshot first, so they stay in the instance's history). Show them and ask before continuing.
5. Run `<source>/setup <root>`. It must end with `setup: ok`; otherwise report its output and stop.
6. Report in at most five lines: old → new version, migrations it ran, stubs it installed or skipped. If a command file changed and a gandalf command is in progress in this session, re-read that file before its next step.
