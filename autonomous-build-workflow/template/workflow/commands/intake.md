# intake

Use this for new features, batches of improvements, or bug reports too large for `change`.

1. Load the `caveman` skill (questions to the human stay in full sentences). Read AGENTS.md, the overview, out-of-scope, the latest phase doc and the plans index.
2. Interview the human one question at a time, with a recommendation each time. Look up facts in the code yourself. Pin down: the problem, the desired behavior, scope in and out, acceptance, constraints affected, and anything withdrawn.
3. Write `workflow/docs/NN-<name>.md` from workflow/templates/phase.md, including Provenance and Withdrawn.
   - Update the overview's phase list.
   - Update out-of-scope "Pulled into scope" where it applies.
   - Change AGENTS.md §4 only with explicit human confirmation.
   - If the new scope needs a technology that no skill in `workflow/skills/` covers and the skill library in harness.md is readable, select from it as in WORKFLOW.md §0 (Skill library), with the human's confirmation.
4. Add the phase row (`open`) and one planned row per Scope-In bullet, in build order.
5. Show the human the phase doc and the rows. After confirmation, commit `docs(intake): phase NN <name> (intake)` and push (AGENTS.md §6). Next step: `build`.
