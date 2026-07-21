#!/usr/bin/env bash
#
# Generate release notes from plugin CHANGELOG.md files.
#
# Collects changes from all plugins and formats them into
# a unified release notes document.
#
# Usage:
#   bash scripts/release-notes.sh
#
# Output:
#   .release-notes.md (temporary file for CI)

set -euo pipefail

RELEASE_NOTES=".release-notes.md"
REPO_VERSION=$(grep -oE '"version":\s*"[^"]*"' .mull-plugin/marketplace.json 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")

# Header
cat > "$RELEASE_NOTES" << EOF
# Palmshed Plugins Release

**Version**: $REPO_VERSION
**Date**: $(date +%Y-%m-%d)

## Summary

EOF

# Collect all changes
ADDITIONS=""
UPDATES=""
BREAKING=""
DOCS=""

for plugin_dir in plugins/*/; do
  [ -d "$plugin_dir" ] || continue
  plugin_name=$(basename "$plugin_dir")
  changelog="$plugin_dir/CHANGELOG.md"
  
  [ -f "$changelog" ] || continue
  
  # Extract the first version block (most recent changes)
  changes=$(awk '/^## [0-9]/{if(n++) exit} n' "$changelog" | head -20)
  
  if [ -z "$changes" ]; then
    continue
  fi
  
  # Check if this is a new plugin (1.0.0 with only "Initial release")
  if echo "$changes" | grep -q "Initial release"; then
    ADDITIONS="${ADDITIONS}- ${plugin_name}: new plugin\n"
  else
    # Check for breaking changes
    if echo "$changes" | grep -qi "breaking"; then
      BREAKING="${BREAKING}- ${plugin_name}:\n"
      while IFS= read -r line; do
        case "$line" in
          "-"*"breaking"*|"- "*)
            BREAKING="${BREAKING}  ${line}\n"
            ;;
        esac
      done <<< "$changes"
    fi
    
    # Check for documentation updates
    if echo "$changes" | grep -qi "doc\|readme\|example"; then
      DOCS="${DOCS}- ${plugin_name}:\n"
      while IFS= read -r line; do
        case "$line" in
          "-"*"doc"*|"- "*readme*|"- "*example*)
            DOCS="${DOCS}  ${line}\n"
            ;;
        esac
      done <<< "$changes"
    fi
    
    # All other changes are updates
    UPDATES="${UPDATES}- ${plugin_name}:\n"
    while IFS= read -r line; do
      case "$line" in
        "-"*)
          UPDATES="${UPDATES}  ${line}\n"
          ;;
      esac
    done <<< "$changes"
  fi
done

# Write sections
if [ -n "$ADDITIONS" ]; then
  echo "## New Plugins" >> "$RELEASE_NOTES"
  echo -e "$ADDITIONS" >> "$RELEASE_NOTES"
  echo "" >> "$RELEASE_NOTES"
fi

if [ -n "$BREAKING" ]; then
  echo "## Breaking Changes" >> "$RELEASE_NOTES"
  echo -e "$BREAKING" >> "$RELEASE_NOTES"
  echo "" >> "$RELEASE_NOTES"
fi

if [ -n "$UPDATES" ]; then
  echo "## Updates" >> "$RELEASE_NOTES"
  echo -e "$UPDATES" >> "$RELEASE_NOTES"
  echo "" >> "$RELEASE_NOTES"
fi

if [ -n "$DOCS" ]; then
  echo "## Documentation" >> "$RELEASE_NOTES"
  echo -e "$DOCS" >> "$RELEASE_NOTES"
  echo "" >> "$RELEASE_NOTES"
fi

# If no changes found, add a note
if [ -z "$ADDITIONS" ] && [ -z "$BREAKING" ] && [ -z "$UPDATES" ] && [ -z "$DOCS" ]; then
  echo "No plugin changes in this release." >> "$RELEASE_NOTES"
  echo "" >> "$RELEASE_NOTES"
fi

# Footer
cat >> "$RELEASE_NOTES" << EOF
## Installation

\`\`\`bash
mull plugins add git+https://github.com/palmshed/plugins.git
\`\`\`

To install a specific plugin:

\`\`\`bash
mull plugins add git+https://github.com/palmshed/plugins.git#plugin-name
\`\`\`

## Links

- [Documentation](https://github.com/palmshed/plugins)
- [Plugin Author Guide](https://github.com/palmshed/plugins/blob/main/docs/plugin-author-guide.md)
- [Mull](https://github.com/palmshed/mull)
EOF

echo "Release notes generated: $RELEASE_NOTES"
