# documentation

Review documentation quality, accuracy, and completeness for your changes.

## When to use

Run this skill when auditing docs, READMEs, comments, or API documentation. Use it before merging changes that affect public interfaces, configuration options, examples, or user-facing behavior.

## What it does

Reviews the current branch's changes for:

- **Accuracy**: docs that contradict the code, broken examples, outdated references
- **Completeness**: undocumented public API, missing error docs, missing migration guides
- **Clarity**: unclear explanations, missing context, jargon without definition
- **Examples**: broken, too simple, too complex, missing for common use cases
- **Comments**: outdated comments, redundant comments, missing design rationale
- **Changelogs**: unnoted breaking changes, vague entries, missing security fix references
- **API documentation**: missing parameter/return/error docs, inconsistent style
- **README and onboarding**: missing quickstart, outdated setup steps

## Inputs

The diff of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- Exact location (file and section)
- What is wrong or missing
- Who is affected (users, contributors, operators)
- Specific correction or addition

## Limitations

- Does not verify that documentation matches runtime behavior
- Cannot assess whether docs are findable or well-organized in the project
- Focuses on content accuracy, not writing style
- Does not check for broken links outside the diff

## Install

```sh
mull plugin install documentation
```
