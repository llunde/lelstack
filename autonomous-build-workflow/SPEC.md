# Autonomous Build Workflow

A template for building any software project with an LLM agent in a resumable **plan → implement → verify** loop. It is neutral about stack, platform and agent harness.

This folder holds:
- `SPEC.md` (this file): how the workflow works and how to bootstrap it.
- `template/`: the literal files bootstrap copies into a new repo (§4, §5).
- `bindings/<harness>/`: ready-made harness binding files (§6), copied by bootstrap and `harness`.
- `README.md`: the human guide, with diagrams. Bootstrap doesn't read or copy it.

In a project, this file is `workflow/WORKFLOW.md`. There, `template/X` means the copied file `X` at the repo root, and `bindings/` stays in the source folder.

## How to use

1. Install the required skills (§0). Point an agent at an empty folder and say **"Bootstrap from `<path to this folder>/SPEC.md`."** The agent needs read access to this folder (in Claude Code, approve it once or add it to `additionalDirectories`), or copy this folder into the new repo first. It runs the preflight and Stage A (§3).
2. Give it the project description. It runs Stage B: interview, docs, stack, then asks for your sign-off.
3. Run `build` and re-run it after every reset or usage limit. Between sessions, use `resolve` for questions and work through `workflow/acceptance.md`.
4. For later work, use `intake` (new scope) or `change` (small fixes). Don't commit outside these commands.

## 0. Requirements

Install the required skills at user level, for every harness that will run the loop. Find them by name. The preflight (§3) and every `build` check for them and stop if one is missing. There is no degraded mode.

| Requirement | Used by | If missing |
|---|---|---|
| `caveman` skill | every role (AGENTS.md §6 Voice) | **required**: stop |
| `ponytail` skill | Planner, Executor, Resolver (AGENTS.md §6 Simplicity) | **required**: stop |
| `ponytail-review` skill | `workflow-review`, quality and lean lens | **required**: stop |
| `workflow-review` skill | every review and audit | none: bootstrap copies it into the repo (`workflow/skills/workflow-review/`) |
| the harness's built-in code review (e.g. Claude Code `/code-review`) | `workflow-review`, correctness lens | optional: the fallback bug hunt in `workflow-review` |
| git, and a harness with sub-agents | the loop; parallel work | git required; without sub-agents, single-agent mode (§6) |

**Loading a skill** means using the harness's skill mechanism. A harness without one reads the skill's `SKILL.md` at the path recorded in `workflow/harness.md` and follows it.

---

## 1. The model in one screen

```
bootstrap A ─▶ description ─▶ bootstrap B (interview → docs → stack) ─▶ [human sign-off]
   ─▶ build: for each phase { plan → execute → verify → review → integrate → commit }* ─▶ phase audit ─▶ remediation ─▶ next phase
   ─▶ final audit ─▶ completion summary ─▶ maintenance (intake / change)

execute = sequential (default) | parallel-shared (sub-agents, one tree) | parallel-worktree (local worktree + branch per unit)
```

- **Memory lives on disk.** Plans, progress notes, questions, decisions and indexes in git are the only state. Any session can die at any moment and the next `build` rebuilds the picture from the repo.
- **Roles:** a thin Orchestrator dispatches disposable Planners, Executors and Reviewers. Their context is thrown away and only files persist (AGENTS.md §5).
- **One writer, one branch.** Every file has one owner at a time. Inside the loop, only the Orchestrator assigns IDs (exceptions: AGENTS.md §5 IDs), commits to the integration branch (default `main`) and pushes. Parallel units work on local branches that are never pushed.
- **Humans are asynchronous.** The loop never waits. It logs questions with defaults, appends human checks to `acceptance.md`, and keeps going.
- **The human does:** answer bootstrap questions, sign off on the docs, run `resolve`, run acceptance checks, and request new work through `intake` or `change`.

## 2. Repository layout

All workflow material lives under one top-level folder, `workflow/`, so the rest of the repository contains only the project itself. Everything is committed.

