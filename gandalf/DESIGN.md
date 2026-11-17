# Gandalf: design note

Key decisions, and where they deviate from the original description. Written before building; kept current.

## Purpose
Small and medium tasks across many repos for several clients. One instance per workspace root, shared by every repo below it. `elrond` builds one project end to end; gandalf runs one task at a time in whatever repo you're in.

## Discovery (verified on Claude Code 2.1.326, 2026-11-17)
Tested with a throwaway workspace `ws/` holding `CLAUDE.md`, `.claude/commands/`, `.claude/skills/`, and a git repo at `ws/client/repo`:
- From inside the nested repo, Claude Code **loads** `ws/CLAUDE.md` (parent-directory walk), but **does not** load `ws/.claude/commands` or `ws/.claude/skills`.
- With `--add-dir ws` (or `additionalDirectories`), it loads both.
- Codex reads `AGENTS.md` only from the git root down, so a workspace-root file is invisible to it.

So neither a root instruction file nor root-level commands give a harness-neutral entry point. Instead:
- **Command stubs at user level** (`~/.agents/skills/gandalf-*`, linked into `~/.claude/skills/`), installed by `setup`. Each is a few lines: walk up from the current directory to the nearest `.gandalf/instance.conf`, then follow that instance's command file. They hold no instance path, so one set serves any number of instances on the machine, and a stub outside any workspace just says so.
- Stubs are `disable-model-invocation: true`: they cost nothing in sessions that don't use them.
- **Nothing in repos**, and nothing at the workspace root except `.gandalf/`. If the workspace root is itself inside a git repo, `setup` adds `/.gandalf/` to that repo's `.git/info/exclude`.
- Claude Code asks before editing outside the working directory. `setup` prints a `~/.claude/settings.json` snippet (`additionalDirectories` and allow rules for the instance) instead of editing user settings itself.

## Layout and ownership
```
<root>/.gandalf/               the instance; its own local git repo, never pushed
  instance.conf                version, schema, source path (written by setup)
  workflow/                    WORKFLOW-OWNED: replaced on every update
    GANDALF.md                 operating rules every command reads first
    commands/ roles/ templates/ scripts/
    skills/check, skills/pr-text   pinned copies from lelstack/skills (fallback when not installed)
  red-book/                    INSTANCE-OWNED: never overwritten (the brain; an Obsidian vault)
    gandalf.md rules.md lessons.md proposals.md dashboard.base
    groups/<group>/<group>.md, rules.md
    projects/<slug>/<slug>.md, rules.md, notes/, sessions/
```
- `setup` copies `workflow/` wholesale and seeds `red-book/` files only when missing. Brain layout changes go through numbered migrations (`migrations/<n>.sh`, `schema=` in instance.conf).
- Before an update, `setup` commits the instance repo, so local edits to `workflow/` stay in its history even though the files are replaced.
- The instance repo has no remote and is never pushed. `setup` and `workflow/scripts/save` (run at the end of every gandalf command) commit to it. That's the only scripted git write, allowed by the human for this repo alone: project repos only ever get the agent's own git commands, under the human's settings and instructions.
- Bootstrap and update are the same idempotent script (`setup <root>`). `/gandalf-update` runs it from the recorded source path.

