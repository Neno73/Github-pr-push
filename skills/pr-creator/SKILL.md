---
name: pr-creator
description: Automatically creates GitHub pull requests after work is committed. Runs comprehensive security checks to prevent secret leaks, generates PR title and description from commit history, and pushes to remote. Activates when implementation work is complete and ready for review.
---

# PR Creator

## Purpose

Automate GitHub pull request creation with built-in security checks to prevent accidental secret commits.

**Core principle:** Every PR goes through security validation before reaching GitHub.

## When to Activate

**Automatically activate when:**
- Implementation work is complete and committed
- User says "create PR" or "ready for review"
- At the end of a feature/fix implementation workflow
- After all tests pass and code is ready

**Do NOT activate for:**
- No commits exist (nothing to create PR for)
- Already on main/master branch (should never happen if git-workflow-enforcer runs first)
- Work in progress (not ready for review)

## Prerequisites

**Before creating PR:**
1. On a feature branch (not main/master)
2. At least one commit exists since branching from main
3. Security checks pass
4. Changes are committed (working directory can be clean or dirty)

## Workflow

### Step 1: Verify Prerequisites

```bash
# Check current branch
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  echo "❌ ERROR: Cannot create PR from main/master branch"
  echo "Use git-workflow-enforcer to create a feature branch first"
  exit 1
fi

# Check for commits
BASE_BRANCH="main"  # or detect default branch
COMMIT_COUNT=$(git log "$BASE_BRANCH..HEAD" --oneline | wc -l)

if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  echo "❌ ERROR: No commits to create PR from"
  echo "Current branch has no commits ahead of $BASE_BRANCH"
  exit 1
fi

echo "✅ Found $COMMIT_COUNT commit(s) to include in PR"
```

### Step 2: Run Security Checks

**MANDATORY:** Never skip security checks.

```bash
# Run the security check script
# This script is located in scripts/check-secrets.sh
bash "$(git rev-parse --show-toplevel)/scripts/check-secrets.sh" "$BASE_BRANCH"

# If script exits with non-zero, security check failed
# Script will display what it found
```

**Security checks include:**
- .gitignore validation (ensure sensitive patterns present)
- .env file detection in staged changes
- Secret pattern scanning (API keys, tokens, credentials)
- Hardcoded credential detection

**If security check fails:**
- Block PR creation
- Display what was found
- Exit with error
- User must fix issues before retrying

### Step 3: Generate PR Metadata

Create meaningful PR title and body from git history:

```bash
# Get PR title from first commit message
PR_TITLE=$(git log "$BASE_BRANCH..HEAD" --format=%s | head -1)

# Generate PR body with summary and changes
PR_BODY=$(cat <<EOF
## Summary

$(git log "$BASE_BRANCH..HEAD" --format="- %s" | head -10)

## Changes

\`\`\`
$(git diff "$BASE_BRANCH...HEAD" --stat)
\`\`\`

## Test Plan

- [ ] Changes build successfully
- [ ] Tests pass
- [ ] No breaking changes
- [ ] Security checks passed

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)
```

**PR body sections:**
- **Summary:** Bullet list of commit messages (up to 10)
- **Changes:** Diff stats showing files changed
- **Test Plan:** Standard checklist (can be customized)
- **Footer:** Claude Code attribution

### Step 4: Push Branch to Remote

```bash
# Push current branch to origin with upstream tracking
git push -u origin "$CURRENT_BRANCH"

echo "✅ Pushed $CURRENT_BRANCH to remote"
```

**If push fails:**
- Branch may already exist on remote (force push not allowed by default)
- Network issues
- Permissions issues
- Display error and exit

### Step 5: Create Pull Request

Use GitHub CLI (`gh`) to create PR:

```bash
# Create PR with title and body
# Use heredoc to handle multiline body correctly
gh pr create \
  --title "$PR_TITLE" \
  --body "$(cat <<'PRBODY'
$PR_BODY
PRBODY
)"

echo "✅ Pull request created"
```

### Step 6: Get PR Information

