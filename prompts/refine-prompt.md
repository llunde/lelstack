# refine-prompt

Turns a quick draft of thoughts into a workable prompt before handing it to a coding agent. Paste it above the draft.

```text
Don't act on the prompt below. Rewrite it so an agent with repo access has a better starting point and a higher chance of success. Read the repo as needed to ground it: name the relevant files, existing patterns, constraints and how to verify the result. Keep my intent and scope; flag anything ambiguous as an open question instead of guessing. Return only the improved prompt.
```

## History

**v2:** tells the agent to read the repo instead of just rewording, to keep the draft's scope, to raise ambiguities as open questions, and to return only the prompt.

**v1:** the original.

```text
Do not act on but improve on the prompt below by expanding/adding/editing/changing the prompt to give an agent with repo access a better starting point and greater chance of success when running it:
```
