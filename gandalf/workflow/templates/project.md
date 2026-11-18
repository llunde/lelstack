---
type: project
path: <repo path below the workspace root>
group: <group name, or empty>
host: <github | azure-devops | gitlab | other | none>
remote: <org/repo, no credentials>
base_branch: <branch PRs target>
pr_cli: <gh | az | glab | none>
onboarded: <YYYY-MM-DD | light>
last_retro:
---
# <slug>

Up: <[[groups/<group>/<group>]], or [[gandalf]] without a group> · Rules: [[projects/<slug>/rules]]

## Stack and layout
<≤10 lines: languages, frameworks and versions, where things live, pinned tool versions>

## Commands
| What | Command (working dir) | Status |
|---|---|---|
| build | | ok YYYY-MM-DD · fails: … · not run: … |
| test | | |
| lint | | |
| run | | |

## Git
- Base branch: <and why, if not obvious>
- Branches: <naming convention, with an example>
- Commits: <style, issue-key placement, language>
- PRs: <template path, title style, draft or ready, language>
- CLI: <gh / az / glab: installed, extension, default org and project> 

## Agent instructions in the repo
<path: gist in ≤3 lines, per file; or none>

## Learnings
<terse bullets: gotchas, things that differ from what you'd expect. ≤15; detail goes to notes/>

## Notes
<[[projects/<slug>/notes/<topic>]] per note (from workflow/templates/note.md), one line each; or none>
