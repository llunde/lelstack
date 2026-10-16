# Harness — <project>

Agent-platform specifics; the rest of the workflow is harness-neutral. Every agent identifies its harness at session start and uses that harness's section. No section for your harness: stop, and run `harness` (workflow/commands/harness.md) from it.

## Shared settings
| Setting | Value |
|---|---|
| Max parallel workers | 3 |
| Usage model | <e.g. subscription, token-bound: prefer standard tier for bulk work> |
| Automatic resume | off · on (WORKFLOW.md §7) |
| Orchestrator session budget | <after each phase audit, or after 6 closed plans; applies only when automatic resume is on> |
| Tier-2 tools enabled | none |
| Skills / plugins (guidance only) | <name → role / phase that uses it> |

## <Harness, e.g. Claude Code>
Added YYYY-MM-DD by <bootstrap | harness>.

| Setting | Value |
|---|---|
| Rulebook loading | <e.g. CLAUDE.md imports AGENTS.md; native AGENTS.md> |
| Command invocation | <e.g. `/build`; or the prompt "Follow workflow/commands/build.md"> |
| Sub-agents | <yes (nesting: n levels) · no → single-agent mode> |
| Tiers strong / standard / fast | <e.g. Claude Code: opus / sonnet / haiku · Codex: sol / terra / luna> |
| Effort per dispatch | <yes: levels … · no: harness default> |
| Worktrees | <harness-native (e.g. Claude Code Agent tool isolation) · Orchestrator-created: `git worktree add <location>/<unit> -b wt/<unit> <integration branch>`> |
| Worktree location | <e.g. `.claude/worktrees/` or `../<repo>.worktrees/`; sub-agents must be able to edit there without permission prompts. If inside the repo: gitignored and excluded from test discovery, lint, search and file watchers> |
| Review: correctness lens | <built-in review an agent can start read-only on a range or paths, e.g. Claude Code `/code-review <effort> <target>` (never `--fix`) · or `fallback` (workflow-review SKILL.md, Fallback bug hunt)> |
| Permissions | <baseline applied (WORKFLOW.md §6): where, e.g. `.claude/settings.json`; confirmed with one allowed and one denied command> |

| Skill | Status | SKILL.md path |
|---|---|---|
| caveman | present | <path> |
| ponytail | present | <path> |
| ponytail-review | present | <path> |
| workflow-review | in repo | workflow/skills/workflow-review/SKILL.md |

## <Next harness, same rows>

Use aliases that track the latest model in a tier, not pinned versions. If fewer models are available, adjacent tiers share one.