```
AGENTS.md                   rulebook: how to build (read in full every session)
CLAUDE.md, .claude/ ...     harness stubs and tool config only (§6), never workflow documents
README.md                   the project's README: what it is, run locally, install/deploy (kept current)
scripts/                    setup, check, check-full, run (project-owned; named in workflow/stack.md)
<project source, tests, CI, lint config ...>
workflow/
  README.md                 map of this folder: what each file is for and who writes it
  WORKFLOW.md               copy of this spec (not read by `build`; `harness` reads §0 and §6)
  docs/                     WHAT to build; changed only via intake or by the human
    brief.md                the human's project description, verbatim, never edited
    00-overview.md          vision, locked decisions, domain model, risks, phase list
    NN-<phase>.md           one per phase, dependency order
    out-of-scope.md         fenced-off ideas + "Pulled into scope" record
  stack.md                  stack profile: commands, layout, environment
  harness.md                agent platform: tiers→models, sub-agents, parallel cap
  decisions/index.md        decision table
  decisions/D-NNN-slug.md   one file per settled fact
  acceptance.md             human-only checks (A-NNN)
  retro.md                  evidence-backed observations and improvement proposals (written by audits)
  dashboard.base            Obsidian Bases status view (optional, §7); .obsidian/ is gitignored
  plans/index.md            plan + phase status table
  plans/NNN-slug.md         one brief per plan
  progress/NNN-slug.md      one completion record per plan
  progress/NNN-slug.X.md    slice note (parallel slices only; folded into the plan's note at close)
  progress/complete.md      completion summary, written when the final audit is clean
  questions/index.md        question table
  questions/Q-NNN-slug.md   one note per question
  audits/YYYY-MM-DD-<scope>/   section-*.md + report.md
  templates/                plan, progress, question, decision, audit, phase
  commands/                 build (+ recover, integrate, plan), audit, resolve, intake, change, harness
  skills/workflow-review/   SKILL.md: the combined review used by every review step
```

**Layout rules**
- Outside `workflow/`, the only workflow files are `AGENTS.md` and the harness stubs and config folders that a tool requires at the root (§6). Those folders hold tool configuration only.
- Project-owned tooling stays with the project and never moves into `workflow/`: tests, lint and format config, CI, and `scripts/`. `workflow/stack.md` records how to run them; it does not replace them.
- Refer to workflow files by exact path. Don't rely on search to find them.

## 3. Bootstrap

The bootstrap agent loads the `caveman` skill once the preflight passes (AGENTS.md §6 Voice). Questions to the human and the sign-off summary are full sentences.

### Stage A — infrastructure (on "Bootstrap from …/SPEC.md")

1. Note which harness you are running in (bootstrap sets up this one only; other harnesses are added later by running `harness` from inside them). Ask the human whether they view the workflow in Obsidian. Steps 2 and 5 follow the `harness` procedure (`template/workflow/commands/harness.md`; nothing is copied yet at step 2) for this harness.
2. **Preflight.** Check every requirement in §0 for this harness. A skill is present if it appears in the agent's skill list or its `SKILL.md` exists at the harness's user-level skill path. Check whether an agent can start the built-in code review read-only on a git range or paths. If a required skill is missing, **stop** before writing anything, and report it: the skill name, which harness lacks it, and "install it at user level, then say 'Bootstrap from <path>/SPEC.md' again". Never continue without it.
3. `git init -b main` if the folder isn't a repo yet.
4. **Copy, don't retype.** Copy everything in `template/` into the repo root as is (`AGENTS.md` and `workflow/`), and copy this `SPEC.md` to `workflow/WORKFLOW.md`. Then replace `<project>` with the project's name and delete the example row A-001 from `workflow/acceptance.md`. Leave the other placeholders for step 5 (harness.md) and Stage B (AGENTS.md §1, §4, §6, stack.md, the D-001 row); mark AGENTS.md's project sections `TBD (stage B)`.
5. Fill in `workflow/harness.md` (§4): the shared settings, and this harness's section (`workflow/commands/harness.md` steps 3–5: model mapping, capability probe, Skills table, bindings from `bindings/<harness>/` and permissions).
6. If the human uses Obsidian, set it up as in §7 (Obsidian): the `.obsidian/` config in `workflow/` and `workflow/dashboard.base`.
7. Add a basic `.gitignore` (including `workflow/.obsidian/`, and the worktree location from harness.md if it is inside the repo) and a stub `README.md`. Commit `chore: bootstrap autonomous-build-workflow (bootstrap)`. Then ask for the project description.

