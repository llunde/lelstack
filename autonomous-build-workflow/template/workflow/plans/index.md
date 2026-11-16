# Plans

Tables only, plain IDs and paths, no links. Status: planned | in-progress | done | superseded. Exec: sequential | parallel-worktree. Order: rows with Pri `next` first, then lowest number in the current phase whose Deps are done. Rows of closed phases move to `archive.md` (build.md §3): a plan missing here is there, and finished. Read it only when a step needs an old row.

| # | Title | Phase | Status | Exec | Deps | Pri | Source | Progress |
|---|---|---|---|---|---|---|---|---|
| 001 | Walking skeleton | 1 | planned | sequential | | | workflow/docs/01 | |

## In flight
Units currently dispatched. The Orchestrator adds a row at dispatch and removes it after integration (worktree units) or at Close. `build` uses this table to recover after a crash.

| Unit | Exec | Model | Worktree | Branch | Started |
|---|---|---|---|---|---|

## Phases
| Phase | Doc | Status (open / audit / closed) | Audit |
|---|---|---|---|
