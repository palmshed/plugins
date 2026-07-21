---
name: debugging-review
description: Guide systematic debugging for failures, tracing root causes, and verifying fixes. Use when investigating a bug, test failure, or unexpected behavior.
disable-model-invocation: true
---

# Debugging Guide

Use this skill for systematic debugging guidance. The goal is to help you find the root cause efficiently — not to guess at the answer, but to follow a structured process that leads to the right diagnosis.

## Core Prompt

> Help me debug this issue systematically.
> Start by understanding the symptoms, then trace the failure to its source.
> Do not guess at the fix until the root cause is identified.
> Propose the minimal change that addresses the root cause.

## Debugging Process

### 1. Understand the Symptom

- What is the observed behavior?
- What is the expected behavior?
- When does it happen? (always, sometimes, under specific conditions)
- Has it worked before? (regression vs new code)
- What changed recently?

### 2. Reproduce the Failure

- Can you reproduce it locally?
- What are the exact steps to reproduce?
- Is it deterministic or intermittent?
- What environment is required? (OS, versions, config)
- Can you write a minimal reproduction?

### 3. Narrow the Scope

- Where does the failure occur? (file, function, line)
- What is the first point where things go wrong?
- Is the input correct up to that point?
- Is the failure in your code or a dependency?
- Can you isolate the failure with a binary search?

### 4. Trace the Root Cause

- What data flows into the failing code?
- What transformations happen to the data?
- Where does the data first deviate from expectations?
- Is there a state mutation causing the issue?
- Is there a timing or concurrency issue?
- Is there an assumption that does not hold?

### 5. Verify the Fix

- Does the fix address the root cause, not just the symptom?
- Does the fix introduce new failures?
- Is the fix minimal? (smallest change that works)
- Can you add a test that would catch this regression?
- Does the fix work in all environments?

## Debugging Patterns

### Symptom → Pattern → Investigation

- **Crash or panic**: Find the stack trace, trace the unwrap/expect, check assumptions
- **Wrong output**: Compare expected vs actual, trace the data flow, check edge cases
- **Performance regression**: Profile, compare flame graphs, check for new allocations or I/O
- **Intermittent failure**: Add logging, check timing, look for shared mutable state
- **Test failure**: Run in isolation, check test isolation, verify test setup
- **Build failure**: Check dependency versions, clear caches, verify toolchain
- **Network failure**: Check connectivity, timeouts, DNS, TLS, proxy settings
- **Auth failure**: Check credentials, token expiry, permission scope, clock skew

### Common Root Causes

- Off-by-one errors in loops or slices
- Null/None where the code assumes non-null
- Stale state from previous operations
- Race conditions in concurrent code
- Incorrect error handling (swallowed errors)
- Wrong assumptions about data format or encoding
- Missing bounds checks on user input
- Platform-specific behavior (macOS vs Linux paths)
- Timezone or locale assumptions
- Integer overflow or precision loss

## Severity Assessment

When reporting the root cause, assess:

- **Impact**: What does this break?
- **Scope**: How many users/code paths are affected?
- **Frequency**: How often does this occur?
- **Regression**: Is this a new problem or pre-existing?
- **Risk**: Could the fix introduce new issues?

## What to Do

- Start with the simplest explanation
- Add logging or assertions to confirm hypotheses
- Change one thing at a time
- Verify the fix with a test
- Check if similar bugs exist elsewhere

## What Not to Do

- Do not guess without evidence
- Do not apply fixes without understanding the root cause
- Do not add workarounds without documenting them
- Do not ignore intermittent failures
- Do not skip the verification step

## Finding Format

For each diagnosis, provide:

1. **Symptom**: what is observed
2. **Root cause**: why it happens (with evidence)
3. **Fix**: minimal change to address the root cause
4. **Verification**: how to confirm the fix works
5. **Prevention**: how to prevent this class of bug in the future