### Stage B — project definition (on receiving the description)

1. Save the description verbatim as `workflow/docs/brief.md`.
2. List the ambiguities, missing decisions and risks. Ask about them **in one interactive round**: grouped, each with a recommendation. Ask follow-ups only where an answer opens new branches. Anything the human leaves open becomes a question note with a default.
3. Write `workflow/docs/00-overview.md`, the phase docs and `workflow/docs/out-of-scope.md`:
   - The overview covers vision, users, locked decisions, domain model, principles, **high-risk areas** (correctness-critical logic and capabilities that can only be confirmed in a specific environment) and the phase list, each phase linked to its doc (AGENTS.md §6 Links).
   - Phases go in dependency order, and each one should be a usable increment where possible.
   - **Phase 1 starts with the walking skeleton (plan 001):** a minimal runnable app, service or library in the chosen layout, with a pure core and thin shell split, one e2e smoke test of the first user flow, working and quiet (stack.md entry points) `scripts/setup`, `check`, `check-full` and `run`, and a README "Run locally" section. `check` must pass in this environment.
4. Choose the stack if the description doesn't fix it. Prefer what the human knows and what the agent's environment can verify. Record it as D-001 with the alternatives considered.
   - **Probe** the environment (which tools exist, which versions) rather than assuming, then write `workflow/stack.md`, including the E2E, Git and Concurrency sections (the outermost headless layer and smoke flows, integration branch, remote, conflict hotspots for this stack, worktree setup).
   - If `check` can't run here at all, declare **static-only mode** in stack.md. The human must accept it explicitly at sign-off.
   - Choose skills or plugins and record them in harness.md. List any tier-2 tools in stack.md and enable them in harness.md.
5. Fill in AGENTS.md §1, §4 and §6.
6. Seed `workflow/plans/index.md` with one row per phase and row `001 Walking skeleton`. Other plans can be listed by title now. Their briefs are written just in time.
7. **Sign-off gate.** Show the human a summary of one page or less: phases, stack and why, constraints, environment capabilities (and static-only mode if it applies), and open questions with their defaults. Apply corrections. When approved, commit `docs: project definition (bootstrap)`, then run `build`.

---

## 4. Template

`template/` (next to this spec) holds the literal files bootstrap copies into a new repo. Copy them; never retype them. Placeholders in `<angle brackets>` are filled at bootstrap only in `AGENTS.md`, `workflow/stack.md`, `workflow/harness.md` and the D-001 index row (`<project>` in Stage A step 4, harness.md in step 5, the rest in Stage B). Placeholders in `workflow/templates/`, `workflow/commands/` and `workflow/skills/` stay: they're filled each time the file is used.

| File | What it is | Written by (in a project) |
|---|---|---|
| `AGENTS.md` | the rulebook every role reads | bootstrap; then only by human decision (AGENTS.md §3.11) |
| `workflow/README.md` | map of the workflow folder | bootstrap |
| `workflow/stack.md` | stack profile: entry points, E2E, Git, concurrency, environment | bootstrap Stage B; plans that change commands |
| `workflow/harness.md` | shared settings and one section per harness | `harness` |
| `workflow/decisions/index.md` · `workflow/templates/decision.md` | decision table · one decision | Orchestrator, interactive commands |
| `workflow/acceptance.md` | human-only checks | Orchestrator; the human fills in results |
| `workflow/plans/index.md` · `workflow/questions/index.md` | plan, phase and in-flight tables · question table | Orchestrator, interactive commands |
| `workflow/templates/plan.md` · `progress.md` · `question.md` · `audit.md` · `phase.md` | templates for plan briefs, progress and slice notes, questions, audit reports, phase docs | — |
| `workflow/docs/out-of-scope.md` | fenced-off ideas and the "Pulled into scope" record | bootstrap Stage B, `intake`, `resolve` |
| `workflow/skills/workflow-review/SKILL.md` | the combined review used by every review and audit | — |
| `workflow/retro.md` | evidence-backed observations and proposals | audits; `resolve` updates proposal status |

