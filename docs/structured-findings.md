# Architecture: Structured Review Findings

Status: **Proposed** ~ not yet implemented.

## Motivation

Plugins currently emit prose output. As the ecosystem grows, multiple consumers will need the same findings in different formats:

- Terminal: grouped report
- GitHub: inline PR review comments
- GitLab: merge request discussions
- Web UI: annotations
- JSON: machine-readable output

Plugins should not know how their output is displayed. Instead, define a common finding schema that the runtime consumes and presents.

## Design Principles

1. **Presentation-neutral** ~ Plugins describe what they found, not how to display it.
2. **Portable** ~ Same finding works across terminal, PR comments, web UI, and JSON.
3. **Stable ID** ~ Each finding has a stable identifier for deduplication, suppression, and analytics.
4. **Extensible** ~ Schema accommodates future fields without breaking existing consumers.

## Finding Schema

```json
{
  "id": "security.sql-injection",
  "severity": "error",
  "category": "security",
  "title": "SQL injection via string interpolation",
  "explanation": "User input is directly interpolated into the query.",
  "recommendation": "Use parameterized queries instead.",
  "location": {
    "path": "src/handler.rs",
    "start_line": 42,
    "end_line": 42
  },
  "snippet": "let query = format!(\"SELECT ... WHERE email = '{}'\", email);",
  "references": [
    {
      "type": "cwe",
      "id": "CWE-89",
      "url": "https://cwe.mitre.org/data/definitions/89.html"
    }
  ]
}
```

### Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Stable identifier (`category.short-name`). Used for deduplication, suppression rules, analytics. |
| `severity` | enum | yes | `info`, `warning`, `error` |
| `category` | string | yes | Domain category (`security`, `performance`, `maintainability`, `testing`, `documentation`, `design`, `api`, `debugging`). |
| `title` | string | yes | One-line summary of the finding. |
| `explanation` | string | yes | Why this is a problem. |
| `recommendation` | string | yes | How to fix it. |
| `location` | object | no | Structured location with `path`, `start_line`, `end_line`. Omit when finding is not tied to a specific location. |
| `snippet` | string | no | Relevant code snippet for context. |
| `references` | array | no | Links to external documentation, CWE entries, style guides, RFCs. Each entry has `type`, `id`, `url`. |

### Severity semantics

- **error** ~ Must fix before merge. Security vulnerabilities, data loss risks, broken functionality.
- **warning** ~ Should fix before merge. Design problems, performance regressions, missing tests.
- **info** ~ Improvement opportunity. Style suggestions, hardening, best practices.

### ID format

`<category>.<short-name>`

Examples:
- `security.sql-injection`
- `performance.n-plus-one-query`
- `maintainability.file-too-large`
- `testing.missing-error-path-test`
- `design.circular-dependency`

## Runtime Responsibilities

The runtime is responsible for:

- Collecting findings from plugin output
- Deduplicating by `id`
- Filtering by severity
- Presenting in the appropriate format for the consumer

## Plugin Responsibilities

Plugins are responsible for:

- Emitting findings in the schema format
- Providing stable, meaningful `id` values
- Including `location` when the finding is tied to specific code
- Including `references` when external documentation exists

## Migration Path

1. **Current**: Plugins emit prose in SKILL.md. No structured output.
2. **Next**: When a second consumer exists (GitHub reviews, web UI), implement the schema in the runtime.
3. **Future**: Plugins can optionally emit structured findings directly. Prose remains the fallback.

## Not Doing

- Not implementing this now. Prose output is sufficient for the current terminal-only use case.
- Not requiring plugins to change their SKILL.md format. The schema is a future runtime concern.
- Not adding structured output to the plugin interface until there is a real consumer.
