# plan

Role: Planner. Write one self-contained plan brief. Never write code or assign IDs.

1. Load the `caveman` skill and the `ponytail` skill (level `full`).
2. Read AGENTS.md, the plan row you were given, its source docs, the relevant active decisions (scan workflow/decisions/index.md or search the folder by topic), stack.md's E2E and Concurrency sections, the routing table in workflow/commands/build.md §1, and the code the plan touches.
3. Write workflow/plans/NNN-slug.md from workflow/templates/plan.md:
   - Climb the ponytail ladder for every task and record the result under Reuse. Plan the fewest files and the shortest diff that meet the requirements.
   - Fill in `owns:` (every path the plan may edit) and `depends_on:`.
   - List hotspot changes you already know of under `### Hotspots`.
   - Fill in Tests per AGENTS.md §9 (usually none).
   - Put new questions, decisions and acceptance items under Proposed entries with local keys (`new-Q1`, `new-D1`, `new-A1`) and the default in use.
4. Choose each of these, with a one-line reason in the plan:

**execution.** Sequential is the default. Go parallel only when it saves more than it costs to coordinate: small work stays sequential.

| `execution` | Use when | Isolation |
|---|---|---|
| `sequential` | default; small work, or work where units touch the same files | none |
| `parallel-shared` | small, clearly separate units that don't need to build or test on their own | one working tree. Workers run no git commands and nothing that writes build output, unless stack.md marks it concurrency-safe. The Orchestrator runs `check` once all units return |
| `parallel-worktree` | two or more substantial units that each need to build and test on their own | one worktree and local branch per unit (harness.md) |

**review** (the Orchestrator may raise it, never lower it):
- `full` (strong tier): the plan touches a high-risk area from the overview, an AGENTS.md §4 constraint, a conflict hotspot or shared contract, persistence or data migration, or security; or it fixes a critical or high finding.
- `light` (standard tier): any other plan that changes code. This is the default.
- `skip`: docs-only or config-only changes, or trivial code changes with no logic.

**ponytail:** `full`; `lite` only with a reason (e.g. the docs ask for a deliberately extensible API); never `ultra`.

**model:** the Executor rows of the routing table in build.md §1, respecting its floors.

5. Return ≤10 lines: goal, execution, review level, model, owns, scope, proposed entries.
