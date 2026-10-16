# AGENTS.md — <project>

The operating contract for building <project>. Read it in full at the start of every session and after any context compaction. `workflow/docs/` says **what** to build; this file says **how**. Workflow: autonomous-build-workflow (`workflow/WORKFLOW.md`).

## 1. Project
<One paragraph: what it is, for whom, platform.> Source of truth: `workflow/docs/brief.md` → `workflow/docs/00-overview.md` → phase docs.

## 2. Authority
- What: `workflow/docs/brief.md` > `workflow/docs/00-overview.md` > phase docs. `workflow/docs/` changes only through `intake` or by the human; `resolve` may add a "Pulled into scope" line to `out-of-scope.md` for a decision the human just made.
- How: this file. Commands and environment: `workflow/stack.md`. Agent platform: `workflow/harness.md`, the section for the harness you run in (identify it at session start).
- Settled facts: `workflow/decisions/` (start from `index.md`). Only `active` decisions apply. A newer decision overrides an older one only through `supersedes`.
- On conflict the higher source wins, and the conflict becomes a question.

## 3. Loop invariants
1. Disk is the only memory. If it isn't in the repo, it didn't happen. A sub-agent's return message is a pointer, never the hand-off. After a context compaction, trust disk, not the summary: re-read what your step needs (the Orchestrator re-runs `recover.md`).
2. Write incrementally: tick tasks, write files and log questions as you go, so a kill at any instant leaves a resumable state. Before starting a step, record it on disk (plan status, "In flight" row).
3. The Orchestrator stays thin. It reads indexes and summaries, dispatches, verifies and commits. Heavy reading and writing happen in disposable roles.
4. No approval gates inside the loop. The human gates are sign-off at bootstrap and acceptance rows marked `Blocking: yes` (e.g. `check-full` in static-only mode), which hold the next phase until they pass.
5. Never block on a human. Log a question with a default and continue. If no safe default exists (`awaiting-human`), skip the dependent work and do other work.
6. Never invent scope. Every plan names its source: a doc section, a question, a review or audit finding, an acceptance failure, or a change request.
7. Do phases in order. Never pull later-phase or out-of-scope work forward.
8. "Done" means proven (§8), never "the model believes it works".
9. Every commit carries a workflow tag (§6). Untagged commits are drift and get adopted, never reverted.
10. One writer per file. Every file has exactly one owner at a time: an active unit or the Orchestrator (§5). Inside the loop, only the Orchestrator assigns IDs (exceptions: §5 IDs), commits to the integration branch and pushes.
11. The loop never changes its own rules on its own: AGENTS.md, workflow/commands/, workflow/skills/, WORKFLOW.md, review levels and required skills change only through a human decision (`resolve`, `intake`, `change`). Retro findings are proposals.

## 4. Project constraints
<Filled at bootstrap: at most 15 non-negotiable rules from docs, e.g. "no network access", "one source of truth for X", "never lose user data". A change that seems to need breaking one is a question, not an exception.>

## 5. Roles
| Role | Tier / effort (default; routing: build.md §1) | Does | Never |
|---|---|---|---|
| Orchestrator | the session's model | picks next work, dispatches, light-verifies, integrates units, assigns IDs, keeps indexes, commits, pushes | reads docs/code broadly, implements (exception: bookkeeping, and one-line fixes with no logic) |
| Planner | strong / high | writes one self-contained plan brief, proposes questions and decisions | writes code, assigns IDs |
| Executor | standard / medium | implements one plan or slice in its owned paths, writes only the tests the plan lists, ticks tasks, writes its note | commits to the integration branch, edits outside owned paths, assigns IDs |
| Resolver | strong / high | resolves a merge conflict between two units, keeping both intents | guesses when the intents contradict |
| Helper | fast / low | failure triage; read-only gathering; returns facts and evidence (≤10 lines) | edits anything, decides, fixes |
| Reviewer | by review level: `light` standard / medium, `full` strong / high | runs the `workflow-review` skill on a plan's diff or an audit section; records findings | edits source; fixes findings; reviews code it wrote |

Without sub-agents, one agent plays every role in sequence, one plan per session, always `sequential`.

**Models.** Tiers `fast` / `standard` / `strong` map to models in `workflow/harness.md`; effort is `low` … `max`, ignored where the harness can't set it per dispatch. The Orchestrator picks both for every dispatch from the routing table (build.md §1). Helpers (fast / low) read a lot and return little: failure triage and read-only gathering, never decisions.

**Execution** (`sequential` by default, `parallel-shared`, `parallel-worktree`) is chosen per plan (workflow/commands/plan.md). A **unit** is a slice of a plan (`042-A`) or a whole plan (`042`); when units may run at the same time: build.md §1. Audit sections run in parallel by default.

