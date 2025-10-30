#!/bin/bash
# Test runner for all plugin tests
# Executes all test scripts and reports overall status

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   GitHub Push PR Plugin - Test Suite      ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Run a single test script
run_test() {
  local test_script="$1"
  local test_name=$(basename "$test_script" .sh)

  echo ""
  echo "═══════════════════════════════════════════"
  echo "Running: $test_name"
  echo "═══════════════════════════════════════════"
  echo ""

  TOTAL_TESTS=$((TOTAL_TESTS + 1))

  if bash "$test_script"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✅ $test_name PASSED${NC}"
    return 0
  else
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}❌ $test_name FAILED${NC}"
    return 1
  fi
}

# Main test execution
main() {
  cd "$REPO_ROOT"

  # Check prerequisites
  echo "🔍 Checking prerequisites..."
  echo ""

  # Check for required commands
  MISSING_DEPS=()

  command -v git >/dev/null 2>&1 || MISSING_DEPS+=("git")
  command -v jq >/dev/null 2>&1 || MISSING_DEPS+=("jq")
  command -v gh >/dev/null 2>&1 || MISSING_DEPS+=("gh (GitHub CLI)")

  if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Missing dependencies:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
      echo "  - $dep"
    done
    echo ""
    echo "Note: Some tests may be skipped"
    echo ""
  else
    echo "✅ All dependencies available"
    echo ""
  fi

  # Find all test scripts
  TEST_SCRIPTS=(
    "$SCRIPT_DIR/test-git-workflow-enforcer.sh"
    "$SCRIPT_DIR/test-security-checks.sh"
  )

  # Run each test
  for test_script in "${TEST_SCRIPTS[@]}"; do
    if [[ -f "$test_script" ]]; then
      run_test "$test_script" || true  # Continue even if test fails
    else
      echo -e "${YELLOW}⚠️  Test script not found: $test_script${NC}"
    fi
  done

  # Print summary
  echo ""
  echo "═══════════════════════════════════════════"
  echo "            TEST SUMMARY                    "
  echo "═══════════════════════════════════════════"
  echo ""
  echo "Total tests:  $TOTAL_TESTS"
  echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
  if [[ $FAILED_TESTS -gt 0 ]]; then
    echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
  else
    echo "Failed:       $FAILED_TESTS"
  fi
  echo ""

  if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ ALL TESTS PASSED!                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
  else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ❌ SOME TESTS FAILED                    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
  fi
}

main
