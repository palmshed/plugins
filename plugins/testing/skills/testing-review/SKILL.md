---
name: testing-review
description: Review test coverage, quality, and gaps for your changes. Use when auditing whether a changeset is well-tested.
disable-model-invocation: true
---

# Test Quality Review

Use this skill for a test review of the current branch's changes. The goal is to ensure changes are well-tested ~ not to demand 100% coverage, but to catch the cases where tests are missing, misleading, or fragile.

## Core Prompt

> Review the test coverage and quality of the current branch's changes.
> Identify missing tests, weak assertions, and test infrastructure issues.
> For each finding, explain what is untested, why it matters, and what test should exist.
> Be practical: focus on tests that catch real regressions, not coverage metrics.

## Review Categories

### 1. Missing Coverage

- New public functions with no tests
- New error paths without test coverage
- Edge cases not exercised: empty input, max values, zero-length, unicode boundary
- Branch coverage gaps: if/else paths where one branch is never tested
- Integration points where new code interacts with existing code
- Regression tests for fixed bugs that lack a "reproduce before fix" test

### 2. Assertion Quality

- Tests that pass with no assertions (vacuous tests)
- Assertions that check something other than the intended behavior
- Assertions that are too broad (e.g. `result.is_ok()` without checking the value)
- Missing negative assertions: what should NOT happen
- Snapshot tests without review of the snapshot diff

### 3. Test Isolation

- Tests that depend on execution order
- Tests that depend on external state (network, filesystem, env vars) without mocking
- Tests that modify global state without cleanup
- Tests that share mutable fixtures
- Tests that leave side effects for other tests

### 4. Test Clarity

- Test names that do not describe the scenario and expected outcome
- Test functions longer than ~80 lines without clear structure
- Complex setup that obscures what is being tested
- Magic values without explanation
- Mixed concerns: testing multiple unrelated things in one test

### 5. Mocking and Fakes

- Over-mocking: mocking things that could be tested with real implementations
- Under-mocking: making real network or filesystem calls in unit tests
- Mocks that are too tightly coupled to implementation details
- Mocks that return values inconsistent with real behavior
- Missing error injection: mocks that never fail

### 6. Flakiness Risk

- Tests relying on timing or sleep
- Tests relying on system-specific behavior (paths, env, locale)
- Tests with non-deterministic ordering
- Tests that depend on other tests passing
- Tests with race conditions between async tasks

### 7. Test Organization

- Unit tests co-located with the code they test
- Integration tests in the right location (tests/ directory or crate)
- Test utilities extracted when reused across multiple tests
- Clear separation between unit, integration, and end-to-end tests
- Test helpers that are not themselves tested where they contain logic

### 8. Property and Fuzz Testing

- New parsing or serialization code without roundtrip tests
- New input validation without fuzz targets
- New protocol handling without malformed input tests
- New cryptographic code without known-answer tests

## Severity Levels

**Critical** ~ Security-sensitive code path has no tests, or tests are misleading.
**High** ~ New public API with no test coverage, or error paths untested.
**Medium** ~ Edge cases missing, assertions too weak, test isolation issues.
**Low** ~ Test organization, naming, or clarity improvements.
**Informational** ~ Style suggestions, minor improvements.

## What to Flag Aggressively

- New error branches with no tests
- Public API changes without updated or new tests
- Security-relevant code (auth, crypto, input validation) without thorough tests
- Tests that would pass even if the code were broken (vacuous or overly broad assertions)
- Flaky tests that rely on timing or external state
- Tests that depend on other tests or shared mutable state
- Missing regression tests for bug fixes

## What Not to Over-Index On

- Coverage percentages as a metric
- Tests for trivial getters, setters, or pass-through functions
- Tests for third-party library behavior
- End-to-end tests that are inherently fragile
- Exhaustive testing of every permutation
- Test code style that does not affect correctness

## Finding Format

For each finding, provide:

1. **Location**: file and function or module
2. **Category**: missing coverage, assertion quality, isolation, clarity, mocking, flakiness, organization
3. **Severity**: critical / high / medium / low / informational
4. **Gap**: what is not tested or what the test gets wrong
5. **Risk**: what regression could slip through
6. **Suggested test**: what should be tested and how

## Review Tone

Be direct and practical. Focus on tests that catch regressions, not tests that inflate metrics.

Good phrases:

- `this error branch is never tested ~ the failure path is untested`
- `the assertion passes even if the function returns the wrong value ~ too broad`
- `this test depends on the system clock ~ will flake on slow CI`
- `this test modifies a global config without cleanup ~ may break other tests`
- `the mock returns success in all cases ~ error injection is missing`
- `the test name says "valid input" but it tests three unrelated things ~ unclear scope`
- `the test is 200 lines of setup with a single assert at the end ~ hard to see what's tested`

## Approval Bar

A test review should not approve when:

- Security-sensitive code has no tests
- A new public API has no test coverage
- Tests are misleading or vacuous (would pass if the code were broken)
- Critical error paths are untested
- Tests are order-dependent or leak state

Medium and low findings should be noted but do not block approval.