## 5. Commands

All procedures are in `template/workflow/commands/`.

| Command | Purpose | Run by |
|---|---|---|
| `build.md` | the loop: dispatch rules, plan → execute → verify → review → close, phase end, stop conditions, IDs | the human (`build`), every session |
| `recover.md` | resume from disk at every session start and after compaction | `build` |
| `integrate.md` | rebase, resolve, check, review and merge one worktree unit | `build` |
| `plan.md` | write one plan brief: execution modes, review levels, ponytail, model | Planner, dispatched by `build` |
| `audit.md` | read-only phase / final / ad hoc audit, with retro | `build` at phase end, or the human |
| `resolve.md` | settle questions with the human | the human (interactive) |
| `intake.md` | add new scope as a phase | the human (interactive) |
| `change.md` | small human-steered change | the human (interactive) |
| `harness.md` | add or switch an agent harness: preflight, models, capabilities, bindings, permissions | the human, from the harness being added; bootstrap |

## 6. Harness bindings

Bindings are the only workflow files besides `AGENTS.md` that live outside `workflow/`, because each harness looks for them in a fixed place. Keep them as thin pointers into `workflow/`.

**Claude Code**
- `CLAUDE.md` contains one line: `@AGENTS.md`.
- Ready-made files are in `bindings/claude-code/` next to SPEC.md: `CLAUDE.md`, and `.claude/` (`commands/`, `skills/workflow-review/SKILL.md`, `settings.json`). Bootstrap and `harness` copy them into the repo root when that folder is readable; otherwise they write the files from this section. What they contain:
- `.claude/skills/workflow-review/SKILL.md`: the same `name` and `description` as `workflow/skills/workflow-review/SKILL.md`, with the body `Follow workflow/skills/workflow-review/SKILL.md exactly. Arguments: $ARGUMENTS`.
- `.claude/commands/<name>.md` for each of build, audit, resolve, intake, change and harness:
  ```
  ---
  description: <one line>
  model: opus
  ---
  Follow `workflow/commands/<name>.md` exactly. Arguments: $ARGUMENTS
  ```
