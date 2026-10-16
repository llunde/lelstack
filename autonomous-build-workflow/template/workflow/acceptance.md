# Human acceptance — <project>

Checks only a human can perform (tier 3). The loop appends rows. The human runs them and fills in Result. A `fail` row needs a note; the next `build` turns it into a plan with `source: A-NNN` and writes `→ plan MMM` in the Note. `Blocking: yes` holds the next phase until the row passes.

| ID | Phase | Plan | Needs | Steps | Expected | Blocking | Result | Date | Note |
|---|---|---|---|---|---|---|---|---|---|
| A-001 | 1 | 001 | <env> | <exact steps> | <observable result> | no | pending | | |
