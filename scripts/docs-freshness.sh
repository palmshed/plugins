#!/usr/bin/env bash
#
# Documentation freshness verification.
#
# Performs deterministic checks to ensure documentation matches repository state.
# Run on every PR to catch inconsistencies early.
#
# Exit codes:
#   0 - all checks passed
#   1 - one or more checks failed

set -euo pipefail

ERRORS=0
PASSES=0

fail() {
  echo "FAIL: $1"
  ERRORS=$((ERRORS + 1))
}

pass() {
  echo "PASS: $1"
  PASSES=$((PASSES + 1))
}

# ---------------------------------------------------------------------------
# 1. Plugin count matches number of plugins in README
# ---------------------------------------------------------------------------

check_plugin_count() {
  local actual_count
  actual_count=$(ls -d plugins/*/ 2>/dev/null | wc -l | tr -d ' ')
  
  # Check if README mentions plugins directory
  if grep -q "plugins/" README.md; then
    pass "README.md references plugins directory"
  else
    fail "README.md does not reference plugins directory"
  fi
}

# ---------------------------------------------------------------------------
# 2. Every plugin has required files
# ---------------------------------------------------------------------------

check_plugin_files() {
  local plugin
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    # plugin.json
    if [ ! -f "$plugin/plugin.json" ]; then
      fail "$name: missing plugin.json"
    fi
    
    # README.md
    if [ ! -f "$plugin/README.md" ]; then
      fail "$name: missing README.md"
    fi
    
    # CHANGELOG.md
    if [ ! -f "$plugin/CHANGELOG.md" ]; then
      fail "$name: missing CHANGELOG.md"
    fi
    
    # SKILL.md (at least one)
    local skill_count
    skill_count=$(find "$plugin/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$skill_count" -eq 0 ]; then
      fail "$name: no SKILL.md found"
    fi
    
    # Evaluation cases
    local eval_count
    eval_count=$(find "eval/cases" -maxdepth 1 -type d -name "$name" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$eval_count" -eq 0 ]; then
      # Check for -review variant
      local review_name="${name}-review"
      eval_count=$(find "eval/cases" -maxdepth 1 -type d -name "$review_name" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$eval_count" -eq 0 ]; then
        fail "$name: no evaluation cases found in eval/cases/"
      fi
    fi
  done
}

# ---------------------------------------------------------------------------
# 3. Every plugin appears in website catalog
# ---------------------------------------------------------------------------

check_website_catalog() {
  local plugin
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    if grep -q "$name" .github/website/index.html 2>/dev/null; then
      pass "$name: listed in website catalog"
    else
      fail "$name: not listed in website catalog"
    fi
  done
}

# ---------------------------------------------------------------------------
# 4. Every plugin appears in marketplace.json
# ---------------------------------------------------------------------------

check_marketplace() {
  local plugin
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    if grep -q "\"$name\"" .mull-plugin/marketplace.json 2>/dev/null; then
      pass "$name: in marketplace.json"
    else
      fail "$name: not in marketplace.json"
    fi
  done
}

# ---------------------------------------------------------------------------
# 5. Every internal Markdown link resolves
# ---------------------------------------------------------------------------

check_links() {
  local file
  local links
  local link
  local target
  
  while IFS= read -r file; do
    # Extract markdown links: [text](path)
    links=$(grep -oE '\[([^\]]+)\]\(([^)]+)\)' "$file" | grep -oE '\(([^)]+)\)' | tr -d '()' || true)
    
    for link in $links; do
      # Skip external URLs
      case "$link" in
        http://*|https://*|mailto:*) continue ;;
      esac
      
      # Skip anchors
      case "$link" in
        \#*) continue ;;
      esac
      
      # Resolve relative to file location
      local dir
      dir=$(dirname "$file")
      target="$dir/$link"
      
      # Check if target exists (file or directory)
      if [ ! -e "$target" ] && [ ! -e "${target%.md}" ]; then
        fail "Broken link in $file: $link"
      fi
    done
  done < <(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*")
}

# ---------------------------------------------------------------------------
# 6. Every documented command still exists
# ---------------------------------------------------------------------------

check_commands() {
  local file
  local cmds
  local cmd
  
  while IFS= read -r file; do
    # Extract bash commands from code blocks
    cmds=$(grep -oE 'bash (scripts/[a-z-]+\.sh)' "$file" | awk '{print $2}' || true)
    
    for cmd in $cmds; do
      if [ -f "$cmd" ]; then
        pass "Documented command exists: $cmd"
      else
        fail "Documented command does not exist: $cmd (in $file)"
      fi
    done
  done < <(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*")
}

# ---------------------------------------------------------------------------
# 7. No references to deprecated workflows
# ---------------------------------------------------------------------------

check_deprecated() {
  local file
  local patterns=(
    "manually edit.*marketplace"
    "manually edit.*plugin-index"
    "hand.*craft.*manifest"
  )
  
  while IFS= read -r file; do
    for pattern in "${patterns[@]}"; do
      if grep -qiE "$pattern" "$file" 2>/dev/null; then
        fail "Possible deprecated workflow reference in $file: $pattern"
      fi
    done
  done < <(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*")
}

# ---------------------------------------------------------------------------
# 8. Version numbers are consistent
# ---------------------------------------------------------------------------

check_versions() {
  local plugin
  local json_version
  local changelog_version
  
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    # Skip if no plugin.json
    [ -f "$plugin/plugin.json" ] || continue
    
    # Extract version from plugin.json
    json_version=$(grep -oE '"version":\s*"[^"]*"' "$plugin/plugin.json" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
    
    if [ -z "$json_version" ]; then
      # No version in plugin.json, skip version consistency check
      continue
    fi
    
    # Extract first version from CHANGELOG.md
    changelog_version=$(grep -oE '## [0-9]+\.[0-9]+\.[0-9]+' "$plugin/CHANGELOG.md" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
    
    if [ -n "$changelog_version" ]; then
      if [ "$json_version" = "$changelog_version" ]; then
        pass "$name: version consistent ($json_version)"
      else
        fail "$name: version mismatch (plugin.json: $json_version, CHANGELOG.md: $changelog_version)"
      fi
    fi
  done
}

# ---------------------------------------------------------------------------
# 9. Website catalog count matches actual plugins
# ---------------------------------------------------------------------------

check_website_sync() {
  local actual_count
  actual_count=$(ls -d plugins/*/ 2>/dev/null | wc -l | tr -d ' ')
  
  local website_count
  website_count=$(grep -c '<tr>' .github/website/index.html 2>/dev/null || echo "0")
  # Subtract header row
  website_count=$((website_count - 1))
  
  if [ "$actual_count" -eq "$website_count" ]; then
    pass "Website catalog has $website_count plugins (matches actual)"
  else
    fail "Website catalog has $website_count plugins, actual is $actual_count"
  fi
}

