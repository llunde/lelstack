# gandalf-rule

Add, list, change or remove rules. Rules belong to the instance, not the session: they take effect at once, also in this session, and every command re-reads them (GANDALF.md §2, §3).

**Arguments**
- `<text>`: add a **project** rule (inside a repo). Project is the default so that a client-specific rule never reaches other projects by accident.
- `global: <text>` · `group: <text>`: add at that scope. Outside a repo, only `global:` and `list` work.
- `list`: the rules that apply here, in precedence order.
- `edit <ID> <new text>` · `remove <ID>` · `lock <ID>` · `unlock <ID>`.

**Files:** global `red-book/rules.md` (IDs `G<n>`), group `red-book/groups/<group>/rules.md` (`C<n>`), project `red-book/projects/<slug>/rules.md` (`P<n>`). One rule per line: `- **P3** Use the shared validation helpers in forms.` and, for a locked rule, a trailing `` `locked` ``.

## Steps
1. `workflow/GANDALF.md` §2 Start, steps 1 and 2 only. `group:` without a group: say so and offer to set one with onboard.
2. **Add:**
   - Write it as one short, imperative line.
   - Compare with every rule that applies here: a duplicate isn't added (say which rule covers it); a conflict is shown side by side, and the human decides: keep both (precedence decides, show the outcome), replace, narrow one, or lock one.
   - `global:` or `group:`: pipe the text into `workflow/scripts/leakcheck -` (for a group rule `leakcheck --except <group_dir> -`). A hit means it names a project or client: propose project scope instead.
   - ID: the next number in that file; never reuse a removed one.
3. **Lock** only global and group rules (a project rule already wins over everything but locks). Lock when the human says it must hold everywhere below it.
4. **Edit / remove / unlock:** by ID, in the file it lives in. Show the line before and after.
5. Precedence for `list` and conflicts: locked global > locked group > project > group > global (GANDALF.md §3).
6. Commit the instance (`workflow/GANDALF.md` §10): `rule(<scope>): <ID> <add|edit|remove|lock|unlock>`.
7. Report the rule line and its scope. If a gandalf command is in progress in this session, say from which of its steps the rule now applies, and follow it from there.
