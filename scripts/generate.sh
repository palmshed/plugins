#!/usr/bin/env bash
set -euo pipefail

# Generate .mull-plugin/marketplace.json and .mull-plugin/plugin-index.json
# from the plugins/ directory. Never edit generated files manually.

plugins_dir="plugins"
out_dir=".mull-plugin"
marketplace_file="$out_dir/marketplace.json"
index_file="$out_dir/plugin-index.json"

# Repository version from git tag or default
REPO_VERSION="${GITHUB_REF_NAME:-dev}"
# Strip leading 'v' if present
REPO_VERSION="${REPO_VERSION#v}"

mkdir -p "$out_dir"

pass() { printf "  ✓ %s\n" "$1"; }

# --- Helpers ---

# Compute a deterministic SHA-256 of a plugin directory.
# Hash = SHA-256 of (sorted relative path + ":" + file contents) for every file.
plugin_sha() {
  local dir="$1"
  find "$dir" -type f | sort | while IFS= read -r file; do
    rel="${file#"$dir"/}"
    printf "%s:" "$rel"
    cat "$file"
  done | shasum -a 256 | cut -d' ' -f1
}

# Extract a JSON string value by key. Handles simple "key": "value" patterns.
json_val() {
  local file="$1" key="$2"
  grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$file" | head -1 | sed "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/"
}

# --- Discover plugins ---

plugin_dirs=()
for dir in "$plugins_dir"/*/; do
  [ -d "$dir" ] || continue
  [ -f "$dir/plugin.json" ] || continue
  plugin_dirs+=("$dir")
done

if [ ${#plugin_dirs[@]} -eq 0 ]; then
  echo "Error: No plugins found in $plugins_dir/" >&2
  exit 1
fi

echo "Generating marketplace files..."
echo ""

# --- Generate marketplace.json ---

# Build plugins array entries (sorted by name for determinism)
marketplace_entries=""
sorted_dirs=($(for d in "${plugin_dirs[@]}"; do basename "$d"; done | sort))

for name in "${sorted_dirs[@]}"; do
  dir="$plugins_dir/$name"
  manifest="$dir/plugin.json"

  desc=$(json_val "$manifest" "description")
  source="./plugins/$name"

  entry="    {
      \"name\": \"$name\",
      \"description\": \"$desc\",
      \"source\": \"$source\"
    }"

  if [ -n "$marketplace_entries" ]; then
    marketplace_entries="$marketplace_entries,
$entry"
  else
    marketplace_entries="$entry"
  fi
done

cat > "$marketplace_file" <<EOF
{
  "\$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "Palmshed Official",
  "description": "Official Palmshed plugin marketplace",
  "version": "$REPO_VERSION",
  "owner": {
    "name": "Palmshed"
  },
  "plugins": [
$marketplace_entries
  ]
}
EOF

pass "marketplace.json"

# --- Generate plugin-index.json ---

# Build plugins object entries (sorted by name for determinism)
index_entries=""
first=true

for name in "${sorted_dirs[@]}"; do
  dir="$plugins_dir/$name"
  manifest="$dir/plugin.json"
  sha=$(plugin_sha "$dir")

  # Discover skills
  skills_dir="$dir/skills"
  skills_json=""
  if [ -d "$skills_dir" ]; then
    skill_first=true
    for skill_dir in "$skills_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name=$(basename "$skill_dir")
      skill_file="$skill_dir/SKILL.md"

      # Extract description from front matter
      skill_desc=""
      if [ -f "$skill_file" ]; then
        first_line=$(head -1 "$skill_file")
        if [ "$first_line" = "---" ]; then
          skill_desc=$(sed -n '2,/^---$/p' "$skill_file" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//')
        fi
      fi

      # Escape double quotes in description
      skill_desc=$(echo "$skill_desc" | sed 's/"/\\"/g')

      skill_entry="            {
              \"name\": \"$skill_name\",
              \"description\": \"$skill_desc\"
            }"

      if [ "$skill_first" = true ]; then
        skills_json="$skill_entry"
        skill_first=false
      else
        skills_json="$skills_json,
$skill_entry"
      fi
    done
  fi

  # Default empty arrays for future component types
  entry="    \"$name\": {
      \"sha\": \"$sha\",
      \"components\": {
        \"skills\": [
$skills_json
        ],
        \"commands\": [],
        \"agents\": [],
        \"mcpServers\": [],
        \"hooks\": [],
        \"lspServers\": []
      }
    }"

  if [ "$first" = true ]; then
    index_entries="$entry"
    first=false
  else
    index_entries="$index_entries,
$entry"
  fi
done

cat > "$index_file" <<EOF
{
  "version": 1,
  "plugins": {
$index_entries
  }
}
EOF

pass "plugin-index.json"

# --- Summary ---

echo ""
echo "Generated:"
echo "  $marketplace_file"
echo "  $index_file"
echo ""
echo "Plugins: ${#plugin_dirs[@]}"
echo ""

pass "Done"
