#!/bin/bash
# Test script for security check functionality
# Tests: secret detection, .env file blocking, .gitignore validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
SECURITY_SCRIPT="$REPO_ROOT/scripts/check-secrets.sh"
TEST_REPO="/tmp/test-security-$$"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing: Security Checks"
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

  # Copy security script to test repo
  mkdir -p scripts
  cp "$SECURITY_SCRIPT" scripts/check-secrets.sh
  chmod +x scripts/check-secrets.sh

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

# Test 1: .gitignore validation
test_gitignore_validation() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 1: .gitignore validation"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"

  # Remove .gitignore if exists
  rm -f .gitignore

  # Create feature branch for testing
  git checkout -b feature/test-gitignore

  # Add a safe file
  echo "test" > test.txt
  git add test.txt
  git commit -m "Add test file"

  # Run security check (should add missing patterns to .gitignore)
  if bash scripts/check-secrets.sh main 2>&1 | grep -q "gitignore patterns verified"; then
    echo "✅ Security check ran successfully"

    # Verify .gitignore was created with required patterns
    if [[ -f .gitignore ]]; then
      if grep -q ".env" .gitignore && grep -q "*.key" .gitignore; then
        echo "✅ .gitignore created with required patterns"
        echo "✅ Test 1 PASSED"
      else
        echo "❌ Test 1 FAILED: .gitignore missing required patterns"
        exit 1
      fi
    else
      echo "❌ Test 1 FAILED: .gitignore not created"
      exit 1
    fi
  else
    echo "❌ Test 1 FAILED: Security check failed"
    exit 1
  fi
}

# Test 2: Block .env file commits
test_env_file_blocking() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 2: Block .env file commits"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main
  git checkout -b feature/test-env-blocking

  # Create .env file
  echo "API_KEY=secret123" > .env
  # Force add to bypass .gitignore (we want to test the security script)
  git add -f .env

  # Try to run security check (should fail)
  if bash scripts/check-secrets.sh main 2>&1 | grep -q "BLOCKED.*Environment file"; then
    echo "✅ Security check correctly blocked .env file"
    echo "✅ Test 2 PASSED"
  else
    echo "❌ Test 2 FAILED: .env file not blocked"
    exit 1
  fi

  # Cleanup
  git reset HEAD .env
  rm .env
}

# Test 3: Detect API keys
test_api_key_detection() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 3: Detect API keys in code"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout -b feature/test-api-key-detection

  # Create file with fake API key (correct lengths for patterns)
  # OpenAI: sk- + 48 chars = 51 total
  # GitHub: ghp_ + 36 chars = 40 total
  cat > config.js <<'EOF'
const config = {
  openai: "sk-123456789012345678901234567890123456789012345678",
  github: "ghp_123456789012345678901234567890123456"
};
EOF

  git add config.js
  git commit -m "Add config with API keys"

  # Run security check (should detect secrets)
  if bash scripts/check-secrets.sh main 2>&1 | grep -q "BLOCKED.*secret detected"; then
    echo "✅ Security check detected API keys"
    echo "✅ Test 3 PASSED"
  else
    echo "❌ Test 3 FAILED: API keys not detected"
    cat config.js
    echo "Running security check manually:"
    bash scripts/check-secrets.sh main || true
    exit 1
  fi
}

# Test 4: Allow example/placeholder values
test_allow_placeholders() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 4: Allow example/placeholder values"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main
  git checkout -b feature/test-placeholders

  # Create .env.example with placeholders
  cat > .env.example <<'EOF'
# Example configuration
API_KEY=your_api_key_here
SECRET_TOKEN=example_token_placeholder
DATABASE_URL=postgres://username:password@localhost:5432/db
EOF

  git add .env.example
  git commit -m "Add .env.example"

  # Run security check (should pass for .env.example)
  if bash scripts/check-secrets.sh main 2>&1 | grep -q "security checks passed"; then
    echo "✅ Security check allowed .env.example"
    echo "✅ Test 4 PASSED"
  else
    echo "❌ Test 4 FAILED: .env.example was blocked incorrectly"
    bash scripts/check-secrets.sh main || true
    exit 1
  fi
}

# Test 5: Detect hardcoded credentials
test_hardcoded_credentials() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 5: Detect hardcoded credentials"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main
  git checkout -b feature/test-hardcoded-creds

  # Create file with hardcoded credentials
  cat > auth.js <<'EOF'
const credentials = {
  apiKey: "abc123def456ghi789jkl012mno345pqr",
  password: "super_secret_password_123",
  authToken: "Bearer_xyz789abc123def456ghi"
};
EOF

  git add auth.js
  git commit -m "Add auth config"

  # Run security check (should detect hardcoded credentials)
  if bash scripts/check-secrets.sh main 2>&1 | grep -q "hardcoded credential"; then
    echo "✅ Security check detected hardcoded credentials"
    echo "✅ Test 5 PASSED"
  else
    echo "❌ Test 5 FAILED: Hardcoded credentials not detected"
    bash scripts/check-secrets.sh main || true
    exit 1
  fi
}

# Test 6: Clean commit passes
test_clean_commit() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test 6: Clean commit passes all checks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  cd "$TEST_REPO"
  git checkout main
  git checkout -b feature/test-clean-commit

  # Create a clean file
  cat > utils.js <<'EOF'
// Utility functions
export function formatDate(date) {
  return date.toISOString();
}

export function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
EOF

  git add utils.js
  git commit -m "Add utility functions"

  # Run security check (should pass)
  if bash scripts/check-secrets.sh main 2>&1 | grep -q "All security checks passed"; then
    echo "✅ Clean commit passed all security checks"
    echo "✅ Test 6 PASSED"
  else
    echo "❌ Test 6 FAILED: Clean commit was blocked"
    bash scripts/check-secrets.sh main || true
    exit 1
  fi
}

# Run all tests
main() {
  setup_test_repo
  test_gitignore_validation
  test_env_file_blocking
  test_api_key_detection
  test_allow_placeholders
  test_hardcoded_credentials
  test_clean_commit

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ All security check tests PASSED!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main
