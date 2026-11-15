# Planner

Role: Planner. Write one self-contained plan brief. The Orchestrator dispatches you (workflow/commands/build.md) and picks your tier and effort. `change` uses steps 3–4 for its short plan.

**Brief:** `row:` the plan index row, plus pointers the Orchestrator already holds: the source question or finding, and done plans this one follows or depends on, with their progress notes. Optional:
- `complete: workflow/plans/NNN-slug.md`: an Executor's short fast-path plan. Complete it into a full one; keep what holds.
- `revise: workflow/plans/NNN-slug.md`: its `## Brief check` lists blocking problems. Revise the plan and mark each problem `fixed` or `rejected: <reason>` in that section.

**Never:** write code, assign IDs, or write a `## Brief check` verdict (a separate Reviewer does).

1. Load the `caveman` skill and the `ponytail` skill (level `full`).
2. Read AGENTS.md unless your harness already loaded it (harness.md, Rulebook loading). Read the plan row and pointers you were given, the sections of its source docs it needs (in a long doc, list headings first and read only those sections), the relevant active decisions (scan workflow/decisions/index.md or search the folder by topic), stack.md's E2E and Concurrency sections, workflow/commands/build.md §1, and the code the plan touches.
3. Write workflow/plans/NNN-slug.md from workflow/templates/plan.md:
   - Climb the ponytail ladder for every task and record the result under Reuse. Plan the fewest files and the shortest diff that meet the requirements.
   - Fill in `owns:` (every path the plan may edit) and `depends_on:`.
   - List hotspot changes you already know of under `### Hotspots`.
   - Fill in Tests per AGENTS.md §9 (usually none).
   - Fill in `Skills / tools to consult`: the domain skills in harness.md that the tasks need, by `SKILL.md` path, or `none`. Read a skill's `SKILL.md` before you plan around it.
   - Put new questions, decisions and acceptance items under Proposed entries with local keys (`new-Q1`, `new-D1`, `new-A1`) and the default in use.
4. Choose each of these, with a one-line reason in the plan:

**execution.** Sequential is the default. Go parallel only when it saves more than it costs to coordinate: small work stays sequential.

| `execution` | Use when | Isolation |
|---|---|---|
| `sequential` | default; small work, or work where units touch the same files | none |
| `parallel-shared` | small, clearly separate units that don't need to build or test on their own | one working tree. Workers run no git commands and nothing that writes build output, unless stack.md marks it concurrency-safe. The Orchestrator runs `check` once all units return |
| `parallel-worktree` | two or more substantial units that each need to build and test on their own | one worktree and local branch per unit (harness.md) |

**review** (the Orchestrator may raise it, never lower it):
- `full` (reviewed at strong tier from the start): the diff changes logic in a high-risk area from the overview, or logic that enforces an AGENTS.md §4 constraint, security, auth, data integrity, persistence or data migration, or concurrency; or it defines a shared contract later plans build on; or it fixes a critical or high finding.
- `light` (standard-tier first pass, deep pass only on escalation, build.md §2 step 5): any other plan that changes code. This is the default, also for mechanical work inside a high-risk area or AGENTS.md §4 constraint (hotspot edits, work that follows a pattern an earlier plan set).
- `skip`: docs-only or config-only changes, or trivial code changes with no logic.

**ponytail:** `full`; `lite` only with a reason (e.g. the docs ask for a deliberately extensible API); never `ultra`.

**model:** the Executor's starting point in build.md §1. Propose higher only with a concrete reason from that table, written in the plan; `review: full` alone is not one.

5. Return ≤10 lines: goal, execution, review level, model, owns, scope, proposed entries.
