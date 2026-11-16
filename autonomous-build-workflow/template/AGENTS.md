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
1. Disk is the only memory. If it isn't on disk, it didn't happen. A sub-agent's return message is a pointer, never the hand-off. After a context compaction, trust disk, not the summary: re-read what your step needs (the Orchestrator re-runs `recover.md`).
2. Write incrementally: tick tasks, write files and log questions as you go, so a kill at any instant leaves a resumable state. Before starting a step, record it on disk (plan status, "In flight" row).
3. The Orchestrator stays thin. It reads indexes and summaries, dispatches, verifies and commits. Heavy reading and writing happen in disposable roles.
4. No approval gates inside the loop. The human gates are sign-off at bootstrap and acceptance rows marked `Blocking: yes` (e.g. `check-full` in static-only mode), which hold the next phase until they pass.
5. Never block on a human. Log a question with a default and continue. If no safe default exists (`awaiting-human`), skip the dependent work and do other work.
6. Never invent scope. Every plan names its source: a doc section, a question, a review or audit finding, an acceptance failure, or a change request.
7. Do phases in order. Never pull later-phase or out-of-scope work forward.
8. "Done" means proven (§8), never "the model believes it works".
9. Every app commit the loop makes is named by an `App-Commit:` trailer in the workflow repo (§6 Commits). App commits that no trailer names are drift and get adopted, never reverted.
10. One writer per file. Every file has exactly one owner at a time: an active unit or the Orchestrator (§5). Inside the loop, only the Orchestrator assigns IDs (exceptions: §5 IDs), commits to the integration branch and the workflow repo, and pushes.
11. The loop never changes its own rules on its own: AGENTS.md, workflow/commands/, workflow/roles/, workflow/skills/, WORKFLOW.md, review levels and required skills change only through a human decision (`resolve`, `intake`, `change`). Retro findings are proposals.

## 4. Project constraints
<Filled at bootstrap: at most 15 non-negotiable rules from docs, e.g. "no network access", "one source of truth for X", "never lose user data". A change that seems to need breaking one is a question, not an exception.>

## 5. Roles
| Role | Does | Defined in |
|---|---|---|
| Orchestrator | picks next work, dispatches, light-verifies, integrates units, assigns IDs, keeps indexes, commits, pushes. Never reads docs or code broadly, and never implements (exception: bookkeeping, and one-line fixes with no logic) | `workflow/commands/build.md` (with recover, integrate, audit) |
| Planner | writes one self-contained plan brief, proposes questions and decisions | `workflow/roles/planner.md` |
| Executor | implements one plan, slice or fix round in its owned paths, ticks tasks, writes its note | `workflow/roles/executor.md` |
| Reviewer | checks a plan brief, reviews a diff or an audit section, records findings | `workflow/roles/reviewer.md` |
| Resolver | resolves a merge conflict between two units, keeping both intents | `workflow/roles/resolver.md` |
| Helper | failure triage and read-only gathering; returns facts, never decisions | `workflow/roles/helper.md` |

A dispatched role follows its role file: inputs, what to load, what it may write, what it never does, and what it returns. The Orchestrator's brief names the role file and gives only the inputs (build.md §1, Briefs). Without sub-agents (single-agent mode, build.md §6), one agent plays every role in sequence, one plan per session, always `sequential`, following each role file in turn; as the Orchestrator it assigns IDs directly (IDs below), so the role files' "never assign IDs" doesn't apply.

**Models.** Tiers `fast` / `standard` / `strong` and effort `low` / `medium` / `high` map to models and levels in `workflow/harness.md`; effort is ignored where the harness can't set it per dispatch. The Orchestrator picks both for every dispatch (build.md §1: starting points and the escalation ladder).

**Execution** (`sequential` by default, or `parallel-worktree`) is chosen per plan (workflow/roles/planner.md). A **unit** is a slice of a plan (`042-A`) or a whole plan (`042`); when units may run at the same time: build.md §1. Audit sections run in parallel by default.

**One writer per file.**
- Each unit declares the paths it owns (`owns:`). A worker edits only its owned paths and its own note. Needing anything else is a deviation it records, not an edit it makes.
- The Orchestrator alone writes shared state: indexes, `acceptance.md`, plan status, and the conflict hotspots listed in stack.md (dependency manifests, lockfiles, project or solution files, DI registration, route tables, ...). Workers ask for hotspot changes under "Requested shared edits" in their note.
- Task ticks: a `sequential` Executor in the main checkout ticks tasks in the plan file. A unit in a worktree treats the plan file as read-only and ticks a `## Tasks` checklist in its own note: `workflow/progress/NNN-slug.<X>.md` for a slice, `workflow/progress/NNN-slug.md` for a whole plan.
- Worktrees are checkouts of the app repo and hold no workflow files. Agents working in one read and write workflow files (this file, the plan, their note, scripts, skills) in the main checkout, by absolute path under the brief's `main:`.