```bash
# Get PR number and URL
PR_NUMBER=$(gh pr view --json number -q .number)
PR_URL=$(gh pr view --json url -q .url)

# Save PR number for feedback loop skill
mkdir -p "$(git rev-parse --show-toplevel)/.claude/feedback"
echo "$PR_NUMBER" > "$(git rev-parse --show-toplevel)/.claude/feedback/current-pr.txt"

# Display to user
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pull Request Created Successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PR #$PR_NUMBER"
echo "🔗 $PR_URL"
echo "📝 Title: $PR_TITLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 7: Return PR Info

Provide structured output for orchestrator or user:

```
PR Number: [number]
PR URL: [url]
Status: Ready for review
Feedback file: .claude/feedback/current-pr.txt
```

## Security Checks Detail

The `scripts/check-secrets.sh` script performs these checks:

### 1. .gitignore Validation

Ensures these patterns exist:
- `.env` and `.env.*`
- `*.key`, `*.pem`
- `.claude/feedback/`
- `credentials.json`
- `config/secrets.yml`

Adds missing patterns automatically.

### 2. Environment File Detection

Scans staged files for:
- `.env`
- `.env.local`, `.env.production`, etc.

Hard block if found - these should NEVER be committed.

### 3. Secret Pattern Scanning

Detects common secret formats:
- OpenAI API keys (`sk-...`)
- GitHub tokens (`ghp_...`, `gho_...`, etc.)
- AWS credentials (`AKIA...`, access key:secret format)
- Google API keys (`AIza...`)
- Stripe keys (`sk_live_...`, `pk_live_...`)
- Slack tokens (`xoxb-...`, `xoxp-...`)
- Database URLs with passwords
- Many more patterns

### 4. Hardcoded Credential Detection

Looks for code like:
- `API_KEY="sk-abc123..."`
- `password: "secret123"`
- `token = "ghp_xyz..."`

Excludes obvious placeholders:
- Values containing "example"
- Values containing "placeholder"
- Values like "YOUR_API_KEY"

## Error Handling

### No Commits to Push

```
❌ ERROR: No commits to create PR from
Current branch has no commits ahead of main

Suggestion: Make some changes and commit them first
```

### Security Check Failed

```
❌ BLOCKED: Potential secret detected!
Pattern: sk-[a-zA-Z0-9]{48}

Matching lines:
+ const apiKey = "sk-abc123..."

Please remove these secrets before pushing.
Consider using environment variables or secret management tools.
```

### Branch Already Exists on Remote

```
❌ ERROR: Push failed

fatal: remote already has branch 'feature/my-branch'

Suggestion: Pull latest changes or use a different branch name
```

### GitHub CLI Not Authenticated

```
❌ ERROR: gh CLI not authenticated

Run: gh auth login

Then try again
```

## Examples

### Example 1: Successful PR Creation

```
User: "Create PR for these changes"

Actions:
1. ✅ Current branch: feature/add-rate-limiting (not main/master)
2. ✅ Found 3 commits ahead of main
3. 🔒 Running security checks...
   ✅ .gitignore patterns verified
   ✅ No .env files in commit
   ✅ No secret patterns detected
   ✅ No hardcoded credentials detected
4. ✅ Pushed feature/add-rate-limiting to remote
5. ✅ Pull request created

Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Pull Request Created Successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PR #42
🔗 https://github.com/user/repo/pull/42
📝 Title: Add rate limiting to API endpoints
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Example 2: Security Check Blocks PR

```
User: "Create PR"

Actions:
1. ✅ Current branch: feature/auth-update
2. ✅ Found 2 commits ahead of main
3. 🔒 Running security checks...
   ✅ .gitignore patterns verified
   ✅ No .env files in commit
   ❌ BLOCKED: Potential secret detected!

Output:
❌ BLOCKED: Potential secret detected!
Pattern: ghp_[a-zA-Z0-9]{36}

Matching lines:
+ const githubToken = "ghp_abc123xyz789..."

Please remove these secrets before pushing.
Consider using environment variables or secret management tools.

PR creation aborted - fix security issues first
```

### Example 3: No Commits to Push

```
User: "Create PR"

Current branch: feature/empty-branch (branched from main but no commits)

Output:
❌ ERROR: No commits to create PR from
Current branch has no commits ahead of main

Suggestion: Make some changes and commit them first
```

## Integration with Other Skills

**Depends on:**
- `git-workflow-enforcer` (ensures on feature branch)

**Provides output for:**
- `claudebot-feedback-loop` (saves PR number to .claude/feedback/current-pr.txt)
- `thoughtful-pr-workflow` (returns PR URL and number)

**Cannot be used without:**
- Git repository with remote
- GitHub CLI (`gh`) installed and authenticated
- At least one commit on current branch

## Success Criteria

✅ Never pushes code with secrets
✅ Creates well-formatted PRs with meaningful descriptions
✅ Saves PR number for feedback loop
✅ Handles all error cases gracefully
✅ Provides clear output for next steps

## Technical Notes

**Requirements:**
- Git 2.23+
- GitHub CLI (`gh`) installed and authenticated
- Bash or compatible shell
- Repository must have GitHub remote
- Security check script at `scripts/check-secrets.sh`

**Files created:**
- `.claude/feedback/current-pr.txt` (PR number for feedback loop)

**No changes to git history** - only pushes existing commits.
