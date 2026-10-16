---
type: decision
id: D-NNN
status: active           # active | superseded
date: YYYY-MM-DD
source: <bootstrap | Q-NNN | plan NNN | audit YYYY-MM-DD F<n> | human>
supersedes:              # D-NNN, if this replaces an earlier decision
superseded_by:           # D-MMM, set when a later decision replaces this one
---

# D-NNN — <title>

- Source: <link to the question, plan or audit report; or "bootstrap" / "human">
- Decision: <one or two sentences>
- Why: <one sentence>
- Guard: <optional: invariant to preserve, the test that pins it, "broke twice before: ...">

<!-- One file per decision (`D-NNN-slug.md`, from workflow/templates/decision.md; the slug carries the topic, so a search on file names finds it), plus the table in workflow/decisions/index.md. Scan the table or search the folder by topic, then open only the decisions that apply. Elsewhere, link a decision by its ID instead of restating it. Decisions are never deleted or rewritten. To change one, add a new decision with `supersedes: D-NNN`, set the old one's `status` to `superseded` with `superseded_by`, and update both index rows. -->
