# Plugin Review Checklist

Every plugin must satisfy this checklist before release.

## Accuracy

- [ ] Findings are factually correct
- [ ] No false positives in the critical/high categories
- [ ] Examples are realistic and demonstrate real patterns
- [ ] The skill does not produce misleading output

## Clarity

- [ ] The SKILL.md prompt is clear and unambiguous
- [ ] Findings include location, category, severity, and fix
- [ ] The skill distinguishes between what must be fixed and what is a suggestion
- [ ] Output is readable by someone unfamiliar with the skill

## Consistency

- [ ] Findings follow a consistent format across categories
- [ ] Severity levels are applied consistently
- [ ] The skill does not contradict itself across different inputs
- [ ] Similar issues receive similar treatment

## False Positive Rate

- [ ] Critical/high findings are almost always real issues
- [ ] The skill does not flag things that are fine in context
- [ ] The skill includes "what not to flag" guidance
- [ ] Edge cases are documented

## False Negative Rate

- [ ] The skill catches the common cases in its domain
- [ ] Important patterns are not missed
- [ ] The skill does not ignore issues because they are hard to detect
- [ ] Domain-specific patterns are covered

## Documentation

- [ ] README.md exists with purpose, usage, inputs, outputs, limitations
- [ ] CHANGELOG.md exists with version history
- [ ] SKILL.md has clear front matter and structured content
- [ ] Install instructions are correct

## Examples

- [ ] At least one "good" example showing approved patterns
- [ ] At least one "bad" example showing flagged patterns
- [ ] Examples are realistic, not toy code
- [ ] Examples explain why the pattern is good or bad
- [ ] Examples cover multiple categories from the SKILL.md

## Evaluation Cases

- [ ] At least one evaluation case with input code
- [ ] At least one evaluation case with expected findings (expected.json)
- [ ] At least one negative case (no findings expected, for false positive testing)
- [ ] Evaluation cases cover the plugin's primary categories
- [ ] `bash eval/runner.sh <plugin-name>` passes

## Versioning

- [ ] plugin.json has a valid semver version
- [ ] Breaking changes increment the major version
- [ ] New features increment the minor version
- [ ] Bug fixes increment the patch version
- [ ] CHANGELOG.md is updated for each release

## Release Process

1. Run `bash scripts/validate.sh` ~ must pass
2. Run `bash scripts/generate.sh` ~ regenerate marketplace files
3. Verify all checklist items above
4. Bump version in plugin.json
5. Update CHANGELOG.md
6. Commit and open a PR
7. CI must pass (validation + freshness check)
