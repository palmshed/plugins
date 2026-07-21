---
name: commit-review
description: Review commit messages and history for clarity, structure, and usefulness. Use when preparing to merge or auditing commit quality.
disable-model-invocation: true
---

# Commit Review

Use this skill for reviewing commit messages and the commit history of a branch. The goal is to ensure commits are clear, well-structured, and useful for future readers — not to enforce a specific convention, but to make the history readable and bisectable.

## Core Prompt

> Review the commit messages in the current branch.
> Identify unclear, misleading, or poorly structured commits.
> For each finding, explain what is wrong and how to improve it.
> Focus on whether the history would help or hinder someone debugging a regression.

## Review Categories

### 1. Message Clarity

- Subject does not describe what changed
- Subject is too vague ("fix bug", "update code", "wip")
- Subject describes the problem, not the fix (or vice versa)
- Subject is a restatement of the file name or function name
- Subject uses past tense inconsistently

### 2. Message Structure

- Missing body for non-trivial changes
- Body is a copy of the diff instead of explaining why
- Missing reference to issue or ticket
- Subject line too long (wrap at 72 characters)
- Missing breaking change notation

### 3. Commit粒度

- Commits that are too large (mix unrelated changes)
- Commits that are too small (trivial changes that should be squashed)
- Fixup commits that should be squashed before merge
- Mixed concerns in a single commit
- Commits that break the build or tests

### 4. History Quality

- Commits that make the code worse before a later commit makes it better
- Dead-end commits that are immediately reverted
- Commits with messages that contradict what the code does
- History that is difficult to bisect
- Missing context for why a change was made

### 5. Conventional Commits (if used)

- Missing type prefix (feat, fix, chore, etc.)
- Missing scope for scoped changes
- Missing breaking change indicator (!)
- Inconsistent format across commits

## Severity Levels

**Critical** — Commit message is factually wrong about what the code does.
**High** — History is difficult to bisect or understand.
**Medium** — Message is unclear or missing context.
**Low** — Style or preference issue.
**Informational** — Minor improvement suggestion.

## What to Flag Aggressively

- Messages that are factually wrong about the change
- "WIP" or "fix" commits that provide no context
- Large commits mixing unrelated changes
- History that would make `git bisect` useless
- Missing context for why a change was made
- Commits that break the build

## What Not to Over-Index On

- Minor style differences in otherwise clear messages
- Whether conventional commits are used (unless the project uses them)
- Commit ordering when the final result is correct
- Squash-merge workflows where individual commit history does not matter

## Finding Format

For each finding, provide:

1. **Commit**: hash or subject
2. **Category**: clarity, structure, granularity, history, conventional commits
3. **Severity**: critical / high / medium / low / informational
4. **Problem**: what is wrong with the commit or message
5. **Fix**: suggested rewrite or action

## Approval Bar

A commit review should not approve when:

- A commit message is factually wrong about what the code does
- The history is too noisy to bisect (many trivial fixup commits)
- Critical context is missing (why the change was made)

Medium and low findings should be noted but do not block approval.
