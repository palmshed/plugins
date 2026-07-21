#!/usr/bin/env bash
#
# Scaffold a new plugin directory following repository conventions.
#
# Usage:
#   bash scripts/scaffold.sh <plugin-name>
#
# Example:
#   bash scripts/scaffold.sh my-plugin

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: bash scripts/scaffold.sh <plugin-name>"
  echo ""
  echo "Example:"
  echo "  bash scripts/scaffold.sh my-plugin"
  exit 1
fi

PLUGIN_NAME="$1"

# Validate plugin name
if ! echo "$PLUGIN_NAME" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
  echo "Error: Plugin name must be lowercase alphanumeric with hyphens, 1-64 chars"
  exit 1
fi

if [ ${#PLUGIN_NAME} -gt 64 ]; then
  echo "Error: Plugin name must be 64 characters or less"
  exit 1
fi

# Check if directory already exists
if [ -d "plugins/$PLUGIN_NAME" ]; then
  echo "Error: plugins/$PLUGIN_NAME already exists"
  exit 1
fi

echo "Creating plugin: $PLUGIN_NAME"

# Create directory structure
mkdir -p "plugins/$PLUGIN_NAME/skills/$PLUGIN_NAME-review"
mkdir -p "plugins/$PLUGIN_NAME/examples"
mkdir -p "eval/cases/$PLUGIN_NAME-review"

# Create plugin.json
cat > "plugins/$PLUGIN_NAME/plugin.json" << EOF
{
  "name": "$PLUGIN_NAME",
  "description": "",
  "version": "1.0.0",
  "author": {
    "name": "",
    "email": ""
  },
  "skills": "./skills"
}
EOF

# Create README.md
cat > "plugins/$PLUGIN_NAME/README.md" << EOF
# $PLUGIN_NAME

## Purpose

TODO: Describe what this plugin does.

## Usage

TODO: Describe when to use this plugin.

## Skills

- \`$PLUGIN_NAME-review\` ~ TODO: Describe the review skill

## Limitations

- TODO: Document known limitations

## Install

\`\`\`bash
mull plugins add git+https://github.com/palmshed/plugins.git#$PLUGIN_NAME
\`\`\`

## Compatibility

- **Mull version**: >= 0.1.0
- **Plugin version**: 1.0.0
- **Breaking changes**: None (initial release)
EOF

# Create CHANGELOG.md
cat > "plugins/$PLUGIN_NAME/CHANGELOG.md" << EOF
# Changelog

## 1.0.0

- Initial release
EOF

# Create SKILL.md
cat > "plugins/$PLUGIN_NAME/skills/$PLUGIN_NAME-review/SKILL.md" << EOF
---
name: $PLUGIN_NAME-review
description: TODO: Describe what this skill reviews
when-to-use: TODO: Describe when to invoke this skill
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# $PLUGIN_NAME Review

## Role

You are a senior engineer reviewing code for TODO: specific domain.

## Instructions

1. TODO: Add review instructions
2. TODO: Add specific checks
3. TODO: Add examples of good and bad patterns

## Output

Return findings in structured format:

\`\`\`json
{
  "findings": [
    {
      "id": "category.issue-name",
      "severity": "error|warning|info",
      "category": "category",
      "title": "Brief description",
      "location": {
        "path": "file.rs",
        "start_line": 1
      }
    }
  ]
}
\`\`\`
EOF

# Create placeholder example
cat > "plugins/$PLUGIN_NAME/examples/README.md" << EOF
# Examples

Golden examples demonstrating what this skill flags and approves.

## Good patterns

TODO: Add examples of approved patterns.

## Bad patterns

TODO: Add examples of flagged patterns.
EOF

# Create eval case placeholder
cat > "eval/cases/$PLUGIN_NAME-review/README.md" << EOF
# Evaluation cases for $PLUGIN_NAME review

TODO: Add evaluation cases for this plugin.
EOF

echo ""
echo "Created plugin structure:"
echo ""
find "plugins/$PLUGIN_NAME" -type f | sort
echo ""
echo "Next steps:"
echo "  1. Edit plugins/$PLUGIN_NAME/plugin.json with description and author"
echo "  2. Edit plugins/$PLUGIN_NAME/skills/$PLUGIN_NAME-review/SKILL.md with review instructions"
echo "  3. Add examples to plugins/$PLUGIN_NAME/examples/"
echo "  4. Add evaluation cases to eval/cases/$PLUGIN_NAME-review/"
echo "  5. Run: bash scripts/validate.sh"
echo "  6. Run: bash scripts/generate.sh"
