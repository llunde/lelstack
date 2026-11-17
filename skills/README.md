# skills

Skills I author, each in its own folder with a `SKILL.md`. Third-party skills aren't copied here; see [Third-party skills](#third-party-skills).

| Skill | What it is |
|---|---|
| [umbraco-mcp](umbraco-mcp/SKILL.md) | Umbraco CMS structure and content through the Umbraco Developer MCP server: setup, write loop, value shapes, gaps (Umbraco 17) |
| [harvest](harvest/SKILL.md) | Run by hand: mines a project for proven learnings and drafts them here as skill or workflow changes, uncommitted |
| [check](check/SKILL.md) | Run by hand: correctness, over-engineering and comment review of a diff in one numbered list. gandalf's reviewer |
| [pr-text](pr-text/SKILL.md) | Branch name, commit message and PR description for the current diff. gandalf's commit and PR text |

## Third-party skills
Installed at user level, not vendored. Pins are the folder hashes from the `skills` CLI lockfile (`~/.agents/.skill-lock.json`) when last checked.

| Skill | Source | Used by | Pin |
|---|---|---|---|
| caveman | [juliusbrussee/caveman](https://github.com/juliusbrussee/caveman) `skills/caveman` | elrond (required), gandalf (optional) | `efae5ae` |
| ponytail | [dietrichgebert/ponytail](https://github.com/dietrichgebert/ponytail) `skills/ponytail` | elrond (required), gandalf (optional) | `cb6e534` |
| ponytail-review | same repo, `skills/ponytail-review` | elrond (required), `check` | `dc6d966` |

## Linking check and pr-text from lelstack
gandalf pins copies of both into each instance, so it works without them installed. Link them at user level when you want to run them by hand, or want gandalf to use the lelstack copies instead of its pinned ones. Then a `git pull` in lelstack updates them everywhere.

**Fresh machine** (nothing installed yet):

```sh
L=<path to lelstack>
for s in check pr-text; do
  ln -s "$L/skills/$s" ~/.agents/skills/$s
  ln -s ~/.agents/skills/$s ~/.claude/skills/$s
done
```

**Replacing existing copies** in `~/.agents/skills/` with links:

1. See what differs, so local edits aren't lost (move anything worth keeping into lelstack first):
   ```sh
   L=<path to lelstack>
   for s in check pr-text; do diff -r ~/.agents/skills/$s "$L/skills/$s"; done
   ```
   The lelstack `pr-text` uses a neutral ticket example (`ABC-128`); otherwise they should match.
2. Swap each folder for a link, keeping the old one aside until the link works:
   ```sh
   for s in check pr-text; do
     mv ~/.agents/skills/$s ~/.agents/skills/$s.bak
     ln -s "$L/skills/$s" ~/.agents/skills/$s
   done
   ```
3. Claude Code reads `~/.claude/skills/`. If `~/.claude/skills/<name>` is already a link to `~/.agents/skills/<name>`, it follows the new link with no change. If it's a real folder, or missing, replace it:
   ```sh
   for s in check pr-text; do
     [ -L ~/.claude/skills/$s ] || { rm -rf ~/.claude/skills/$s; ln -s ~/.agents/skills/$s ~/.claude/skills/$s; }
   done
   ```
4. Check: `ls -l ~/.agents/skills/check ~/.claude/skills/check` shows the links, and `/check` in a new session runs. Then delete the backups: `rm -rf ~/.agents/skills/check.bak ~/.agents/skills/pr-text.bak`.

## Harvesting a project
When a project taught something worth keeping, run harvest from any harness:

```sh
ln -s <lelstack>/skills/harvest ~/.agents/skills/harvest   # once; also link into ~/.claude/skills for Claude Code
```

Then, in the project: `/harvest lelstack: <lelstack> focus: <topic>` (Codex: `$harvest …`), or in any harness: "Follow `<lelstack>/skills/harvest/SKILL.md` for project `<path>`". Review the result with `git diff` in lelstack.

## How they're used
- **In elrond:** bootstrap reads only each skill's frontmatter, copies the ones that match the project's stack into `workflow/skills/<name>/` and records them in `workflow/harness.md` (SPEC.md §0, Skill library). Skills with `disable-model-invocation: true` are tools you run yourself and are never selected.
- **Anywhere else:** symlink a folder into your harness's user-level skill folder (e.g. `ln -s "$PWD/<name>" ~/.agents/skills/<name>`), or tell the agent "Follow `<path>/SKILL.md`".

## Writing one
- Frontmatter: `name` (the folder name) and a `description` that says which technology and when to use it, so an agent can judge relevance from it alone.
- `SKILL.md` is short and procedural. Longer reference material goes in separate files in the folder, linked from `SKILL.md`.
- Say which versions it was verified against, and mark anything unproven.
- Staleness: when a skill's `Verified against:` line is a major version or more behind the stack you use it on, treat its version-specific claims as unproven until checked, and harvest the project afterwards to update the skill.
- Technology-specific is fine. Client or project specifics never are: no client or site names, domains, real content, credentials, or content-model details and business rules unique to one project.
- Prefer updating an existing skill over adding a near-duplicate.
