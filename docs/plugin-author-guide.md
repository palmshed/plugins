# Plugin Author Guide

How to create, validate, and release a plugin for the Palmshed marketplace.

## Quick start

```bash
# Scaffold a new plugin
bash scripts/scaffold.sh my-plugin

# Follow the prompts to fill in details
# Then validate and generate
bash scripts/validate.sh
bash scripts/generate.sh
```

## Plugin layout

```
plugins/
  my-plugin/
    plugin.json                 # Manifest (required)
    README.md                   # Documentation (required)
    CHANGELOG.md                # Version history (required)
    skills/
      my-plugin-review/         # Primary review skill
        SKILL.md                # Skill prompt (required)
    examples/
      README.md                 # Good/bad code examples
    eval/cases/                 # Evaluation cases (in repo root)
```

## Naming conventions

- Plugin names: lowercase alphanumeric with hyphens, 1-64 characters
- Primary review skill: `<plugin-name>-review` (unless plugin name already ends in `-review`)
- Directory names: kebab-case
- File names: lowercase with hyphens

## Manifest (plugin.json)

Required fields:
- `name` ~ kebab-case identifier matching the directory name

Optional fields:
- `version` ~ semver string (e.g., "1.0.0")
- `description` ~ what the plugin does (under 120 characters)
- `author` ~ `{ "name": "...", "email": "...", "url": "..." }`
- `skills` ~ path to skills directory (default: "./skills")
- `commands` ~ path to commands directory
- `agents` ~ path to agents directory
- `hooks` ~ path to hooks.json
- `mcpServers` ~ path to .mcp.json

## SKILL.md format

```yaml
---
name: my-plugin-review
description: What this skill reviews
when-to-use: When the user asks for X
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Role

You are a senior engineer reviewing code for [domain].

## Instructions

1. [Specific check]
2. [Another check]

## Output

Return findings in structured format.
```

### Frontmatter keys

| Key | Required | Description |
|-----|----------|-------------|
| name | Yes | Skill identifier |
| description | Yes | What the skill does |
| when-to-use | Yes | When to invoke this skill |
| allowed-tools | No | Tools the skill can use |
| paths | No | File patterns to include |
| model | No | Model to use |
| effort | No | Reasoning effort level |
| user-invocable | No | Whether users can invoke directly |

## Evaluation cases

Every plugin should include evaluation cases to verify quality.

### Case structure

```
eval/cases/
  my-plugin-review/
    test-case-name/
      input.rs           # Code to review
      expected.json      # Expected findings
      README.md          # Why these findings are expected
```

### expected.json format

```json
{
  "findings": [
    {
      "id": "category.issue-name",
      "severity": "error",
      "category": "category",
      "title": "Brief description",
      "location": {
        "path": "input.rs",
        "start_line": 5
      }
    }
  ]
}
```

### Running evaluation

```bash
# Run all cases for a plugin
bash eval/runner.sh my-plugin-review

# Run a specific case
bash eval/runner.sh my-plugin-review test-case-name

# Run all cases
bash eval/runner.sh
```

## Validation

Before submitting a PR, ensure your plugin passes validation:

```bash
bash scripts/validate.sh
```

This checks:
- plugin.json exists and is valid JSON
- Required fields are present
- Directory names follow conventions
- SKILL.md exists and has valid front matter
- No duplicate skill IDs across the marketplace
- README.md and CHANGELOG.md exist

## Release process

1. Run `bash scripts/validate.sh` - must pass
2. Run `bash scripts/generate.sh` - regenerate marketplace files
3. Verify all checklist items in `docs/plugin-review-checklist.md`
4. Bump version in plugin.json
5. Update CHANGELOG.md
6. Commit and open a PR
7. CI must pass (validation + freshness check + eval suite)

## Versioning

Follow semantic versioning:
- **Major** (X.0.0): Breaking changes to skill behavior or output format
- **Minor** (0.X.0): New checks, new categories, expanded coverage
- **Patch** (0.0.X): Bug fixes, false positive reduction, documentation updates

## Common patterns

### Adding a new check

1. Add the check to SKILL.md instructions
2. Add a "bad" example to examples/README.md
3. Add an evaluation case to eval/cases/
4. Bump minor version

### Reducing false positives

1. Add "what not to flag" guidance to SKILL.md
2. Add a negative evaluation case (no findings expected)
3. Bump patch version

### Breaking changes

If you change the output format or remove checks:
1. Document in CHANGELOG.md
2. Bump major version
3. Consider adding migration notes to README.md

## Resources

- [Plugin review checklist](./docs/plugin-review-checklist.md)
- [Structured findings schema](./docs/structured-findings.md)
- [Evaluation framework](./eval/README.md)
- [Mull documentation](https://github.com/palmshed/mull)
