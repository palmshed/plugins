# code-review

Extremely strict maintainability review for abstraction quality, file size, and spaghetti-condition growth.

## When to use

Run this skill when you want a deep code quality audit or an especially harsh maintainability review. Use it before merging significant changes, during refactoring, or when you suspect technical debt is accumulating.

This is stricter than a standard code review. It will flag things a normal review would let pass.

## What it does

Reviews the current branch's changes for:

- File size and complexity growth
- Abstraction quality: are modules doing one thing?
- Spaghetti conditions: deeply nested logic, tangled control flow
- Function length and cognitive complexity
- Module responsibility boundaries
- Naming clarity and consistency
- Unnecessary indirection

## Inputs

The diff of the current branch against its base.

## Expected outputs

A severity-rated list of findings across five categories:

- **Critical** — Must fix before merge
- **High** — Should fix before merge
- **Medium** — Fix if scope allows
- **Low** — Improvement opportunity
- **Informational** — Style or preference

Each finding includes the location, what is wrong, and a concrete fix.

## Limitations

- Focuses on structural quality, not correctness or security
- Does not measure performance
- Strict by design — will flag things that are fine in context
- Does not replace domain-specific review

## Install

```sh
mull plugin install code-review
```
