---
name: pr-text
description: Suggest a branch name, commit message and PR description for the current diff, written the way Lars writes them. Use for /pr-text, or when asked for a commit message, PR description or branch name.
---

Write text for the current change. Return it in the chat only. Never run `git add/commit/push`, `git checkout -b`, or `gh pr create/edit`.

## Input

1. Read the diff: uncommitted changes (`git diff HEAD` + untracked files from `git status`), or if the tree is clean, the current branch against `develop` (fall back to `main`/`master`).
2. Use any text I gave after the skill name (`$ARGUMENTS` in Claude Code) as context: issue text (often Norwegian), the PR's goal, or which parts to include ("only commit", "PR only", "norsk").
3. If this conversation already discussed the problem and the fix, use that. It beats guessing from the diff.

## Output

Give only the parts that were asked for. With no arguments, give all three.

- **Branch:** `issue/<TICKET>_<short-slug>` when a ticket id is known (e.g. `issue/ABC-128_origin-check`). Otherwise `<short-kebab-slug>`.
- **Commit message:** one line, imperative, under ~70 chars. Add a short body only if the why isn't obvious.
- **PR description:** 2–6 short sentences or a few bullets: what was wrong, what changed, and anything a reviewer or tester must know (env vars, backoffice/dictionary steps, infra changes in another repo). No per-file walkthrough.

Then stop. Offer nothing else.

## Style

- Sound like a developer wrote it quickly for colleagues. Plain, specific, a bit informal.
- No em-dashes. No "This PR...", "This change introduces...", "In summary". No headings for a short description. No bold-label bullet lists. No emoji.
- Don't oversell ("robust", "comprehensive", "seamless", "ensures").
- Language follows the request: English by default, natural bokmål if asked for Norwegian.
- If asked for "shorter", cut it roughly in half. Don't just trim words.