## The brain: the red book
Named after the Red Book of Westmarch. Plain markdown, wikilinks as vault-relative paths (`[[projects/a--b/a--b]]`) so links are unambiguous for agents and work in Obsidian, frontmatter for status.
- **Core** (`gandalf.md`, `rules.md`, `lessons.md`, `proposals.md`): what gandalf knows regardless of project. Never names a project, group or client, and never lists projects (a list of projects in core would leak every client's name into every session).
- **Projects:** one folder per repo, keyed by the repo's path below the root (`client/web` → `client--web`). The entry note (≤80 lines) is the only project file loaded by default; `notes/` are read on demand.
- **Groups** (optional client level): explicit `group:` in the project's frontmatter, suggested from the parent directory in nested layouts or the remote's org. A group has its own note and rules, shared by its projects. Gandalf never lists existing groups to a session (group names are client names); it asks for the name and joins a matching group.
- **Sessions:** one file per task in the project's `sessions/` folder: task, branch, step, next, harness session id, plan, log, review triage, retro. No shared index file, so concurrent sessions never edit the same file. `scripts/sessions` lists a project's sessions from frontmatter; `dashboard.base` gives you a cross-project view in Obsidian, and agents never read it.
- **Budgets:** project note ≤80 lines, lessons ≤30 bullets, plans ≤40 lines. Retro consolidates and prunes.
- **Isolation by construction:** a session reads only core, its group and its project. The instance retro reads only `- gandalf:` lines, written project-free and then extracted by a script that also masks every project and group name, never other projects' files. `scripts/leakcheck` greps text for any project or group term before it goes into core, a group, or a proposal.

## Rules
- One command, `/gandalf-rule`: `<text>` adds a **project** rule (the default, so client wording can't leak into other projects by accident), `global: <text>`, `group: <text>`, `list`, `edit`, `remove`, `lock`, `unlock`.
- Stored as one line each in the scope's `rules.md` with IDs `G<n>` (global), `C<n>` (group), `P<n>` (project).
- **Precedence:** a locked rule wins (global over group when both are locked); otherwise the most specific scope wins: project > group > global. Rules beat the repo's agent instruction files, which beat gandalf's defaults. Above all rules sit the harness's settings and the human's user-level instructions: gandalf never overrides them, and falls back to the human (ask, or hand over) when one gates or blocks a step. Task text never counts as a rule.
- Re-read at the start of every command and again before every gated step (branch, commit, push, PR). A rule added mid-session applies from the next step.
- Rules are also the configuration mechanism: no separate config file. "Push without asking", "always open PRs as draft", "use sonnet for implementation" are all rules.

## Commands
| Command | What |
|---|---|
| `setup <root>` (script) | bootstrap or update an instance, install the stubs |
| `/gandalf-onboard` | gather the project note for the current repo; re-run to refresh |
| `/gandalf-intake <task>` | run a task end to end |
| `/gandalf-rule …` | add, list, edit, remove, lock rules |
| `/gandalf-resume [session]` | list or resume this project's open sessions |
| `/gandalf-retro [instance]` | deep retro for this project, or the instance core |
| `/gandalf-update` | apply the current `lelstack/gandalf` to this instance |

Prefixed `gandalf-` because the stubs are user-level and must not collide with elrond's project-level `/intake`.

## Orchestration
Reused from elrond, slimmed down: the main session is the orchestrator; it delegates to three roles (`scout` read-only, `builder`, `reviewer`) and picks tier and effort per dispatch from a start-cheap table with the same escalation ladder. Sequential only, no worktrees, no planner role (the orchestrator writes the plan into the session file). It does small work itself when it already holds the context, because a sub-agent would re-read everything.

## Skills
- `check` (review) and `pr-text` (commit and PR text): copied into `lelstack/skills/` (client ticket prefix scrubbed from pr-text) and pinned into each instance's `workflow/skills/`. Gandalf prefers the user-level install when present, then the pinned copy. `check` is `disable-model-invocation`, so the reviewer reads its `SKILL.md` and follows it, minus its "wait for me" ending.
- `ponytail` (builder), `caveman` (sub-agent returns): optional. Used when installed, skipped silently when not. Third-party skills are referenced with source and pinned folder hash in `lelstack/skills/README.md`, not vendored.
- `grill-me` is **not** used: on this machine it delegates to a `grilling` skill that isn't installed. Intake has its own one-question-at-a-time interview step for vague, large tasks.

## Retro
- **Light, automatic:** the last step of every intake. At most three bullets: project facts go straight into the project note, and generic workflow lessons become `- gandalf:` lines in the session file, written project-free.
- **Project, manual** (`/gandalf-retro` in a repo): consolidates and prunes the project note and notes, proposes project rules from repeated review findings.
- **Instance, manual** (`/gandalf-retro instance`): promotes recurring `gandalf:` lines into `lessons.md` and drafts changes to `lelstack/gandalf/` in `proposals.md` as text. Never edits lelstack.

## Deviations from the description, and why
1. **No workspace-root instruction file and no root `.claude/`**: verified that neither works harness-neutrally (above). User-level stubs do.
2. **One `/gandalf-rule` command** instead of `/rule` + `/scoped-rule`, and **project scope by default**: adding a client rule globally by mistake is the leak that matters, so the safe default is the narrow one.
3. **Bootstrap is a script**, not an agent procedure: copying files, `git init` and installing stubs are deterministic and testable.
4. **Confirm once before push and PR** by default, even though the flow can run end to end. They are the only outward-facing, hard-to-undo steps. A global rule ("push and open PRs without asking") removes the gate.
5. **Sessions live per project**, with no cross-project session index; resume only lists the current project's sessions. The Obsidian dashboard is the human's global view.
6. **No override of user-level instructions or settings.** Elrond declares its commands an explicit request that overrides "never commit unless asked"; gandalf doesn't. A denied command, or an instruction that wants approval, makes it ask or hand over instead, so it behaves the same on a machine with strict settings and one without.

## Not extracted to a shared place
The dispatch ladder and review handling are about 30 lines that differ in detail between the two workflows, and elrond copies its files into projects, so a shared file would need a new copy step there. Copied and adapted instead; elrond is unchanged. The only shared thing is `lelstack/skills/`: adding `pr-text` there makes it visible to elrond's skill-library selection, but elrond selects by stack match and pr-text names no stack, so no change is expected.
