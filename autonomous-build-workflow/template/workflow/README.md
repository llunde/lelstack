# workflow/

Everything this project's agent workflow writes. The project's own code, tests and CI live outside this folder (WORKFLOW.md §2: application or workflow?). Process rules: `../AGENTS.md`; full spec: `WORKFLOW.md`.

```
README.md                 map of this folder: what each file is for and who writes it
WORKFLOW.md               copy of the workflow spec, SPEC.md (not read by `build`; `harness` reads its §0 and §6)
docs/                     WHAT to build; changed only via intake or by the human
  brief.md                the human's project description, verbatim, never edited
  00-overview.md          vision, locked decisions, domain model, risks, phase list
  NN-<phase>.md           one per phase, dependency order
  out-of-scope.md         fenced-off ideas + "Pulled into scope" record
stack.md                  stack profile: commands, layout, environment
harness.md                agent platform: tiers→models, sub-agents, parallel cap
decisions/index.md        decision table
decisions/D-NNN-slug.md   one file per settled fact
acceptance.md             human-only checks (A-NNN)
retro.md                  evidence-backed observations and improvement proposals (written by audits)
dashboard.base            Obsidian Bases status view (optional, WORKFLOW.md §7); .obsidian/ is local-only
plans/index.md            plan + phase status table
plans/archive.md          plan rows of closed phases
plans/NNN-slug.md         one brief per plan
progress/NNN-slug.md      one completion record per plan
progress/NNN-slug.X.md    slice note (parallel slices only; folded into the plan's note at close)
progress/complete.md      completion summary, written after the final audit
questions/index.md        question table
questions/archive.md      resolved question rows of closed phases
questions/Q-NNN-slug.md   one note per question
audits/YYYY-MM-DD-<scope>/   section-*.md + report.md
templates/                plan, progress, question, decision, audit, phase
commands/                 build (+ recover, integrate), audit, resolve, intake, change, harness
roles/                    planner, executor, reviewer, resolver, helper: one file per dispatched role
scripts/                  setup, check, check-full, run: quiet wrappers around the project's own commands (stack.md); helpers
scripts/git-setup         sets up the workflow repo (.git/workflow) and both ignore lists (WORKFLOW.md §2 Git)
scripts/save, drift       the two-repo save (AGENTS.md §6 Commits) and the drift check (recover.md step 5)
.logs/                    script logs and tier-2 evidence; local-only, tracked by neither repo
skills/workflow-review/   SKILL.md: the combined review used by every review step
skills/<name>/            domain skills copied from the skill library at bootstrap or intake, if any
```
