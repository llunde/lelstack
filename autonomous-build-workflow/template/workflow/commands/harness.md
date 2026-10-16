# harness

Run it from the harness being added: "Follow workflow/commands/harness.md". Bootstrap uses the same steps for the harness it runs in. Write only to workflow/harness.md, this harness's binding and permission files (WORKFLOW.md §6) and .gitignore.

1. Identify this harness (name and version). If harness.md already has a section for it, re-run the checks below and update that section.
2. **Preflight.** Check each required skill (WORKFLOW.md §0): in this harness's skill list, or `SKILL.md` at its user-level skill path. If one is missing, stop and write nothing. Report the skill, this harness, and "install it at user level, then run `harness` again". Then load `caveman`.
3. **Models.** Ask the human which models map to strong / standard / fast here, suggesting this harness's current large, mid and small models. Start a minimal sub-agent on each to confirm it runs. Record which effort levels a dispatch can set, or "harness default".
4. **Capabilities.** Probe and record: sub-agents and nesting; worktrees (native isolation and where it puts them, or Orchestrator-created at a location sub-agents can edit without permission prompts); a built-in code review an agent can start read-only on a range or paths (else `fallback`); how commands are invoked.
5. **Bindings.** If the workflow source folder is readable and has `bindings/<harness>/`, copy its contents (including hidden folders such as `.claude/`) to the repo root; otherwise write the binding files from WORKFLOW.md §6. Apply the permissions baseline (WORKFLOW.md §6), adding the worktree location if it's outside the repo; confirm it with one allowed and one denied command. Add its worktree location to .gitignore if it's inside the repo. Fill in the section and its Skills table.
6. **Work in flight.** If "In flight" has rows, list them: the next `build` here resumes them (recover.md step 3). Recommend switching when nothing is in flight.
7. Commit `chore(harness): add <harness> (harness)` and push (AGENTS.md §6). Summarize the section in a few lines.
