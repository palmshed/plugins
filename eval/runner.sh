#!/usr/bin/env bash
set -euo pipefail

# Evaluation runner for Mull plugins.
# Runs plugin evaluation cases and reports pass/fail.
#
# Usage:
#   bash eval/runner.sh                          # Run all cases
#   bash eval/runner.sh security-review           # Run all cases for a plugin
#   bash eval/runner.sh security-review sql-injection  # Run a specific case

eval_dir="eval"
cases_dir="$eval_dir/cases"
total=0
passed=0
failed=0
skipped=0

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; }
skip() { printf "  - %s (no expected.json)\n" "$1"; }
info() { printf "  %s\n" "$1"; }

target_plugin="${1:-}"
target_case="${2:-}"

# Discover cases
if [ -n "$target_plugin" ]; then
  plugin_dir="$cases_dir/$target_plugin"
  if [ ! -d "$plugin_dir" ]; then
    echo "Plugin not found: $target_plugin"
    echo "Available plugins:"
    for d in "$cases_dir"/*/; do
      [ -d "$d" ] && echo "  $(basename "$d")"
    done
    exit 1
  fi
  plugin_dirs=("$plugin_dir")
else
  plugin_dirs=()
  for d in "$cases_dir"/*/; do
    [ -d "$d" ] || continue
    plugin_dirs+=("$d")
  done
fi

if [ ${#plugin_dirs[@]} -eq 0 ]; then
  echo "No evaluation cases found in $cases_dir/"
  exit 1
fi

echo "Evaluation runner"
echo ""

for plugin_dir in "${plugin_dirs[@]}"; do
  plugin_name=$(basename "$plugin_dir")
  echo "Plugin: $plugin_name"

  case_dirs=()
  if [ -n "$target_case" ]; then
    case_dir="$plugin_dir/$target_case"
    if [ ! -d "$case_dir" ]; then
      echo "  Case not found: $target_case"
      continue
    fi
    case_dirs=("$case_dir")
  else
    for c in "$plugin_dir"/*/; do
      [ -d "$c" ] || continue
      case_dirs+=("$c")
    done
  fi

  if [ ${#case_dirs[@]} -eq 0 ]; then
    info "  No cases found"
    echo ""
    continue
  fi

  for case_dir in "${case_dirs[@]}"; do
    case_name=$(basename "$case_dir")
    total=$((total + 1))

    expected_file="$case_dir/expected.json"
    input_file=""
    for f in "$case_dir"/input.*; do
      [ -f "$f" ] && input_file="$f" && break
    done

    if [ ! -f "$expected_file" ]; then
      skip "$case_name"
      skipped=$((skipped + 1))
      continue
    fi

    if [ -z "$input_file" ]; then
      fail "$case_name: No input file found"
      failed=$((failed + 1))
      continue
    fi

    # Validate expected.json is valid JSON
    if ! python3 -c "import json; json.load(open('$expected_file'))" 2>/dev/null; then
      fail "$case_name: Invalid expected.json"
      failed=$((failed + 1))
      continue
    fi

    # Count expected findings
    expected_count=$(python3 -c "import json; print(len(json.load(open('$expected_file')).get('findings', [])))")

    # Check that input file is readable
    if [ ! -s "$input_file" ]; then
      fail "$case_name: Input file is empty"
      failed=$((failed + 1))
      continue
    fi

    pass "$case_name ($expected_count expected findings, input: $(basename "$input_file"))"
    passed=$((passed + 1))
  done

  echo ""
done

# Summary
echo "---"
echo ""
echo "Cases: $total | Passed: $passed | Failed: $failed | Skipped: $skipped"

if [ $failed -gt 0 ]; then
  echo "Result: FAILED"
  exit 1
else
  echo "Result: PASSED"
  exit 0
fi