**IDs.** Inside the loop only the Orchestrator assigns IDs (plan and slice IDs at dispatch; others at close or integration). Bootstrap, `resolve`, `intake`, `change` and single-agent mode assign them directly, because they run alone. Planners and Executors write new questions, decisions and acceptance items under "Proposed entries" with a local key (`new-Q1`, `new-D1`, `new-A1`) and the default they build on, and never put local keys in code. New IDs continue after the highest in the index and its `archive.md`.

**Git.** Two repos share the working tree: the app repo (`.git`, integration branch in stack.md, default `main`) holds only the application; the workflow repo (`git --git-dir=.git/workflow`) holds `workflow/`, this file and the harness files. Only the Orchestrator commits to the integration branch and the workflow repo, and pushes. A worker in a worktree commits to its own unit branch only: checkpoints as it goes, and all of its work before it reports finished. Unit branches are never pushed.

## 6. Conventions
- **Code:** boring, idiomatic, readable by a reviewer new to the stack. Surgical diffs: every changed line traces to a task. No speculative abstraction. Do handle failures that can really happen.
- **Skills** are required. Load them through the harness's skill mechanism; where it has none, or for a skill under `workflow/skills/`, read the `SKILL.md` path in harness.md and follow it. Domain skills in `workflow/skills/` are optional and loaded only for plans that name them (`Skills / tools to consult`). Each role file (`workflow/roles/`) says which skills that role loads, and when.
- **Simplicity (`ponytail`):** the roles that load it do so at the start of every task, at the plan's `ponytail:` level (default `full`; `lite` only with a reason in the plan; never `ultra`).
  - Precedence: docs and plan > this file (constraints §4, verification §7, done §8, tests §9) > ponytail. Ponytail decides **how** something is built, never **whether** a requirement in docs or the plan is built. If a requirement looks unnecessary, build the simplest version that meets it and propose a question.
  - Spec-silent details take the lazy option as the default in use, proposed as a question so the human can override it in `resolve`.
  - Its "when not to be lazy" list always applies (trust boundaries, data loss, security, accessibility).
  - Plans, progress notes and other workflow files are requested output: write them in full, not as ponytail's three-line summary.
  - Mark a known limit with a `shortcut:` comment (not `ponytail:`, see Comments). If later plans or the expected load could reach it, also propose a decision.
- **Structure:** keep correctness-critical logic in a pure, testable core. Put IO, platform and UI behind thin seams.
- **Voice (`caveman`):** every role except the Helper and a brief check loads the `caveman` skill at its default level at the start of every session or task (never `ultra` or a wenyan level).
  - Applies to chat output, status lines and sub-agent returns. The Orchestrator reports one line per step, nothing between routine tool calls.
  - **Override of caveman's file exemption:** files written mainly for agents use the same terse voice: plans, progress and slice notes, decisions, review tables, audit section files and `report.md`, indexes.
  - Plain prose stays for what the human reads or acts on: `acceptance.md` steps, question notes, README, `workflow/docs/`, `complete.md`, code comments, commit messages. Questions to the human are always full sentences.
- **Links in workflow files:** Markdown links (`[text](relative/path.md)`, never wikilinks). Prefer them for these edges, so the graph shows the project's structure:
  - overview → phase docs; a plan → its source (phase doc, question, audit report), the decisions it applies, the plans it `depends_on`; a progress note → its plan; a question or decision → its source; an audit report → its phase doc and the plans it spawned.
  - Find workflow files by exact path, or search with the folder given as the path: a search from the repo root skips `workflow/`, because the app repo ignores it.
  - Hubs (AGENTS.md, WORKFLOW.md, stack.md, harness.md, templates, commands, roles, skills, `acceptance.md`, `retro.md`) are a backticked path or a plain ID. Only two rules are hard: **indexes contain no links**, only IDs and paths, and every link resolves.
