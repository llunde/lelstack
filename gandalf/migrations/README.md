# Migrations

`setup` runs `<n>.sh <instance folder>` for every schema number above the instance's `schema=` up to `SCHEMA` in `setup`, in order. A migration moves or rewrites `red-book/` files when the brain's layout changes. Rules for writing one:

- Bump `SCHEMA` in `setup` in the same change.
- Idempotent: running it twice does no harm.
- Never deletes content: move or rewrite it. `setup` commits the instance before and after, so the change is reviewable with `git diff HEAD~1` in the instance folder.
- POSIX sh, no dependencies beyond what `setup` uses.

There are none yet: schema 1 is the first layout.
