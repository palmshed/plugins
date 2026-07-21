# commit-review

Review commit messages and history for clarity, structure, and usefulness for future readers.

## When to use

Run this skill when preparing to merge a branch or auditing commit quality. Use it to ensure the commit history is readable, bisectable, and useful for someone debugging a regression weeks later.

## What it does

Reviews the current branch's commit history for:

- **Message clarity**: vague subjects, wrong descriptions, missing context
- **Message structure**: missing body, missing issue references, too-long subjects
- **Commit granularity**: too large, too small, mixed concerns, fixup commits
- **History quality**: commits that make code worse then better, dead-end commits, difficult bisect
- **Conventional commits**: missing type prefix, missing scope, inconsistent format

## Inputs

The git log of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- The commit (hash or subject)
- What is wrong with the message or history
- Suggested improvement or rewrite

## Limitations

- Does not analyze code correctness, only message quality
- Cannot determine whether commits should be squashed (depends on merge strategy)
- Does not enforce conventional commits unless the project uses them
- Focuses on readability, not stylistic preferences

## Compatibility

- **Mull version**: 1.0.0 or later
- **Plugin version**: 1.0.0
- **Breaking changes**: None in this version
- **Migration notes**: N/A (initial release)

## Install

```sh
mull plugin install commit-review
```
