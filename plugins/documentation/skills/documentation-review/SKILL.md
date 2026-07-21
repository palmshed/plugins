---
name: documentation-review
description: Review documentation quality, accuracy, and completeness for your changes. Use when auditing docs, READMEs, comments, or API documentation.
disable-model-invocation: true
---

# Documentation Review

Use this skill for a documentation review of the current branch's changes. The goal is to ensure documentation is accurate, useful, and complete — not to produce more docs, but to make sure what exists actually helps.

## Core Prompt

> Review the documentation changes in the current branch.
> Identify inaccuracies, gaps, outdated content, and unclear explanations.
> For each finding, explain what is wrong, who it affects, and how to fix it.
> Be practical: focus on docs that users or contributors actually read.

## Review Categories

### 1. Accuracy

- Documentation that contradicts the code
- Examples that do not work as written
- Outdated references to removed or renamed APIs
- Incorrect parameter types, defaults, or constraints
- Misleading descriptions of behavior
- Broken or outdated links

### 2. Completeness

- Public API without documentation
- Configuration options not documented
- Error conditions not described
- Edge cases or limitations not mentioned
- Migration guides missing for breaking changes
- Prerequisites or setup steps missing

### 3. Clarity

- Explanations that assume context the reader may not have
- Jargon or terminology used without definition
- Unclear examples that do not demonstrate the common case
- Missing "why" — telling what to do without explaining why
- Wall of text where structure would help

### 4. Examples

- Examples that are too simple to be useful
- Examples that are too complex to be understood
- Missing examples for common use cases
- Examples that use patterns the docs advise against
- Examples without explanation of what they demonstrate
- Examples that do not run or are out of date

### 5. Comments

- Comments that describe what the code does rather than why
- Comments that are redundant with the code itself
- Comments that are outdated and contradict the current code
- Missing comments for non-obvious design decisions
- TODO comments without owners or context

### 6. Changelogs

- Breaking changes not noted in the changelog
- New features without description of user impact
- Security fixes without security advisory reference
- Version bumps without corresponding changelog entry
- Changelog entries that are too vague to be useful

### 7. API Documentation

- Missing parameter descriptions
- Missing return value documentation
- Missing error documentation
- Missing examples for non-trivial APIs
- Inconsistent documentation style across similar APIs
- Missing stability or deprecation annotations

### 8. README and Onboarding

- Missing quickstart or getting-started section
- Missing or outdated installation instructions
- Missing contribution guidelines
- Missing license information
- Setup steps that are incomplete or wrong

## Severity Levels

**Critical** — Documentation is wrong in a way that causes users to take dangerous actions or misconfigure security-sensitive settings.
**High** — Documentation is wrong or missing for a common use case or public API.
**Medium** — Documentation is incomplete, unclear, or slightly outdated.
**Low** — Minor style, clarity, or organizational issues.
**Informational** — Suggestions that would improve the docs but are not urgent.

## What to Flag Aggressively

- Documentation that contradicts the code — users will follow the docs and get wrong results
- Missing documentation for public API
- Broken or outdated examples
- Security-sensitive configuration not documented
- Missing migration guide for breaking changes
- Outdated content that looks current (most dangerous category)
- Comments that lie about what the code does

## What Not to Over-Index On

- Internal implementation comments visible only to maintainers
- Minor style differences in documentation
- Documentation for features still in development
- Theoretical completeness that no one would read
- Formatting preferences

## Finding Format

For each finding, provide:

1. **Location**: file and section or function
2. **Category**: accuracy, completeness, clarity, examples, comments, changelogs, API docs, onboarding
3. **Severity**: critical / high / medium / low / informational
4. **Issue**: what is wrong or missing
5. **Audience**: who is affected (users, contributors, operators)
6. **Fix**: specific correction or addition

## Review Tone

Be direct and specific. Say what is wrong and how to fix it.

Good phrases:

- `this example does not work — the function signature changed in v2`
- `the README says "easy setup" but the steps are incomplete`
- `the changelog does not note the breaking change in the config format`
- `this parameter is not documented — users will not know it exists`
- `the comment says "temporary workaround" but this code has been here for 2 years`
- `the API docs say it returns a string but it returns an enum`
- `the example uses a pattern the style guide says to avoid`

## Approval Bar

A documentation review should not approve when:

- Documentation is factually wrong in a way that causes harm
- Public API is undocumented
- Breaking changes have no migration guide
- Security-sensitive configuration is undocumented
- Examples are broken and cannot be run

Medium and low findings should be noted but do not block approval.
