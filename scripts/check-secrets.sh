#!/bin/bash
# Security check script for preventing secret commits
# Called by pr-creator skill before pushing to remote

set -e

echo "🔒 Running security checks..."

# Function: Ensure .gitignore has required patterns
ensure_gitignore() {
  REQUIRED_IGNORES=(
    ".env"
    ".env.*"
    "!.env.example"
    "*.key"
    "*.pem"
    ".claude/feedback/"
    "node_modules/"
    ".DS_Store"
    "credentials.json"
    "config/secrets.yml"
  )

  for pattern in "${REQUIRED_IGNORES[@]}"; do
    if ! grep -qF "$pattern" .gitignore 2>/dev/null; then
      echo "⚠️  Adding missing pattern to .gitignore: $pattern"
      echo "$pattern" >> .gitignore
    fi
  done

  echo "✅ .gitignore patterns verified"
}

# Function: Check for .env files in staging
check_env_files() {
  local env_files
  env_files=$(git diff --cached --name-only | grep -E '^\.env$|\.env\.' || true)

  if [[ -n "$env_files" ]]; then
    echo "❌ BLOCKED: Environment file(s) in commit!"
    echo "$env_files"
    echo ""
    echo "These files should never be committed:"
    echo "$env_files" | sed 's/^/  - /'
    exit 1
  fi

  echo "✅ No .env files in commit"
}

# Function: Scan for common secret patterns
scan_secret_patterns() {
  local base_branch="${1:-main}"

  # Define secret patterns to detect
  local -a patterns=(
    'sk-[a-zA-Z0-9]{48}'                    # OpenAI API keys
    'ghp_[a-zA-Z0-9]{36}'                   # GitHub Personal Access Tokens
    'gho_[a-zA-Z0-9]{36}'                   # GitHub OAuth tokens
    'ghu_[a-zA-Z0-9]{36}'                   # GitHub User tokens
    'ghs_[a-zA-Z0-9]{36}'                   # GitHub Server tokens
    'ghr_[a-zA-Z0-9]{36}'                   # GitHub Refresh tokens
    'github_pat_[a-zA-Z0-9_]{82}'           # GitHub Fine-grained PAT
    'postgres://[^:]+:[^@]+@'               # Database URLs with passwords
    'mysql://[^:]+:[^@]+@'                  # MySQL URLs with passwords
    '[A-Z0-9]{20}:[A-Z0-9]{40}'            # AWS credentials (Access Key:Secret)
    'AKIA[0-9A-Z]{16}'                      # AWS Access Key ID
    'AIza[0-9A-Za-z_-]{35}'                # Google API keys
    'ya29\.[0-9A-Za-z_-]+'                 # Google OAuth access tokens
    '[0-9]+-[0-9A-Za-z_-]{32}\.apps\.googleusercontent\.com' # Google OAuth client ID
    'sk-[a-zA-Z0-9-_]{48,}'                # Stripe API keys
    'pk_live_[0-9a-zA-Z]{24,}'             # Stripe Publishable keys
    'sk_live_[0-9a-zA-Z]{24,}'             # Stripe Secret keys
    'xox[baprs]-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24,}' # Slack tokens
    'sqOatp-[0-9A-Za-z_-]{22}'             # Square OAuth Secret
    'sq0csp-[0-9A-Za-z_-]{43}'             # Square Access Token
    'SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}' # SendGrid API key
    '[0-9a-f]{32}-us[0-9]{1,2}'            # Mailchimp API key
    'key-[0-9a-zA-Z]{32}'                   # Mailgun API key
  )

  echo "🔍 Scanning for secret patterns in diff..."

  # Get the diff, excluding .env.example and similar files
  local diff_output
  diff_output=$(git diff "$base_branch...HEAD" -- . ':(exclude)*.example' ':(exclude).env.example')

  local found_secrets=false
  for pattern in "${patterns[@]}"; do
    if echo "$diff_output" | grep -qE "$pattern"; then
      echo "❌ BLOCKED: Potential secret detected!"
      echo "Pattern: $pattern"
      echo ""
      echo "Matching lines:"
      echo "$diff_output" | grep -E "$pattern" --color=always | head -5
      found_secrets=true
    fi
  done

  if [[ "$found_secrets" == "true" ]]; then
    echo ""
    echo "Please remove these secrets before pushing."
    echo "Consider using environment variables or secret management tools."
    exit 1
  fi

  echo "✅ No secret patterns detected"
}

# Function: Check for hardcoded credentials
check_hardcoded_credentials() {
  local base_branch="${1:-main}"

  echo "🔍 Checking for hardcoded credentials..."

  # Look for assignment patterns like: API_KEY="abc123" or password: "secret"
  local cred_pattern='(api[_-]?key|secret|password|token|auth|credential)["\x27\s]*[:=]["\x27\s]*[A-Za-z0-9_-]{20,}["\x27]'

  # Get diff excluding .example files
  local diff_output
  diff_output=$(git diff "$base_branch...HEAD" -- . ':(exclude)*.example' ':(exclude).env.example')

  if echo "$diff_output" | grep -iE "$cred_pattern" | grep -v "example" | grep -v "placeholder" | grep -v "YOUR_" | grep -q .; then
    echo "❌ BLOCKED: Potential hardcoded credential detected!"
    echo ""
    echo "Suspicious lines (excluding examples/placeholders):"
    echo "$diff_output" | grep -iE "$cred_pattern" | grep -v "example" | grep -v "placeholder" | grep -v "YOUR_" --color=always | head -10
    echo ""
    echo "If these are legitimate non-secret values, consider:"
    echo "  - Using 'example' in the value name"
    echo "  - Using obvious placeholders like 'YOUR_API_KEY'"
    echo "  - Moving to .env.example with fake values"
    exit 1
  fi

  echo "✅ No hardcoded credentials detected"
}

# Main execution
main() {
  local base_branch="${1:-main}"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔒 Security Pre-Push Checks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  ensure_gitignore
  check_env_files
  scan_secret_patterns "$base_branch"
  check_hardcoded_credentials "$base_branch"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ All security checks passed!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run main with optional base branch argument
main "${1:-main}"
