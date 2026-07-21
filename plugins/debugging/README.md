# debugging

Systematic debugging guidance for diagnosing failures, tracing root causes, and verifying fixes.

## When to use

Run this skill when investigating a bug, test failure, or unexpected behavior. Use it to follow a structured process instead of guessing. Particularly useful when the root cause is not obvious.

## What it does

Provides a systematic debugging workflow:

1. **Understand the symptom**: observed vs expected, conditions, history
2. **Reproduce the failure**: exact steps, determinism, environment
3. **Narrow the scope**: binary search, isolate the failure point
4. **Trace the root cause**: data flow, state mutations, timing, assumptions
5. **Verify the fix**: root cause addressed, minimal change, regression test

Also provides common debugging patterns for crashes, wrong output, performance regressions, intermittent failures, network issues, and auth failures.

## Inputs

A description of the observed failure or unexpected behavior.

## Expected outputs

- Structured analysis of the symptom
- Step-by-step investigation plan
- Root cause diagnosis with evidence
- Minimal fix recommendation
- Regression test suggestion

## Limitations

- Provides guidance, not automatic fixes
- Cannot run code or execute tests
- Requires you to provide symptoms and observations
- Effectiveness depends on the quality of the bug report

## Install

```sh
mull plugin install debugging
```