- Tiers: strong = `opus`, standard = `sonnet`, fast = `haiku` (aliases; don't use `fable`). Pass `model` and `effort` on every Agent call (per-call effort needs Claude Code v2.1.292 or later; leave `CLAUDE_CODE_EFFORT_LEVEL` unset, since it overrides per-call effort). Sub-agents go through the Agent tool. They can nest (by default up to three levels) and can run skills, which the review needs: a Reviewer sub-agent runs `/code-review` and `ponytail-review` itself. All other dispatching stays with the Orchestrator. For `parallel-worktree`, use the Agent tool's worktree isolation and record the worktree path and branch it reports in "In flight". Add `.claude/worktrees/` to `.gitignore` and exclude it from test discovery, lint and search. Skills and plugins go in `.claude/settings.json`.

**Permissions baseline** (every harness). An autonomous run should neither stall on permission prompts nor run with everything allowed. The `harness` command writes this baseline into the harness's own permission config and records where in its section of harness.md:
- **Allow** without prompting: the repo's `scripts/`; git inside the repo and its worktrees (status, diff, log, add, commit, rebase, merge, worktree, branch, fetch); reading and editing files in the repo and the worktree location; pushing the integration branch.
- **Deny:** force pushes, `git reset --hard`, `git clean`, `rm -rf`, reading credential locations (`~/.ssh`, `~/.aws`, `.env` files), and `sudo`.
- Also allow the stack's own commands from stack.md (worktree setup, dependency install) once they're known.
- Everything else prompts. A prompt in an unattended run is a sign something went off-plan.
- Deny rules are a guardrail, not a sandbox: a shell can work around a prefix rule. Nothing in this workflow needs a denied command.

Claude Code: `.claude/settings.json` (committed; the copy is `bindings/claude-code/.claude/settings.json`):
```json
{
  "permissions": {
    "allow": ["Bash(scripts/*)", "Bash(./scripts/*)", "Bash(git status)", "Bash(git status *)", "Bash(git diff *)",
              "Bash(git log *)", "Bash(git add *)", "Bash(git rm *)", "Bash(git commit *)", "Bash(git rebase *)",
              "Bash(git merge *)", "Bash(git worktree *)", "Bash(git branch *)", "Bash(git fetch *)",
              "Bash(git -C *)", "Bash(git push)", "Bash(git push *)", "Edit(./**)"],
    "deny": ["Bash(git push --force *)", "Bash(git push -f *)", "Bash(git push --force-with-lease *)",
             "Bash(git reset --hard *)", "Bash(git clean *)", "Bash(rm -rf *)", "Bash(sudo *)",
             "Read(~/.ssh/**)", "Read(~/.aws/**)", "Read(./**/.env)", "Read(./**/.env.*)"],
    "ask": ["Edit(./.claude/settings.json)"]
  }
}
```
Deny rules win over allow rules, so a force push stays blocked. Editing the permission file itself always asks, so an agent can't loosen its own baseline; `harness` runs with you present. Delete slice notes with `git rm`. Add the worktree location to `permissions.additionalDirectories` if it's outside the repo. Rule syntax changes between versions: check it against the Claude Code permissions docs, and confirm with one allowed and one denied command.

**Harnesses that read `AGENTS.md` natively, or any other harness**
- Invoke a command with the prompt "Follow workflow/commands/<name>.md.", or the harness's own custom-command mechanism if it has one (record which in its section). Codex reads AGENTS.md natively. If the harness has sub-agents, map the tiers to them. Otherwise use single-agent mode. Without native worktree isolation, the Orchestrator creates worktrees itself (harness.md); check that the harness lets sub-agents work in that location without permission prompts.

**Single-agent mode** (no sub-agents, small context windows, local models)
- `build` handles **one plan per session**, always `sequential`: run recover.md, write the plan, implement it, verify, commit, then exit. The single agent is also the Orchestrator, so it writes real IDs directly instead of proposed entries. It keeps `caveman` on throughout, loads `ponytail` while planning and implementing, and turns `ponytail` off for the review pass. If the harness can clear context between writing and implementing the plan, do so. Disk carries everything over. Do the plan review after clearing context if possible; otherwise do it as a separate pass, following the Reviewer brief strictly.
- Restarting the agent after each session can be automated (§7, Automatic resume).
- With small models, keep plans to about 5 tasks and give the strong tier to the best model available.

## 7. Optional add-ons

- **Automatic resume** (off by default). `build` is safe to re-run at any point (`workflow/commands/recover.md`), so a shell loop or a scheduled task can start it again after a usage reset, until it reports a stop condition other than "usage running low" or "session budget reached". Set it to `on` in harness.md; that also enables the Orchestrator's session budget. Leave it off until a few supervised runs look right: it spends quota unattended.
- **Obsidian.** For a readable graph and a status view. Bootstrap sets it up when the human uses Obsidian (§3 Stage A step 6).
  - **Vault:** open `workflow/` as the vault, so it contains only workflow files. `workflow/.obsidian/` is gitignored: it's viewer preference, and Obsidian rewrites it constantly.
  - **Config** (written by bootstrap; if Obsidian ignores it, set the same by hand in Settings): links in Markdown format with relative paths; excluded files `templates/`, `commands/`, `skills/`, `WORKFLOW.md`; graph colour groups by folder for `docs/`, `plans/`, `progress/`, `decisions/`, `questions/`, `audits/`.
  - **Graph:** with the link policy (AGENTS.md §6 Links), the global graph shows overview → phases → plans → progress, with decisions and questions attached to the plans that use them. For navigating, use the local graph at depth 1–2 around one plan.
  - **Status:** `workflow/dashboard.base` (Obsidian Bases, a core plugin) with table views over frontmatter: plans by phase and status (`type: plan`), open questions (`type: question`, `status` not `resolved`), active decisions (`type: decision`), audits (`type: audit`). Dataview is an alternative if preferred. The plain indexes remain the contract for agents.
- **Tier-2 tools** (off by default). List them in stack.md and enable them in harness.md. Examples:
  - web: a headless browser with screenshots
  - APIs: HTTP probes
  - CLIs: runs against fixtures
  - native apps: a UI test runner, simulator screenshots, or computer-use tools
  - graphics: render to a file and inspect it
