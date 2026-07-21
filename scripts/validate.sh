#!/usr/bin/env bash
set -euo pipefail

errors=0
warnings=0
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; errors=$((errors + 1)); }
warn() { printf "  ⚠ %s\n" "$1"; warnings=$((warnings + 1)); }

# --- Repository validation ---

echo "Repository validation"
echo ""

plugins_dir="plugins"
marketplace_file=".mull-plugin/marketplace.json"

if [ ! -d "$plugins_dir" ]; then
  fail "plugins/ directory not found"
  exit 1
fi

plugin_dirs=()
for dir in "$plugins_dir"/*/; do
  [ -d "$dir" ] || continue
  plugin_dirs+=("$dir")
done

if [ ${#plugin_dirs[@]} -eq 0 ]; then
  fail "No plugins found in plugins/"
  exit 1
fi

pass "Found ${#plugin_dirs[@]} plugin(s)"

for dir in "${plugin_dirs[@]}"; do
  dirname=$(basename "$dir")
  echo ""
  echo "Plugin: $dirname"

  # 1. plugin.json exists
  manifest="$dir/plugin.json"
  if [ ! -f "$manifest" ]; then
    fail "$dirname: Missing plugin.json"
    continue
  fi

  # 2. Parse required fields
  name=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" | head -1 | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  description=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" | head -1 | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$manifest" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

  if [ -z "$name" ]; then
    fail "$dirname: Missing required field: name"
    continue
  else
    pass "name: $name"
  fi

  if [ -z "$description" ]; then
    fail "$dirname: Missing required field: description"
  else
    pass "description present"
  fi

  if [ -z "$version" ]; then
    fail "$dirname: Missing required field: version"
  else
    if echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
      pass "version: $version (valid semver)"
    else
      fail "$dirname: Invalid version: $version (expected semver: X.Y.Z)"
    fi
  fi

  # 3. Directory name matches plugin name
  if [ -n "$name" ] && [ "$dirname" != "$name" ]; then
    fail "$dirname: Directory name does not match plugin name '$name'"
  else
    pass "Directory name matches plugin name"
  fi

  # 4. Plugin name uniqueness (track via temp file)
  if [ -n "$name" ]; then
    if [ -f "$tmpdir/names" ] && grep -qx "$name" "$tmpdir/names"; then
      fail "Duplicate plugin name: '$name'"
    else
      echo "$name" >> "$tmpdir/names"
      pass "Plugin name unique"
    fi
  fi

  # 5. Skills directory and SKILL.md files
  skills_dir="${dir}skills"
  if [ ! -d "$skills_dir" ]; then
    fail "$dirname: No skills/ directory found"
    continue
  fi

  skill_count=0
  for skill_dir in "$skills_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    echo "  Skill: $skill_name"

    # SKILL.md exists
    if [ ! -f "$skill_file" ]; then
      fail "$dirname/$skill_name: SKILL.md not found"
      continue
    fi

    # File is not empty
    if [ ! -s "$skill_file" ]; then
      fail "$dirname/$skill_name: SKILL.md is empty"
      continue
    fi

    # File is valid UTF-8
    if ! iconv -f utf-8 -t utf-8 "$skill_file" > /dev/null 2>&1; then
      fail "$dirname/$skill_name: SKILL.md is not valid UTF-8"
      continue
    fi
    pass "SKILL.md is valid UTF-8"

    # Front matter exists and has required fields
    first_line=$(head -1 "$skill_file")
    if [ "$first_line" = "---" ]; then
      frontmatter=$(sed -n '2,/^---$/p' "$skill_file" | sed '$d')

      if [ -z "$frontmatter" ]; then
        fail "$dirname/$skill_name: SKILL.md has empty front matter"
      else
        fm_name=$(echo "$frontmatter" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//')
        if [ -z "$fm_name" ]; then
          fail "$dirname/$skill_name: SKILL.md front matter missing 'name' field"
        else
          pass "Front matter name: $fm_name"
        fi

        fm_desc=$(echo "$frontmatter" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//')
        if [ -z "$fm_desc" ]; then
          fail "$dirname/$skill_name: SKILL.md front matter missing 'description' field"
        else
          pass "Front matter description present"
        fi

        # Skill ID uniqueness
        if [ -n "$fm_name" ]; then
          if [ -f "$tmpdir/skills" ] && grep -qx "$fm_name" "$tmpdir/skills"; then
            fail "Duplicate skill name: '$fm_name'"
          else
            echo "$fm_name" >> "$tmpdir/skills"
          fi
        fi
      fi
    else
      warn "$dirname/$skill_name: SKILL.md has no front matter"
    fi

    skill_count=$((skill_count + 1))
  done

  if [ $skill_count -eq 0 ]; then
    fail "$dirname: No skills found in skills/"
  else
    pass "Found $skill_count skill(s)"
  fi

  # 6. README.md exists and is not empty
  if [ ! -f "${dir}README.md" ]; then
    fail "$dirname: Missing README.md"
  elif [ ! -s "${dir}README.md" ]; then
    fail "$dirname: README.md is empty"
  else
    pass "README.md present"
  fi

  # 7. CHANGELOG.md exists and is not empty
  if [ ! -f "${dir}CHANGELOG.md" ]; then
    fail "$dirname: Missing CHANGELOG.md"
  elif [ ! -s "${dir}CHANGELOG.md" ]; then
    fail "$dirname: CHANGELOG.md is empty"
  else
    pass "CHANGELOG.md present"
  fi
done

# --- Marketplace validation ---

echo ""
echo "Marketplace validation"
echo ""

if [ ! -f "$marketplace_file" ]; then
  fail "marketplace.json not found at $marketplace_file"
else
  pass "marketplace.json found"

  for dir in "${plugin_dirs[@]}"; do
    dirname=$(basename "$dir")
    if grep -q "\"$dirname\"" "$marketplace_file" 2>/dev/null; then
      pass "Plugin '$dirname' found in marketplace.json"
    else
      fail "Plugin '$dirname' missing from marketplace.json"
    fi
  done

  # Check marketplace source paths resolve (paths are relative to repo root)
  marketplace_refs=$(grep -o '"source"[[:space:]]*:[[:space:]]*"[^"]*"' "$marketplace_file" | sed 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  for ref in $marketplace_refs; do
    if [ -d "$ref" ] || [ -f "$ref" ]; then
      pass "Marketplace source '$ref' resolves"
    else
      fail "Marketplace source '$ref' does not resolve"
    fi
  done

  # Check for duplicate plugin IDs in marketplace.json (only within the plugins array)
  # Extract names from objects that contain a "source" field (plugin entries, not the marketplace owner)
  marketplace_plugin_names=$(awk '/"plugins":/,/\]/' "$marketplace_file" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  for mname in $marketplace_plugin_names; do
    if [ -f "$tmpdir/market_names" ] && grep -qx "$mname" "$tmpdir/market_names"; then
      fail "Duplicate plugin in marketplace.json: '$mname'"
    else
      echo "$mname" >> "$tmpdir/market_names"
    fi
  done
fi

# --- Summary ---

echo ""
echo "---"
echo ""

if [ $errors -gt 0 ]; then
  echo "✗ $errors error(s), $warnings warning(s)"
  exit 1
elif [ $warnings -gt 0 ]; then
  echo "✓ Passed with $warnings warning(s)"
  exit 0
else
  echo "✓ All checks passed"
  exit 0
fi
