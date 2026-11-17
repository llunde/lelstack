---
name: check
description: Combined correctness review, over-engineering review and comment review of the current diff, in one numbered list, without applying anything. Only run when I invoke it.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: false
---

Run three reviews on the same target, then merge them. Apply nothing.

## Target and context

Any text I gave after the skill name (`$ARGUMENTS` in Claude Code) may contain a target (default: the uncommitted diff, `git diff HEAD` + untracked files; or "PR #74", "branch vs develop"), files to ignore (e.g. `appsettings.json`), and context about the goal (issue text, often Norwegian). Apply the target, the ignores and the context to all reviews.

## Steps

1. **Correctness review.** If your tool has a `code-review` skill or command (Claude Code does), use it with the target and context. Otherwise review the diff yourself for bugs, broken existing behaviour, missing error handling, security issues and wrong assumptions about callers. Read the surrounding code, not just the diff lines.
2. **Over-engineering review.** Use the `ponytail-review` skill (in `~/.agents/skills/ponytail-review`) on the same target.
3. **Comment review.** Do this yourself, only on comments the diff adds or changes. Default is no comment: names and structure should explain the code.
   - Keep: why it's done this way, a non-obvious constraint or invariant (units, ordering, thread safety), a known limit, a workaround for an external bug (with upstream link), or a doc comment the stack requires on a public API.
   - Flag: comments that restate the code (including doc comments that only repeat the member name, like `/// Gets the user` on `GetUser`), section banners, change history ("added", "fixed", "now", "new"), new TODOs, commented-out code, references to tickets, PRs, plans, reviews or agents, and comments longer than 3 lines.
   - Also flag existing comments the diff made wrong. Leave other existing comments alone.
   - Fix is usually "delete" or a shorter rewrite; give the rewrite inline.
4. Merge them into **one numbered list**, most important first:
   - `N. [bug|risk|simplify|comment|nit] file:line: what, and the fix in one line`
   - Mark each finding as **(this diff)** or **(pre-existing)**. Pre-existing ones go last and are only flagged.
   - Drop duplicates between the reviews, and drop simplifications that would make the code worse or break existing behaviour.
   - Group several trivial comment findings in one file into one item (e.g. `Foo.cs:12,30,44: restate the code, delete`) so they don't bury the real findings.
5. End with one line, e.g. `Ship as is`, `Fix 1–2 first`, or `net: -N lines possible`.

Then wait. I'll answer with "apply 1, 3" or "show me 2". "Show me" means paste the code in chat and don't edit.
