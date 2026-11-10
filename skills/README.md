# skills

Skills I author, each in its own folder with a `SKILL.md`. Third-party skills (caveman, ponytail, ponytail-review) aren't copied here; they're installed at user level, see [autonomous-build-workflow](../autonomous-build-workflow/README.md#1-install-the-required-skills-once).

| Skill | What it is |
|---|---|
| [umbraco-mcp](umbraco-mcp/SKILL.md) | Umbraco CMS structure and content through the Umbraco Developer MCP server: setup, write loop, value shapes, gaps (Umbraco 17) |
| [harvest](harvest/SKILL.md) | Run by hand: mines a project for proven learnings and drafts them here as skill or workflow changes, uncommitted |

## Harvesting a project
When a project taught something worth keeping, run harvest from any harness:

```sh
ln -s <lelstack>/skills/harvest ~/.agents/skills/harvest   # once; also link into ~/.claude/skills for Claude Code
```

Then, in the project: `/harvest lelstack: <lelstack> focus: <topic>` (Codex: `$harvest …`), or in any harness: "Follow `<lelstack>/skills/harvest/SKILL.md` for project `<path>`". Review the result with `git diff` in lelstack.

## How they're used
- **In the autonomous build workflow:** bootstrap reads only each skill's frontmatter, copies the ones that match the project's stack into `workflow/skills/<name>/` and records them in `workflow/harness.md` (SPEC.md §0, Skill library). Skills with `disable-model-invocation: true` are tools you run yourself and are never selected.
- **Anywhere else:** symlink a folder into your harness's user-level skill folder (e.g. `ln -s "$PWD/<name>" ~/.agents/skills/<name>`), or tell the agent "Follow `<path>/SKILL.md`".

## Writing one
- Frontmatter: `name` (the folder name) and a `description` that says which technology and when to use it, so an agent can judge relevance from it alone.
- `SKILL.md` is short and procedural. Longer reference material goes in separate files in the folder, linked from `SKILL.md`.
- Say which versions it was verified against, and mark anything unproven.
- Technology-specific is fine. Client or project specifics never are: no client or site names, domains, real content, credentials, or content-model details and business rules unique to one project.
- Prefer updating an existing skill over adding a near-duplicate.
