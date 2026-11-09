---
name: workflow-review
description: Combined code review used by this repo's workflow. Runs the harness's built-in correctness review and ponytail-review on the same target, checks the change against its plan, and merges everything into one findings table. Use for plan and unit reviews, phase or final audit sections, change, or "review <target>".
---

# workflow-review

Read-only: lists findings, changes no code. Never pass a fix flag to a review tool.

## Inputs
- **target:** a git range (`main..HEAD`), `uncommitted` (`git status` and `git diff HEAD`; read new files in full), or paths
- **context:** the plan and its note (optional for ad hoc reviews)
- **level:** `light` or `full` (workflow/commands/plan.md)
- **out:** where to write the merged table (a `## Review` section or an audit section file)
- **focus** (deep pass only): the reason the first pass was escalated. Review those parts in depth. Keep the first pass's rows (change a severity or status only with a reason), append new rows, and replace its verdict.

A review that dies is simply run again. Only the merged result is written.

## 1. Run both lenses on the same target
Run them in parallel when the harness allows; both are read-only.
- **Correctness:** the built-in review named in workflow/harness.md, on the target. Effort `low` for `light`, `medium` for `full`. If harness.md says `fallback`, or an agent can't start it, run the fallback bug hunt below instead, in a fresh sub-agent where possible.
- **Quality and lean:** `ponytail-review` on the target (required, so always available).

Wait until every lens has finished before merging. Never write the verdict, return, or edit **out** after returning while a lens is still running. If the built-in review can't start or doesn't finish, run the fallback bug hunt and record it on the `Lenses:` line (§4).

## 2. Check against the plan (skip without a plan)
- Each acceptance criterion is really met: point at the code or test that shows it.
- AGENTS.md §4 constraints hold.
- Nothing outside the plan's scope or `owns:` changed. Ignore `workflow/` bookkeeping and requested shared edits the Orchestrator applied.
- New or changed comments follow AGENTS.md §6 Comments: minimal, and no workflow references.
- New tests are exactly those on the plan's `Tests:` line and meet AGENTS.md §9.

## 3. Merge
Put every finding on one scale:

| Source | Severity |
|---|---|
| built-in review | its own level, mapped to critical / high / medium / low |
| ponytail Must fix | high (critical for data loss or a security hole) |
| ponytail Should fix | medium |
| ponytail Nice to have | low |
| plan: unmet acceptance criterion, broken constraint | high |
| plan: change outside scope or `owns:` | medium |
| plan: comment rule broken (restates code, workflow reference, TODO, commented-out code) | low |
| plan: test not on the `Tests:` line, or not meeting AGENTS.md §9 | medium (lens: lean) |

Then:
- **Duplicates** (same location, same root cause): keep one, with the higher severity and every lens that found it.
- **Missing-test findings** count only for critical logic, a user flow without its planned e2e test, or a recurring bug (AGENTS.md §9). Drop the rest.
- **Lean findings** from ponytail's Should fix or Nice to have stay medium or low, except a structural one in code later plans will build on: a new abstraction with one implementation, an unneeded dependency, config nobody sets, or a speculative feature. That becomes high, because it's cheapest to remove now.
- **Conflicts:** if a lean fix would remove something correctness depends on, keep the correctness view and note why.
- **Every finding needs a concrete case** (this input or situation leads to this wrong result). Drop a finding only after re-reading the code and confirming it's wrong.
- **Nits:** a low finding with no concrete case (wording, naming, small duplication, an unreachable branch) isn't a table row. List it on one `Nits:` line after the table. Nits aren't fixed in a fix round, collected by audits or planned. A broken plan rule from §2 is never a nit.

## 4. Write
Write to **out**:

| # | Severity | Lens | Location | Finding and concrete case | Fix | Status |
|---|---|---|---|---|---|---|

- Lens: `correctness` | `quality` | `lean` | `plan`. Fix: the smallest fix that works, preferring fixes that delete code. Status starts as `open` for critical and high rows, and `open → phase audit` for medium and low rows. `fixed` always cites its evidence (file:line or commit).
- After the table: `Nits:` if any, `Verdict: ship` or `Verdict: fix #…`, `Lean: -<N> lines possible` if any, `Lenses: <built-in | fallback>, ponytail-review`, and `Not checked:` for anything that mattered but couldn't be checked.
- Then `Deep review: no` or `Deep review: yes — <reason>`. Say yes only when part of the target needs more depth than this pass gave it: a critical or high finding you couldn't confirm, or security, auth, data-integrity or concurrency logic you couldn't fully judge. A confirmed finding needs a fix, not a deep review. A deep pass writes `Deep review: done`.
- Return ≤5 lines: counts by severity, the verdict and the `Deep review:` line.

## Fallback bug hunt (correctness lens without a built-in review)
Read-only. Goal: find what breaks, not restate what the code does. `light`: hunks with logic only. `full`: every hunk.
1. List each changed hunk. For each, one line: what it must do (from the plan, or from its callers).
2. Try to break it: empty, zero, boundary and malformed inputs; error, timeout and retry paths; ordering and concurrency; state left behind after a failure; every caller of a changed signature or behavior; the plan's acceptance criteria.
3. Keep a finding only with a concrete case (this input or situation leads to this wrong result) that you confirmed by re-reading the code. Few confident findings beat many guesses.
4. Severity: critical (data loss, security hole, crash on a normal path); high (wrong result on a realistic input, broken caller, unmet acceptance criterion); medium (edge-case failure, critical logic without a test); low (minor robustness).
5. Report the findings as the correctness lens for §3.
