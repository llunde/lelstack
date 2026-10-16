---
type: progress
plan: NNN
created: YYYY-MM-DD
---

# Progress NNN — <title>

Plan: [NNN](../plans/NNN-slug.md)

## Built
<what was built, terse (AGENTS.md §6 Voice); a reviewer new to the code can follow it>

## Verification
- Model: <tier/effort, plus any escalation and why>
- check: pass (<n> tests) | static-only
- Tier 2: <what was observed, and how>
- Tier 3: <acceptance items proposed (new-A…) | none>

## Review
<level (full / light / skip) and reviewer tier>

<the merged table written by the workflow-review skill>

| # | Severity | Lens | Location | Finding and concrete case | Fix | Status |
|---|---|---|---|---|---|---|
<Status: open | fixed | open → phase audit | open → plan MMM | → audit YYYY-MM-DD F<n>. "Open" means exactly `open`.>

## Decisions and deviations
<D-NNN added; any deviation from the plan, and why>

## Notable files
<path — what changed (the full list is in git)>

## Follow-ups
<deferred items and where they went>

## Proposed entries
<new-Q1 / new-D1 / new-A1: one short block each (question + default in use / decision + why / acceptance steps + expected). The Orchestrator turns them into real IDs and writes the IDs back here.>

## Requested shared edits
<hotspot or out-of-scope file changes this unit needs, for the Orchestrator to apply: path — exact change>

<!-- A parallel slice writes this template as workflow/progress/NNN-slug.<X>.md (plan: NNN-X), with a ## Tasks checklist copied from its slice of the plan. A whole-plan worktree unit adds the same ## Tasks checklist to NNN-slug.md. At plan close the Orchestrator folds the slice notes into NNN-slug.md and deletes them. -->
