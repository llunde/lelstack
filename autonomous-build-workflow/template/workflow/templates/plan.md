---
type: plan
id: NNN
title: <title>
phase: <n>
status: planned        # planned | in-progress | done | superseded
mode: delegated        # delegated | interactive
execution: sequential  # sequential | parallel-shared | parallel-worktree
review: light          # full | light | skip (workflow/commands/plan.md)
ponytail: full         # full | lite (AGENTS.md §6; never ultra)
model: standard/medium # Executor tier/effort proposal; higher only with a reason (build.md §1)
depends_on: []         # plan IDs that must be done first
owns: []               # paths/globs this plan may edit (union of its slices)
source: <workflow/docs/NN §x | Q-NNN | audit YYYY-MM-DD F<n> | A-NNN | change YYYY-MM-DD | drift YYYY-MM-DD | plan NNN review #n | plan NNN (partial close)>
adopts: []             # SHAs of commits made outside the loop that this plan adopts
created: YYYY-MM-DD
completed:
---

# NNN — <title>

> Self-contained brief. An implementer with no other context must be able to build this from it alone.

## Goal
<two or three sentences>

## Context
- Requirements, inlined with source references: ...
- Constraints that apply (AGENTS.md §4), inlined: ...
- Source: <link to the phase doc, question or audit report>
- Depends on: <links to plans, or none>
- Decisions that apply: <[D-NNN](../decisions/D-NNN-slug.md) — one line each>
- Shared contract (types, interfaces, files this must match): ...
- Reuse (ponytail ladder): <existing helpers and paths, stdlib, native platform features, installed dependencies each task builds on instead of new code>
- Tests (AGENTS.md §9): <none | test — flow / critical / regression — why>
- Skills / tools to consult: ...

## Scope
- In: ...
- Out: ...

## Execution and review
<execution: one line on why. Parallel only if the slices own disjoint paths and the work is big enough to pay for coordinating it.>
<review: full | light | skip — one line on why (workflow/commands/plan.md).>
<ponytail: full, or lite with one line on why.>
<model: Executor tier/effort, the build.md §1 starting point unless a concrete reason from that table; one line on why.>

## Tasks
- [ ] 1. <task> → verify: <how> (tier 1/2/3)
<!-- Hotspot changes the plan already knows it needs go under "### Hotspots"; the Orchestrator applies them before dispatch.
     parallel: "### Contract — owns: ..." first (lands before any slice starts), then
     "### Slice A — owns: <paths>", "### Slice B — owns: <paths>". Hotspot changes a slice needs are listed under that slice for the Orchestrator to apply. -->

## Acceptance criteria
| # | Criterion | Tier | How verified |
|---|---|---|---|

## Proposed entries
<!-- Planner only: new questions, decisions and acceptance items as `new-Q1`, `new-D1`, `new-A1` with the default in use. The Orchestrator replaces each key with its real ID here (build.md §5). -->
