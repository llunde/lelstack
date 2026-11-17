# Migrations

`setup` runs `<n>.sh <instance folder>` for every schema number above the instance's `schema=` up to `SCHEMA` in `setup`, in order. A migration moves or rewrites `red-book/` files when the brain's layout changes. Rules for writing one:

- Bump `SCHEMA` in `setup` in the same change.
- Idempotent: running it twice does no harm.
- Never deletes content: move or rewrite it. `setup` commits the red book before migrating (and stops if it can't), then commits the migration on its own, so `git show` on that commit in the instance folder reviews just the migration.
- POSIX sh, no dependencies beyond what `setup` uses.

There are none yet: schema 1 is the first layout.
