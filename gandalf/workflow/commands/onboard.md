# gandalf-onboard

Gather what gandalf needs to work in the current repo into its project note. Re-run any time to refresh. The repo is read-only here: change nothing in it, and run nothing that writes outside its usual build output.

## Full
1. `workflow/GANDALF.md` §2 Start. Must be inside a git repo below the instance. If the project note exists, this is a refresh: keep `## Learnings`, `notes/`, `rules.md` and the group; update everything else and report what changed.
2. **Gather** (a scout at fast / medium with the list below, or yourself for a small repo). Every fact needs evidence; mark guesses `(guess)`.
   - **Stack and layout:** languages, frameworks and versions, solution or project files, where backend, frontend and tests live, pinned tool versions (`.nvmrc`, `global.json`, `.tool-versions`). At most ten lines.
   - **Commands:** build, run, test, lint and format, from the README, CONTRIBUTING, package manifests, Makefile or scripts, and CI config. Note the working directory for each.
   - **Git:**
     - host and repo from `git remote -v` (strip any credentials from the URL);
     - default branch (`git symbolic-ref refs/remotes/origin/HEAD`);
     - base branch for PRs: which of `develop`, `main`, `master` exist, and where recent merges land (`git log --merges --first-parent -20 --format=%s origin/<branch>`);
     - branch naming, from merge subjects and `git branch -r`;
     - commit style, from `git log --no-merges -30 --format=%s` (Conventional Commits? issue keys, where?);
     - PR template: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/pull_request_template.md`, `.azuredevops/pull_request_template.md`, and the same names in upper case;
     - PR CLI: GitHub → `gh` installed; Azure DevOps → `az` installed and `az extension show --name azure-devops` (local only); GitLab → `glab`. Don't run anything that contacts the host.
   - **Agent instruction files** in the repo: `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules/`, `.cursorrules`, `GEMINI.md`, at the root and in subfolders. List each path with a gist (at most three lines) of what changes how to work here. Gandalf respects them (GANDALF.md §3).
   - Nothing secret (GANDALF.md §4): no connection strings, keys, private hostnames, people.
3. **Verify commands:** run the build and the linter. Run tests only when they look self-contained; ask first when they need a database, network, a running app or secrets, or will take long. Mark each command `ok <date>`, `fails: <decisive line>` or `not run: <why>`.
4. **Group:** suggest a name from this repo's own parent folder (nested layouts) or its remote's organisation. Ask the human to confirm, change or leave it empty. Never list existing groups (GANDALF.md §4); if the name matches a folder in `red-book/groups/`, join it, else create it from `workflow/templates/group.md` with an empty `rules.md` from `workflow/templates/rules.md`.
5. **Ask** in one round what's still unclear: the base branch when both `develop` and `main` look live, commands that failed, the group.
6. **Write** the project note from `workflow/templates/project.md` (≤80 lines), and `rules.md` from `workflow/templates/rules.md` if it's missing. Set `onboarded:` to today.
7. Commit the instance (`workflow/GANDALF.md` §10): `onboard(<slug>)`. Report in at most ten lines: stack, commands with their status, base branch and conventions, PR CLI, instruction files found, anything unverified.

## Light
Used from intake when the human doesn't want a full onboarding now. Steps 1, 2 (Git and Commands only, from manifests and git), 6 and 7, with `onboarded: light` and every command marked `not run: light onboarding`. Intake treats those commands as best guesses. A later full onboarding replaces it.
