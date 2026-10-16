# change

The sanctioned path for quick fixes and tweaks, so that nothing lands outside the loop. If the request needs more than about one plan, changes a constraint, or adds a feature area, use `intake` instead.

1. Load the `caveman` skill (questions to the human stay in full sentences). Read AGENTS.md and the code involved. Ask until the expected behavior is unambiguous.
2. Write a short plan from the template (Context and Tasks can be brief; choose levels per workflow/commands/plan.md), with `mode: interactive` and `source: change YYYY-MM-DD: <the request in one line>`. Add its index row.
3. Load the `ponytail` skill (level `full` unless the human asks for `lite`) and implement, iterating with the human as needed. Follow the test rules in AGENTS.md §9: a bug fix gets a regression test only in a critical area or for a bug that came back.
4. Pass the done gates in AGENTS.md §8, including the plan review at its level: dispatch a fresh Reviewer with the build.md §2 step 5 brief (in single-agent mode, a separate pass). The human can waive a `light` review. If the change alters behavior described in workflow/docs/ or in a decision, add a decision (D-NNN file and index row) that references it.
5. Write a short progress note, update the index, commit `<type>(<scope>): <subject> (plan NNN)`, and push (AGENTS.md §6). `change` is always `sequential`, and the agent running it writes real IDs directly.
