# Evaluation Framework

Verify that plugins produce high-quality review results over time.

## Structure

```text
eval/
├── cases/
│   ├── code-review/
│   ├── security-review/
│   ├── performance-review/
│   └── ...
├── runner.sh
└── README.md
```

Each plugin owns its evaluation cases under `eval/cases/<plugin-name>/`.

## Case format

```text
eval/cases/security-review/sql-injection/
├── input.rs          # The code to review
├── expected.json     # Expected findings
└── README.md         # Why these findings are expected
```

### expected.json

```json
{
  "findings": [
    {
      "id": "security.sql-injection",
      "severity": "error",
      "category": "security",
      "title": "SQL injection via string interpolation",
      "location": {
        "path": "input.rs",
        "start_line": 5
      }
    }
  ]
}
```

Each finding must have `id`, `severity`, and `category`. Other fields are optional for matching.

## Running

```bash
# Run all cases for a plugin
bash eval/runner.sh security-review

# Run a specific case
bash eval/runner.sh security-review sql-injection

# Run all cases for all plugins
bash eval/runner.sh
```

## Metrics

The runner reports:

- **Matched**: expected findings that were produced
- **Missing**: expected findings that were not produced
- **Unexpected**: findings that were produced but not expected
- **Pass/Fail**: whether all expected findings were matched

## Adding cases

1. Create a directory under `eval/cases/<plugin>/<case-name>/`
2. Add `input.<ext>` with the code to review
3. Add `expected.json` with the expected findings
4. Add `README.md` explaining why those findings are expected
5. Run `bash eval/runner.sh <plugin> <case-name>` to verify

## Principle

A plugin is not complete until it includes evaluation cases.