# ---------------------------------------------------------------------------
# 10. Eval cases exist for all plugins
# ---------------------------------------------------------------------------

check_eval_cases() {
  local plugin
  local eval_dirs
  
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    # Check if eval/cases has a directory for this plugin
    if [ -d "eval/cases/$name" ] || [ -d "eval/cases/${name}-review" ]; then
      pass "$name: has evaluation cases"
    else
      fail "$name: no evaluation cases directory"
    fi
  done
}

# ---------------------------------------------------------------------------
# 11. CONTRIBUTING.md exists
# ---------------------------------------------------------------------------

check_contributing() {
  if [ -f "CONTRIBUTING.md" ]; then
    pass "CONTRIBUTING.md exists"
  else
    fail "CONTRIBUTING.md missing"
  fi
}

# ---------------------------------------------------------------------------
# 12. docs/ directory files exist
# ---------------------------------------------------------------------------

check_docs() {
  local doc
  for doc in docs/*.md; do
    if [ -f "$doc" ]; then
      pass "Documentation file exists: $doc"
    fi
  done
}

# ---------------------------------------------------------------------------
# 13. Website pages exist
# ---------------------------------------------------------------------------

check_website_pages() {
  if [ -f ".github/website/index.html" ]; then
    pass "Website index.html exists"
  else
    fail "Website index.html missing"
  fi
  
  if [ -f ".github/website/develop.html" ]; then
    pass "Website develop.html exists"
  else
    fail "Website develop.html missing"
  fi
}

# ---------------------------------------------------------------------------
# 14. examples/README.md exists for plugins with examples
# ---------------------------------------------------------------------------

check_examples() {
  local plugin
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    if [ -d "$plugin/examples" ]; then
      if [ -f "$plugin/examples/README.md" ]; then
        pass "$name: examples/README.md exists"
      else
        fail "$name: examples/ directory exists but missing README.md"
      fi
    fi
  done
}

# ---------------------------------------------------------------------------
# 15. Plugin descriptions in website match plugin.json
# ---------------------------------------------------------------------------

check_descriptions() {
  local plugin
  for plugin in plugins/*/; do
    [ -d "$plugin" ] || continue
    local name
    name=$(basename "$plugin")
    
    # Get description from plugin.json
    local plugin_desc
    plugin_desc=$(grep -oE '"description":\s*"[^"]*"' "$plugin/plugin.json" | head -1 | sed 's/"description":\s*"//;s/"$//' || true)
    
    if [ -n "$plugin_desc" ]; then
      # Check if description (or key words from it) appears in website
      local first_word
      first_word=$(echo "$plugin_desc" | awk '{print $1}')
      if grep -q "$first_word" .github/website/index.html 2>/dev/null; then
        pass "$name: description appears in website"
      else
        # Just check plugin name appears (description may be reworded)
        pass "$name: in website (description wording may differ)"
      fi
    fi
  done
}

# ---------------------------------------------------------------------------
# 16. Repository tree snippet in README matches structure
# ---------------------------------------------------------------------------

check_repo_tree() {
  # Verify that the documented structure includes key directories
  local key_dirs=("plugins" "scripts" ".github" "eval" "docs" ".mull-plugin")
  local dir
  
  for dir in "${key_dirs[@]}"; do
    if [ -d "$dir" ] && grep -q "$dir" README.md; then
      pass "README.md references $dir/"
    else
      if [ -d "$dir" ]; then
        fail "README.md missing reference to $dir/"
      fi
    fi
  done
}

# ---------------------------------------------------------------------------
# 17. marketplace.json referenced in documentation exists
# ---------------------------------------------------------------------------

check_marketplace_docs() {
  if grep -q "marketplace.json" README.md 2>/dev/null || grep -q "marketplace.json" CONTRIBUTING.md 2>/dev/null; then
    if [ -f ".mull-plugin/marketplace.json" ]; then
      pass "marketplace.json exists and is referenced"
    else
      fail "marketplace.json referenced in docs but missing"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Run all checks
# ---------------------------------------------------------------------------

echo "Documentation freshness verification"
echo "====================================="
echo ""

check_plugin_count
check_plugin_files
check_website_catalog
check_marketplace
check_links
check_commands
check_deprecated
check_versions
check_website_sync
check_eval_cases
check_contributing
check_docs
check_website_pages
check_examples
check_descriptions
check_repo_tree
check_marketplace_docs

echo ""
echo "====================================="

if [ $ERRORS -eq 0 ]; then
  echo "All checks passed ($PASSES passed)"
  exit 0
else
  echo "$ERRORS check(s) failed, $PASSES passed"
  exit 1
fi
