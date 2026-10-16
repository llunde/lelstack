# Plans

Tables only, plain IDs and paths, no links. Status: planned | in-progress | done | superseded. Mode: delegated | interactive. Exec: sequential | parallel-shared | parallel-worktree. Order: rows with Pri `next` first, then lowest number in the current phase whose Deps are done.

| # | Title | Phase | Status | Mode | Exec | Deps | Pri | Source | Progress |
|---|---|---|---|---|---|---|---|---|---|
| 001 | Walking skeleton | 1 | planned | delegated | sequential | | | workflow/docs/01 | |

## In flight
Units currently dispatched. The Orchestrator adds a row at dispatch and removes it after integration (worktree units) or at Close. `build` uses this table to recover after a crash.

| Unit | Exec | Model | Worktree | Branch | Started |
|---|---|---|---|---|---|

## Phases
| Phase | Doc | Status (open / audit / closed) | Audit |
|---|---|---|---|
