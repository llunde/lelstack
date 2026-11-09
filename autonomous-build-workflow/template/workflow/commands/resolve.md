# resolve

Write only to question notes, the questions index, `workflow/decisions/`, the plans index (new `planned` rows), workflow/retro.md (proposal status), `workflow/docs/out-of-scope.md` ("Pulled into scope" only), `workflow/acceptance.md` (Result, Date and Note only), and, for approved `needs: workflow` questions, the workflow file the proposal names (AGENTS.md, stack.md, harness.md, a plan's review level). Never touch source.

1. Load the `caveman` skill (questions to the human stay in full sentences). Read AGENTS.md §2–4, the questions index and the open notes. Announce the set you'll go through in ID order, `awaiting-human` first.
2. For each question, investigate docs and code yourself first. Then ask the human one thing at a time, always with a recommendation, working depth-first until you have a firm, explicitly confirmed decision.
3. Only after confirmation:
   - Write the Resolution, set `status: resolved` and the date, and update the index.
   - Add a decision (D-NNN file and index row) if the answer settles a fact.
   - If the decision differs from the default the code uses, add a planned row "Reconcile Q-NNN" with `source: Q-NNN`, and Pri `next` if shipped code or AGENTS.md now contradicts it. Don't write the plan or touch code. If a new row would land after a plan that must run last or only once in its phase (a destructive reset, a rebuild proof, a release step), order it before that plan, or add a row to rerun that plan after it.
   - If the decision changes scope, record it in out-of-scope "Pulled into scope", or send it to `intake`.
   - For a `needs: workflow` question: if approved, apply the change to the named workflow file, add a decision, and mark the proposal `approved` in retro.md. If declined, mark it `declined`.
4. Optionally, record results for pending acceptance rows that the human has run.
5. Commit `docs(questions): resolve Q-... (resolve)` and push (AGENTS.md §6). Summarize what was resolved, which plans were queued, and what is still open.