**One writer per file.**
- Each unit declares the paths it owns (`owns:`). A worker edits only its owned paths and its own note. Needing anything else is a deviation it records, not an edit it makes.
- The Orchestrator alone writes shared state: indexes, `acceptance.md`, plan status, and the conflict hotspots listed in stack.md (dependency manifests, lockfiles, project or solution files, DI registration, route tables, ...). Workers ask for hotspot changes under "Requested shared edits" in their note.
- Task ticks: a `sequential` Executor in the main checkout ticks tasks in the plan file. A unit in a worktree or a parallel slice treats the plan file as read-only and ticks a `## Tasks` checklist in its own note: `workflow/progress/NNN-slug.<X>.md` for a slice, `workflow/progress/NNN-slug.md` for a whole plan.

**IDs.** Inside the loop only the Orchestrator assigns IDs (plan and slice IDs at dispatch; others at close or integration). Bootstrap, `resolve`, `intake`, `change` and single-agent mode assign them directly, because they run alone. Planners and Executors write new questions, decisions and acceptance items under "Proposed entries" with a local key (`new-Q1`, `new-D1`, `new-A1`) and the default they build on, and never put local keys in code.

**Git.** Only the Orchestrator commits to the integration branch (stack.md, default `main`) and pushes. A worker in a worktree commits to its own unit branch only: checkpoints as it goes, and all of its work before it reports finished. Unit branches are never pushed.

## 6. Conventions
- **Code:** boring, idiomatic, readable by a reviewer new to the stack. Surgical diffs: every changed line traces to a task. No speculative abstraction. Do handle failures that can really happen.
- **Skills** are required (WORKFLOW.md §0). Load them through the harness, or by reading the `SKILL.md` path in harness.md.
- **Simplicity (`ponytail`):** Planners, Executors and Resolvers load the `ponytail` skill at the start of every task, at the plan's `ponytail:` level (default `full`; `lite` only with a reason in the plan; never `ultra`).
  - Precedence: docs and plan > this file (constraints §4, verification §7, done §8, tests §9) > ponytail. Ponytail decides **how** something is built, never **whether** a requirement in docs or the plan is built. If a requirement looks unnecessary, build the simplest version that meets it and propose a question.
  - Spec-silent details take the lazy option as the default in use, proposed as a question so the human can override it in `resolve`.
  - Its "when not to be lazy" list always applies (trust boundaries, data loss, security, accessibility).
  - Plans, progress notes and other workflow files are requested output: write them in full, not as ponytail's three-line summary.
  - Mark a known limit with a `shortcut:` comment (not `ponytail:`, see Comments). If later plans or the expected load could reach it, also propose a decision.
- **Structure:** keep correctness-critical logic in a pure, testable core. Put IO, platform and UI behind thin seams.
- **Voice (`caveman`):** every role loads the plain `caveman` skill at the start of every session or task (never `ultracave` or `megacave`).
  - Applies to chat output, status lines and sub-agent returns. The Orchestrator reports one line per step, nothing between routine tool calls.
  - **Override of caveman's file exemption:** files written mainly for agents use the same terse voice: plans, progress and slice notes, decisions, review tables, audit section files and `report.md`, indexes.
  - Plain prose stays for what the human reads or acts on: `acceptance.md` steps, question notes, README, `workflow/docs/`, `complete.md`, code comments, commit messages. Questions to the human are always full sentences.
- **Links in workflow files:** Markdown links (`[text](relative/path.md)`, never wikilinks) only for these edges, so the graph shows the project's structure:
  - overview → phase docs; a plan → its source (phase doc, question, audit report), the decisions it applies, the plans it `depends_on`; a progress note → its plan; a question or decision → its source; an audit report → its phase doc and the plans it spawned.
  - Everything else is a backticked path or a plain ID, never a link: AGENTS.md, WORKFLOW.md, stack.md, harness.md, templates, commands, skills, `acceptance.md`, `retro.md`. **Indexes contain no links**, only IDs and paths.
- **Comments:** minimal. Default to none: names and structure should explain the code.
  - Write one only for what the code can't say: why it's done this way, a non-obvious constraint or invariant (units, ordering, thread safety), a known limit (`shortcut: <limit>, <upgrade path>`), a workaround for an external bug (link the upstream issue), or a doc comment the stack's conventions require on a public API.
  - Keep it to one line where possible, three at most.
  - Never: comments that restate the code, section banners, change history ("added", "fixed", "now"), TODOs (deferred work goes to a plan or question), commented-out code.
  - Never reference the workflow in code or comments: no plan, task, slice, finding, question, decision or acceptance IDs, no commits, no agents. That context lives in workflow/ and git.
  - When you change code, fix or delete comments it makes wrong. Leave other existing comments alone.
