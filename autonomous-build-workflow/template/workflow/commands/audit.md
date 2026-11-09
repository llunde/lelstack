# audit

Role: Orchestrator for Reviewers. Load the `caveman` skill. Source code is read-only. Write only to workflow/audits/<date>-<scope>/, workflow/plans/, workflow/questions/, the indexes, workflow/retro.md, and the Status column of plan-review findings in progress notes. A final audit may also fix docs (README, links) directly.

1. **Setup.** Create the folder. Record HEAD as `audited_through`. The scope is everything since the previous audit's `audited_through`, plus the phase's plans and any adopted commits. Run `check-full` and record the result as the gate (failure triage by a Helper if it fails). Collect every `open → phase audit` finding from the `## Review` sections of every progress note whose plan closed in scope. They go into the report as findings without being reviewed again, and are marked there `→ audit <date> F<n>`.
2. **Sections.** Split the scope into non-overlapping sections (by module or layer). Dispatch Reviewers in parallel (within the read-only cap in harness.md). Each Reviewer runs the `workflow-review` skill with the section's paths as the target, level `full` for sections holding a high-risk area from the overview and `light` otherwise, and out `section-<name>.md`. It adds a "Read fully / not read" list, and returns ≤5 lines. The skill's lenses cover correctness, safety, scale, tests, speed and lean code; the cross-cutting pass below covers what spans sections.
3. **Cross-cutting pass** (you, or one Reviewer at strong / high), written to `section-cross-cutting.md`:
   - constraints that span modules
   - duplication across sections
   - earlier remediations still holding
   - tests that don't meet AGENTS.md §9 (no flow, not critical, not a regression), or duplicate each other: deletion candidates, grouped in one plan
   - governance: link policy (AGENTS.md §6 Links: no links to hubs, none in indexes); untagged commits; docs drift (README, stack.md, decisions vs code; docs vs shipped scope); index consistency, including decision status and supersede links; pending acceptance count
4. **Synthesize** `report.md` from the template, leaving "Plans spawned" and "Retro" for steps 5 and 6. State coverage gaps plainly. Sections that weren't covered go first in the next audit.
5. **Plans.**
   - One plan per critical or high finding (or tight cluster of them), with Pri `next`.
   - Medium findings grouped by area.
   - All low findings in one sweep plan.
   - Governance findings in one docs plan.
   Number them after the last plan, with `source: audit <date> F<n>`. Product ambiguities become questions with defaults. Fix index and link bookkeeping directly. Fill in the report's "Plans spawned".
6. **Retro.** Start Helpers to gather the numbers (fix rounds, escalations, model mix, repeats, overturned defaults), then judge them yourself. Read only what's on disk for this scope: progress notes and their Review sections, this report, Resolver runs and re-dispatches, questions resolved since the last audit. Append observations to workflow/retro.md:
   - **escape:** a critical or high finding in this audit that its plan's review missed (name the plan, its review level, the Executor's and Reviewer's tier/effort, and the finding).
   - **repeat:** the same kind of finding, deviation or question in 3 or more plans.
   - **friction:** escalations (which tier/effort failed, which one fixed it), a plan that needed more than one fix round, merge conflicts or contradictions, plans well over budget.
   - **model mix:** one line per audit: dispatches by role and tier/effort (from progress notes' `Model:` lines), how many started above the build.md §1 starting point or escalated, deep passes, brief checks that found a blocking problem, and any escape on work that stayed at standard tier.
   - **default-overturned:** a question where the human chose something other than the default in use.
   - **skill:** a multi-step procedure done by hand 3 or more times, or a recurring finding type a skill could prevent. Propose the skill's name, what it would do, and the evidence. Never create or install one.
   Then propose:
   - Project-level changes (an AGENTS.md rule, a stack.md symptom, a higher review level for an area): one question note each, `needs: workflow`, with a recommendation; the default in use is "no change".
   - Spec-level changes (would help any project): a line under "For the workflow".
   Never loosen a gate (definition of done, review levels, required skills) by default, and never apply a proposal yourself. Fill in the report's "Retro".
7. **Commit** `docs(audit): <scope> findings (audit)`. Then return to `build`, or push (AGENTS.md §6) and stop if this audit was run on its own.

## Additional checks for scope `final`
- **Retro summary:** rank the "For the workflow" lines by evidence and put the top items in `report.md`. They're the input for the next revision of the workflow.
- **Feature audit:** Helpers gather the evidence in parallel (one per phase doc); you judge it. A table of every Scope-In and Acceptance item in workflow/docs/ (plus decisions that changed them), each marked implemented / partial / missing with evidence (a file or a test). Partial and missing items become plans.
- **Quality:** `check-full` clean with no new warnings; lint, format and type checks pass; no leftover TODOs, commented-out code or debug logging; comments follow AGENTS.md §6 (none that restate code, none that reference plans, findings, questions, decisions or commits); no hardcoded secrets or config that belongs in the environment.
- **README:** what it is; Run locally (prerequisites with versions, setup, config and env, exact commands); Install / deploy for real use. Run every command to confirm it works, and don't invent steps.
- **Shippability, where it applies:** error handling at boundaries; config and env handling; `.gitignore` covers build output and secrets; license and version; no broken doc links.
- **Scope discipline:** recommend minimal root-cause fixes. Don't refactor working code unless it is part of a real gap.
