# testing

Review test coverage, quality, and gaps across your changes.

## When to use

Run this skill when auditing whether a changeset is well-tested. Use it before merging code that adds new features, fixes bugs, changes public APIs, or modifies error handling paths.

## What it does

Reviews the current branch's changes for:

- **Missing coverage**: untested public functions, error paths, edge cases, branch gaps
- **Assertion quality**: vacuous tests, overly broad assertions, missing negative checks
- **Test isolation**: order dependencies, shared mutable state, missing cleanup
- **Test clarity**: unclear names, mixed concerns, magic values, obscured intent
- **Mocking and fakes**: over-mocking, under-mocking, implementation-coupled mocks, missing error injection
- **Flakiness risk**: timing dependencies, system-specific behavior, race conditions
- **Test organization**: unit vs integration placement, reused test utilities
- **Property and fuzz testing**: missing roundtrip tests, missing malformed input tests

## Inputs

The diff of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- Exact location (file and function)
- What is untested or wrong with the test
- What regression could slip through
- Suggested test to add or fix

## Limitations

- Does not measure code coverage percentages
- Does not run tests or detect flakiness at runtime
- Cannot assess test execution speed
- Focuses on test design, not test infrastructure

## Install

```sh
mull plugin install testing
```