- **Unverifiable capabilities:** if you can't confirm something works here, build a primary path and a fallback behind a one-line switch, record the active path in a decision, and add an acceptance item.
- **Dependencies:** <policy chosen at bootstrap>. Adding one needs a decision entry.
- **Commits:** Conventional Commits, one per plan. With worktree units, one per unit instead (each squash-merged), plus the dispatch commit, the Contract commit (slices), and the plan's close commit. Subject tag is one of `(plan NNN)`, `(audit)`, `(harness)`, `(resolve)`, `(intake)`, `(bootstrap)`; slice commits use their plan's tag. Commits adopted from outside the loop are listed in the adopting plan's `adopts:`.
- **Push:** the integration branch is pushed at plan close, and by a standalone `audit`, `resolve`, `intake`, `change` and `harness` before they end, if stack.md lists a remote. If a push is rejected, fetch, rebase, run `check`, and push again. Never force-push, and never push unit branches.
- **Language** of code and docs: <...>.

## 7. Verification ladder
Verify each acceptance criterion at the highest tier available, and record which tier you used:
1. **Automated:** covered by `check` (workflow/stack.md).
2. **Agent-observed:** run the artifact and inspect real output using tools listed in stack.md (CLI output, HTTP probe, UI test runner, snapshot or screenshot, logs). Use only tools enabled in harness.md.
3. **Human:** a row in `workflow/acceptance.md` with exact steps and the expected result. Use this only for what tiers 1–2 can't reach.

A failing `check` is an **environment problem until proven otherwise**: check stack.md "Known environment symptoms" and re-run through the script. Only then treat it as a code failure.

**Static-only mode** (declared in stack.md and accepted at sign-off): verify by consistency instead (every referenced symbol and file exists). Each phase end adds a blocking acceptance item to run `check-full`.

## 8. Definition of done (per plan)
- [ ] `check` passes (static-only mode: consistency verified)
- [ ] every acceptance criterion verified at its stated tier, with tier-3 items in acceptance.md
- [ ] traceability: each changed file → a task → the plan's source
- [ ] §4 constraints hold, and no later-phase or out-of-scope work crept in
- [ ] tests: exactly those on the plan's `Tests:` line (§9), no others
- [ ] diff self-reviewed as the human reviewer would read it
- [ ] plan review done at its level, with no critical or high finding whose Status is exactly `open`
- [ ] docs current: README, stack.md and decisions updated if behavior, commands or settled facts changed
- [ ] durable state: tasks ticked, progress note written (slice notes folded in), proposed entries turned into real IDs, index rows updated, tagged commit(s), worktrees and unit branches removed, integration branch pushed

**Plan review level** (`review:`): chosen by the Planner (workflow/commands/plan.md); the Orchestrator may raise it, never lower it. Every review runs the `workflow-review` skill. Reviewers only report; the Orchestrator triages, and Executors fix.

## 9. Tests
Coverage is deliberately traded for speed and signal. **Default: no new test.** Most plans add zero or one. A plan proves its acceptance criteria at the verification tier that fits (§7); often that's tier 2, which leaves no test behind.

Write a test only for:
1. **User flows (e2e):** one test per important flow, through the outermost layer that runs headless here (stack.md "E2E"). Real storage; mocks only at true external boundaries (third-party APIs, the clock).
2. **Critical logic:** the overview's high-risk areas and the §4 constraints (data loss and persistence, money and time calculations, security, parsing of external input). The only place unit tests are allowed, and only where edge cases are cheaper to cover than through e2e.
3. **Regressions:** only for a bug in a critical area, or a bug that has come back. Other bugs are fixed without a new test.

Never: tests for trivial code, accessors, constants, framework behavior or language semantics; mock-heavy tests of glue code; snapshot tests nobody reads; coverage padding.
- The Planner lists the tests on the plan's `Tests:` line with a reason each (flow, critical, regression). The Executor adds no others.
- Name a test after the behavior it pins. Finding or question IDs go in the progress note, not in the test.
- `check` runs the critical tests and an e2e smoke subset (a few core flows) and stays fast. `check-full` runs every e2e flow.
- These rules take precedence over ponytail's "one runnable check".

## 10. Size budgets
Context that is read every session must stay small. When something goes over budget, move the content elsewhere; don't compress it into a lossy summary.
- This file: at most ~250 lines, rules only. Facts go in `workflow/decisions/`.
- Indexes: tables only, no narrative, no links.
- Plan brief: target about 100 lines. Inline constraints and acceptance criteria; link decisions by ID instead of restating them. Never drop a requirement, constraint or acceptance criterion to fit: an Executor that has to re-read the docs costs more context than a longer brief.
- Progress note (and slice note): about 40 lines or less. Decision file: about 10 lines of body or less.
- Command output: scripts follow the quiet rule in stack.md. Don't paste full logs into notes or returns; quote the shortest decisive line.

## 11. Commands
`build` (loop; uses `recover`, `integrate` and `plan`) · `audit` (phase / final / adhoc) · `resolve` (questions, interactive) · `intake` (new scope, interactive) · `change` (small change, interactive) · `harness` (add or switch an agent harness, interactive). The procedures are in `workflow/commands/`; how to invoke them is in `workflow/harness.md`.
