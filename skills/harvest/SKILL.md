---
name: harvest
description: Mine a project for proven, reusable learnings and draft them into the lelstack repo as new or updated skills or workflow improvements, uncommitted, with client specifics stripped. Only run when invoked.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: false
---

# harvest

Turn what one project proved into reusable skills or workflow changes. The project is read-only. lelstack gets drafts only: never commit or push.

## Inputs
Take them from the text after the skill name (`$ARGUMENTS` in Claude Code); ask once for what's missing.
- **project:** path (default: the current directory)
- **lelstack:** path to the lelstack repo
- **focus** (optional): a technology or topic, e.g. "the CMS's MCP server". Without one, harvest everything that qualifies.

## 1. Prepare
1. **Target.** In lelstack, run `git status`. Not clean: stop and ask. On `main`: `git switch -c harvest/<topic>-<YYYY-MM-DD>`. On another branch: use it and say so. **Fallback** when lelstack isn't reachable or writable: write everything under `./harvest-out/<YYYY-MM-DD>/` in the current directory (never inside the project), mirroring lelstack's paths, and say so.
2. **Know what exists.** Read `skills/README.md` (the rules), the frontmatter of every `skills/*/SKILL.md`, and, when a learning may touch the workflow, the `autonomous-build-workflow/` file it would change.
3. **Deny-list.** Before mining, list the project's specifics: client, organisation, site and product names; domains and hostnames; people; repo and folder names; content-model aliases and type names; content keys and GUIDs; credential values; distinctive real content. Sources: README, brief and docs, config, the git remote. Keep the list in chat, never in lelstack.

## 2. Mine
Read in this order and leave a source once it yields nothing new:
- **Workflow projects:** `workflow/decisions/` (active only), `workflow/retro.md` (`skill`, `repeat` and `friction` rows, "For the workflow"), gap and deviation notes in `workflow/progress/`, `workflow/stack.md` (Known environment symptoms, Environment), audit reports.
- **Any project:** README setup and troubleshooting, `AGENTS.md` / `CLAUDE.md`, tool config (never secret files such as `.env`), and `git log` for fix and workaround commits.
- Briefs and upfront designs state intent, not results. Use them only to find what to check.

For each candidate, note the claim, its evidence (file, decision ID or commit), the versions it applies to, and its proof:
- **proven:** observed working (a decision or progress note citing a run, a passing check), or a failure observed with its error.
- **unproven:** read in source only, assumed, or claimed but never exercised. Keep it only if useful, marked `(unproven)`.
- No evidence: drop it.

## 3. Classify
- **Skill update:** fits an existing skill's description. Edit that skill; prefer this over a new one.
- **New skill:** a technology no skill covers, with at least three proven learnings. Fewer: report it as a candidate, don't create it.
- **Workflow improvement:** helps any project on any stack (often a "For the workflow" line with evidence). Draft the edit in `autonomous-build-workflow/` without technology, tool or project names.
- **Project-only:** depends on this client's content model, business rules or setup. Leave it and list it in the report.

## 4. Write
- Generalize: replace project names, aliases and keys with role words (`a page type`, `<propertyAlias>`, `<key>`). A learning that can't be stated without project specifics is project-only.
- Follow `skills/README.md`: a short procedural `SKILL.md` (when to use, procedure, verify) and reference detail in separate files; a `Verified against:` line with versions and date; `(unproven)` marks.
- Updating a skill: keep its structure; add, correct, or mark superseded what this project disproved. Extend its `Verified against:` line only with what this project ran.
- Add or update the skill's row in `skills/README.md`.
- Never write credentials, or placeholders that look like real ones. Name the variable, not the value.

## 5. Leak check
Before reporting, run these and show the commands and their output:
1. The deny-list against everything changed: `git diff -U0` and untracked files (`git ls-files --others --exclude-standard -z | xargs -0 grep -inE '<terms>'`).
2. GUIDs, e-mail addresses, and URLs other than public documentation: `grep -nE '[0-9a-f]{8}-[0-9a-f]{4}-|@[a-z0-9-]+\.|https?://'` over the same files.
3. If `autonomous-build-workflow/` changed: its added lines against the technology and tool names you harvested.

Fix every hit and re-run until clean, or say why a remaining hit is generic.

## 6. Report
In chat, short:
- the branch (or fallback folder), `git status --short` and `git diff --stat`
- one row per learning: claim · destination (skill / workflow / project-only / candidate) · proof · evidence
- the leak-check result
- a Conventional Commits message, ready to paste
