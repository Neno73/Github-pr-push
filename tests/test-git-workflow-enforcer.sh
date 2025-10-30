#!/bin/bash
# Test script for git-workflow-enforcer skill
# Tests: branch detection, feature branch creation, naming conventions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_REPO="/tmp/test-git-workflow-$$"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing: git-workflow-enforcer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Setup test repository
setup_test_repo() {
  echo "📦 Setting up test repository..."
  rm -rf "$TEST_REPO"
  mkdir -p "$TEST_REPO"
  cd "$TEST_REPO"

  git init
  git config user.name "Test User"
  git config user.email "[email protected]"

  echo "# Test Repo" > README.md
  git add README.md
  git commit -m "Initial commit"

  git branch -M main

  echo "✅ Test repository created at $TEST_REPO"
}

# Cleanup
cleanup() {
  echo ""
  echo "🧹 Cleaning up test repository..."
  rm -rf "$TEST_REPO"
  echo "✅ Cleanup complete"
}

trap cleanup EXIT

# Test 1: Detect main branch and create feature branch
test_create_from_main() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 1: Create feature branch from main"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main

  CURRENT_BRANCH=$(git branch --show-current)
  echo "Current branch: $CURRENT_BRANCH"

  if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo "✅ Detected main branch"

    # Simulate git-workflow-enforcer behavior
    TASK_DESCRIPTION="Add rate limiting to API"
    TASK_TYPE="feature"

    DESCRIPTION=$(echo "$TASK_DESCRIPTION" | \
      tr '[:upper:]' '[:lower:]' | \
      tr -s ' ' '-' | \
      tr -cd '[:alnum:]-' | \
      head -c 50)

    BRANCH_NAME="${TASK_TYPE}/${DESCRIPTION}"

    git checkout -b "$BRANCH_NAME"

    NEW_BRANCH=$(git branch --show-current)

    if [[ "$NEW_BRANCH" == "$BRANCH_NAME" ]]; then
      echo "✅ Created feature branch: $NEW_BRANCH"
      echo "✅ Test 1 PASSED"
    else
      echo "❌ Test 1 FAILED: Expected $BRANCH_NAME, got $NEW_BRANCH"
      exit 1
    fi
  else
    echo "❌ Test 1 FAILED: Not on main branch"
    exit 1
  fi
}

# Test 2: Already on feature branch (no-op)
test_already_on_feature_branch() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 2: Already on feature branch"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"

  # Create a feature branch
  git checkout main
  git checkout -b "feature/existing-feature"

  CURRENT_BRANCH=$(git branch --show-current)

  if [[ "$CURRENT_BRANCH" == "feature/existing-feature" ]]; then
    echo "✅ Already on feature branch: $CURRENT_BRANCH"
    echo "✅ No action needed"
    echo "✅ Test 2 PASSED"
  else
    echo "❌ Test 2 FAILED: Not on expected branch"
    exit 1
  fi
}

# Test 3: Branch naming conventions
test_branch_naming() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 3: Branch naming conventions"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main

  test_cases=(
    "feature:Add New Dashboard Component:feature/add-new-dashboard-component"
    "fix:Fix Authentication Bug:fix/fix-authentication-bug"
    "refactor:Refactor Database Layer:refactor/refactor-database-layer"
    "docs:Update API Documentation:docs/update-api-documentation"
  )

  for test_case in "${test_cases[@]}"; do
    IFS=':' read -r task_type description expected <<< "$test_case"

    sanitized=$(echo "$description" | \
      tr '[:upper:]' '[:lower:]' | \
      tr -s ' ' '-' | \
      tr -cd '[:alnum:]-' | \
      head -c 50)

    result="${task_type}/${sanitized}"

    if [[ "$result" == "$expected" ]]; then
      echo "✅ $description → $result"
    else
      echo "❌ $description → Expected: $expected, Got: $result"
      exit 1
    fi
  done

  echo "✅ Test 3 PASSED"
}

# Test 4: Handle uncommitted changes
test_uncommitted_changes() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 4: Uncommitted changes carry over"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main

  # Create uncommitted changes
  echo "test content" > test.txt
  git add test.txt

  # Create feature branch (changes should carry over)
  git checkout -b "feature/test-uncommitted"

  # Verify changes are still there
  if git diff --cached --name-only | grep -q "test.txt"; then
    echo "✅ Uncommitted changes carried over to feature branch"
    echo "✅ Test 4 PASSED"
  else
    echo "❌ Test 4 FAILED: Changes didn't carry over"
    exit 1
  fi
}

# Test 5: Branch name conflict handling
test_branch_conflict() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 5: Branch name conflict resolution"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main

  # Create a branch
  BRANCH_NAME="feature/duplicate-branch"
  git checkout -b "$BRANCH_NAME"
  git checkout main

  # Try to create same branch name
  if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    # Branch exists, append timestamp
    NEW_BRANCH_NAME="${BRANCH_NAME}-$(date +%s)"
    git checkout -b "$NEW_BRANCH_NAME"

    CURRENT=$(git branch --show-current)
    if [[ "$CURRENT" == "$NEW_BRANCH_NAME" ]]; then
      echo "✅ Conflict resolved: created $NEW_BRANCH_NAME"
      echo "✅ Test 5 PASSED"
    else
      echo "❌ Test 5 FAILED"
      exit 1
    fi
  else
    echo "❌ Test 5 FAILED: Branch should exist"
    exit 1
  fi
}

# Run all tests
main() {
  setup_test_repo
  test_create_from_main
  test_already_on_feature_branch
  test_branch_naming
  test_uncommitted_changes
  test_branch_conflict

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ All git-workflow-enforcer tests PASSED!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main