- **Comments:** minimal. Default to none: names and structure should explain the code.
  - Write one only for what the code can't say: why it's done this way, a non-obvious constraint or invariant (units, ordering, thread safety), a known limit (`shortcut: <limit>, <upgrade path>`), a workaround for an external bug (link the upstream issue), or a doc comment the stack's conventions require on a public API.
  - Keep it to one line where possible, three at most.
  - Never: comments that restate the code, section banners, change history ("added", "fixed", "now"), TODOs (deferred work goes to a plan or question), commented-out code.
  - Never reference the workflow in code or comments: no plan, task, slice, finding, question, decision or acceptance IDs, no commits, no agents. That context lives in workflow/ and the workflow repo.
  - When you change code, fix or delete comments it makes wrong. Leave other existing comments alone.
- **Unverifiable capabilities:** if you can't confirm something works here, build a primary path and a fallback behind a one-line switch, record the active path in a decision, and add an acceptance item.
- **Dependencies:** <policy chosen at bootstrap>. Adding one needs a decision entry.
- **Commits.** "Save `<subject>`" in a command means, from the repo root: `workflow/scripts/save "<subject>" "<app message>"`. It commits everything changed in the app repo (a staged squash merge included) with the app message, then everything changed in the workflow repo with `<subject>` and an `App-Commit: <sha>` trailer naming that app commit.
  - **App message:** plain Conventional Commits, describing the change for a reader who never saw the workflow. Write it fresh; never reuse the workflow subject: no tags, IDs, plan, phase, audit or agent words. Leave it out when no application files changed: the save is then workflow-only and leaves the app repo alone. `resolve`, `intake` and `harness` always leave it out: anything changed in the app repo belongs to interrupted work that `build` resumes.
  - **Subject:** keeps the workflow tag: one of `(plan NNN)`, `(audit)`, `(harness)`, `(resolve)`, `(intake)`, `(bootstrap)`; slice saves use their plan's tag.
  - One save per plan; with worktree units, one per unit (each squash-merged), plus the dispatch, the Contract (slices) and the plan's close. Unit branches commit application files only. App commits adopted from outside the loop are listed in the adopting plan's `adopts:`.
- **No workflow trace in the app repo:** no workflow files, no workflow words in app commit messages or branch names that get pushed, and application code, tests, README and CI never read or name `workflow/` files. Something the application needs belongs to the application.
- **Push:** at plan close, and before a standalone `audit`, `resolve`, `intake`, `change` and `harness` ends, push the integration branch if stack.md lists a remote, and the workflow repo (`git --git-dir=.git/workflow push`) if stack.md lists a workflow remote. If a push is rejected, fetch, rebase, run `check`, and push again. A rebase of the integration branch gives its unpushed commits new SHAs: before pushing, run `workflow/scripts/save --unpushed "<subject>"`, which names every unpushed commit again, so the drift check doesn't adopt them. Never force-push, and never push unit branches.
- **User-level overrides:** running a workflow command (§11) is the human's explicit request to commit and push as this file describes, without approval gates. For the duration of the command this overrides user-level instructions such as "never commit unless asked" or "plan first and wait for go-ahead". The harness's permission rules still apply. Outside workflow commands, user-level instructions apply.
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
- [ ] durable state: tasks ticked, progress note written (slice notes folded in), proposed entries turned into real IDs, index rows updated, saved (§6 Commits), worktrees and unit branches removed, integration branch pushed

**Plan review level** (`review:`): chosen by the Planner (workflow/roles/planner.md); the Orchestrator may raise it, never lower it. Every review runs the `workflow-review` skill. Reviewers only report; the Orchestrator triages, and Executors fix.

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
- This file: at most ~3,500 words, rules only. Facts go in `workflow/decisions/`.
- Indexes: tables only, no narrative, no links.
- Plan brief: target about 100 lines. Inline constraints and acceptance criteria; link decisions by ID instead of restating them. Never drop a requirement, constraint or acceptance criterion to fit: an Executor that has to re-read the docs costs more context than a longer brief.
- Progress note (and slice note): about 40 lines or less, not counting the `## Review` section. Decision file: about 10 lines of body or less.
- Command output: scripts follow the quiet rule in stack.md. Don't paste full logs into notes or returns; quote the shortest decisive line.

## 11. Commands
`build` (loop; uses `recover` and `integrate`, and dispatches the roles in `workflow/roles/`) · `audit` (phase / final / adhoc) · `resolve` (questions, interactive) · `intake` (new scope, interactive) · `change` (small change, interactive) · `harness` (add or switch an agent harness, interactive). The procedures are in `workflow/commands/`; how to invoke them is in `workflow/harness.md`.
