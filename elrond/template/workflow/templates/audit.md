---
type: audit
scope: phase <n> | final | adhoc
date: YYYY-MM-DD
audited_through: <commit SHA>
gate: check-full pass (<n> tests) | static-only
---

# Audit YYYY-MM-DD — <scope>

Phase: <link to the phase doc>

## Summary
- Sections: <...> · Coverage gaps: <what wasn't fully read, and why>
- Counts (new in this audit): critical n · high n · medium n · low n · governance n
- Collected from plan reviews: <plan NNN #n, ...> · medium n · low n (not copied; planned in step 5)
- Earlier remediations re-verified: <held / regressed: ...>

## Findings
### F1 — <title> · <severity> · <lens: correctness | quality | lean | plan> · <category>
- Location: <path:line>
- Problem and concrete failure scenario:
- Recommended fix:
- Plan: NNN

## Final scope only
<feature audit table, quality, README, shippability (see workflow/commands/audit.md)>

## Retro
<filled in by the Retro step: observations added n · proposals Q-NNN ... · for the workflow n>

## Plans spawned
<filled in by the Plans step: links to the plan files, or "none">
