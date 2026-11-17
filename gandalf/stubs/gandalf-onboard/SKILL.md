---
name: gandalf-onboard
description: "Gandalf: onboard the current repo (stack, commands, git and PR conventions) into its project note. Re-run to refresh."
disable-model-invocation: true
metadata:
  opencode/autoinvoke: false
---
<!-- gandalf-stub: installed by lelstack/gandalf/setup and replaced on update; don't edit. -->
Find the gandalf instance: the nearest folder at or above the current directory that has `.gandalf/instance.conf`. This prints it:

    d=$(pwd -P); while [ "$d" != / ] && [ ! -f "$d/.gandalf/instance.conf" ]; do d=$(dirname "$d"); done; echo "$d"

If it prints `/`, say there's no gandalf instance at or above this directory (one is created with `lelstack/gandalf/setup <workspace root>`) and stop.

Otherwise follow `<that folder>/.gandalf/workflow/commands/onboard.md` exactly. Paths in it are relative to `<that folder>/.gandalf/`. Arguments: $ARGUMENTS
