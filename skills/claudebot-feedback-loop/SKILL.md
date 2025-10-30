---
name: claudebot-feedback-loop
description: Iteratively applies ClaudeBot PR review feedback until clean or max iterations reached. Polls for comments, categorizes them (blocking vs suggestions), applies fixes, commits and pushes changes, then repeats. Includes infinite loop detection and smart polling. Activates after PR creation when automated feedback iteration is needed.
---

# ClaudeBot Feedback Loop

## Purpose

Automate the cycle of receiving ClaudeBot PR feedback and applying fixes until the PR is clean or manual intervention is needed.

**Core principle:** Iterate automatically on feedback, but know when to stop and escalate to human review.

## When to Activate

**Automatically activate when:**
- PR has been created and is awaiting ClaudeBot review
- User requests "apply ClaudeBot feedback" or "iterate on PR"
- Part of automated PR workflow after `pr-creator`
- Feedback iteration is needed to clean up PR

**Do NOT activate for:**
- PRs without ClaudeBot configured
- Manual code review (human reviewers only)
- PRs that are already approved
- Situations where automated fixes are inappropriate

## Configuration

**Default settings:**
- Max iterations: 3
- Poll interval: 30 seconds
- Poll timeout: 5 minutes (10 checks × 30 seconds)
- Feedback directory: `.claude/feedback/`

**Adjustable parameters:**
- `MAX_ITERATIONS` - Maximum number of fix-push-wait cycles
- `POLL_INTERVAL` - Seconds between feedback checks
- `MAX_POLL_ATTEMPTS` - How many times to check before giving up

## GitHub App Integration

### Recommended Setup

This skill works best with the **official Claude GitHub App** installed:

```bash
# Install via Claude Code
claude
> "/install-github-app"

# Or visit: https://github.com/apps/claude
```

### How It Works

**With Official GitHub App (Recommended):**
- ✅ ClaudeBot automatically reviews PRs
- ✅ Structured, actionable feedback
- ✅ @claude mentions available for team
- ✅ Rich comment formatting
- ✅ Consistent review patterns

**Without GitHub App (Still Works):**
- ⚠️ Detects generic bot comments
- ⚠️ May miss some feedback patterns
- ⚠️ No @claude mention support
- ✅ Basic feedback detection works
- ✅ Manual reviews still processed

### Comment Detection

This skill looks for comments from:
- Official ClaudeBot (user.login contains "claude")
- GitHub Actions bots (user.login contains "github-actions")
- Other automation bots (user.login contains "bot")

**Best results:** Install the GitHub App for optimal feedback structure and detection.

## Workflow

### Step 1: Get PR Information

```bash
# Try to get PR number from saved file first
FEEDBACK_DIR="$(git rev-parse --show-toplevel)/.claude/feedback"
PR_NUM=$(cat "$FEEDBACK_DIR/current-pr.txt" 2>/dev/null)

# If not found, get from current branch
if [[ -z "$PR_NUM" ]]; then
  PR_NUM=$(gh pr view --json number -q .number 2>/dev/null)
fi

if [[ -z "$PR_NUM" ]]; then
  echo "❌ ERROR: No PR found for current branch"
  exit 1
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

echo "📋 Working on PR #$PR_NUM in $REPO"
```

### Step 2: Initialize Iteration Loop

```bash
ITERATION=0
MAX_ITERATIONS=3
mkdir -p "$FEEDBACK_DIR"

echo "🔄 Starting feedback iteration loop (max $MAX_ITERATIONS iterations)"
```

### Step 3: Poll for Comments (Smart Polling)

For each iteration, wait for ClaudeBot to comment:

```bash
echo "⏳ Iteration $ITERATION: Waiting for ClaudeBot feedback..."

COMMENT_COUNT=0
POLL_INTERVAL=30
MAX_POLL_ATTEMPTS=10

for attempt in $(seq 1 $MAX_POLL_ATTEMPTS); do
  # Fetch comments from ClaudeBot or related bots
  COMMENT_COUNT=$(gh api "repos/$REPO/pulls/$PR_NUM/comments" \
    | jq '[.[] | select(.user.login | test("claude|bot|github-actions"; "i"))] | length')

  if [[ "$COMMENT_COUNT" -gt 0 ]]; then
    echo "✅ Found $COMMENT_COUNT comment(s) after $((attempt * POLL_INTERVAL)) seconds"
    break
  fi

  if [[ $attempt -lt $MAX_POLL_ATTEMPTS ]]; then
    echo "   Checking again in ${POLL_INTERVAL}s... ($attempt/$MAX_POLL_ATTEMPTS)"
    sleep $POLL_INTERVAL
  fi
done
```

**If timeout (no comments after max attempts):**

```bash
if [[ "$COMMENT_COUNT" -eq 0 ]]; then
  echo "✅ No feedback found after $((MAX_POLL_ATTEMPTS * POLL_INTERVAL))s"
  echo "PR appears clean - no comments from ClaudeBot"
  exit 0
fi
```

### Step 4: Fetch and Save Feedback

```bash
# Fetch all bot comments as JSON
gh api "repos/$REPO/pulls/$PR_NUM/comments" \
  | jq '[.[] | select(.user.login | test("claude|bot|github-actions"; "i"))]' \
  > "$FEEDBACK_DIR/PR-$PR_NUM-iteration-$ITERATION.json"

FEEDBACK_FILE="$FEEDBACK_DIR/PR-$PR_NUM-iteration-$ITERATION.json"
```

### Step 5: Filter for NEW Comments Only

On iterations after the first, compare with previous iteration to find new comments:

```bash
if [[ $ITERATION -gt 1 ]]; then
  PREV_FILE="$FEEDBACK_DIR/PR-$PR_NUM-iteration-$((ITERATION - 1)).json"

  # Extract comment IDs from previous iteration
  # Compare to find comments not in previous iteration
  jq --slurpfile prev "$PREV_FILE" \
    '[.[] | select(.id as $id | $prev[0] | map(.id) | contains([$id]) | not)]' \
    "$FEEDBACK_FILE" \
    > "$FEEDBACK_DIR/PR-$PR_NUM-new.json"

  FEEDBACK_FILE="$FEEDBACK_DIR/PR-$PR_NUM-new.json"
  NEW_COMMENT_COUNT=$(jq 'length' "$FEEDBACK_FILE")

  if [[ "$NEW_COMMENT_COUNT" -eq 0 ]]; then
    echo "✅ No new comments - previous fixes resolved all issues!"
    exit 0
  fi

  echo "📊 Found $NEW_COMMENT_COUNT new comment(s) since last iteration"
else
  NEW_COMMENT_COUNT="$COMMENT_COUNT"
fi
```

### Step 6: Categorize Feedback

Analyze comments to determine severity:

```bash
# Count blocking vs non-blocking comments
BLOCKING=$(jq '[.[] | select(.body | test("\\[BLOCKING\\]|must fix|critical|security|error"; "i"))] | length' "$FEEDBACK_FILE")
SUGGESTIONS=$(jq '[.[] | select(.body | test("consider|suggestion|nitpick|optional|nit:"; "i"))] | length' "$FEEDBACK_FILE")
OTHER=$((NEW_COMMENT_COUNT - BLOCKING - SUGGESTIONS))

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Feedback Breakdown (Iteration $ITERATION)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚫 Blocking issues: $BLOCKING"
echo "💡 Suggestions: $SUGGESTIONS"
echo "📝 Other comments: $OTHER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 7: Display Feedback

Show comments in readable format:

```bash
echo ""
echo "📍 Feedback Details:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

jq -r '.[] | "
📂 File: \(.path // "General")
📍 Line: \(.line // "N/A")
👤 Reviewer: \(.user.login)
💬 Comment:
\(.body)
🔗 \(.html_url)
"' "$FEEDBACK_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 8: Apply Fixes

This is where Claude Code reads the feedback and makes changes:

```bash
echo ""
echo "🤖 Analyzing feedback and applying fixes..."
echo ""

# The feedback is now available in structured JSON format
# Claude Code will:
# 1. Read each comment
# 2. Understand the requested change
# 3. Make the code modifications
# 4. Verify the fix addresses the feedback

# Example feedback structure:
# {
#   "path": "src/api/users.ts",
#   "line": 42,
#   "body": "This function should validate email format before saving",
#   "user": {"login": "claudebot"},
#   "html_url": "https://github.com/.../pull/42#discussion_r123"
# }

# Claude processes this and makes appropriate code changes
```

**Processing logic:**
- Read each comment from JSON
- Identify file and line number
- Understand the requested change
- Apply the fix using Edit tool
- Handle multiple comments per file
- Skip already-applied fixes (if re-running)

### Step 9: Commit Fixes

After applying all fixes for this iteration:

```bash
# Check if any changes were made
if git diff --quiet && git diff --cached --quiet; then
  echo "⚠️  No changes made - feedback may not be actionable"
  echo "Manual review recommended"
  exit 1
fi

# Stage all changes
git add -A

# Create descriptive commit message
COMMIT_MSG="🤖 Address ClaudeBot feedback (iteration $ITERATION)

Addressed $NEW_COMMENT_COUNT comment(s):
$(jq -r '.[] | "- \(.path // "general"):\(.line // "N/A") - \(.body | split("\n") | first)"' "$FEEDBACK_FILE" | head -5)

$(if [[ $NEW_COMMENT_COUNT -gt 5 ]]; then echo "...and $((NEW_COMMENT_COUNT - 5)) more"; fi)

Refs: $FEEDBACK_DIR/PR-$PR_NUM-iteration-$ITERATION.json"

# Commit with descriptive message
git commit -m "$COMMIT_MSG"

echo "✅ Changes committed"
```

### Step 10: Push Changes

```bash
git push

echo "✅ Changes pushed to remote"
echo "ClaudeBot will re-review the changes..."
```

### Step 11: Check for Infinite Loop

Detect if the same issues keep appearing:

```bash
if [[ $ITERATION -gt 1 ]]; then
  echo ""
  echo "🔍 Checking for repeated issues..."

  # Compare file:line locations between iterations
  PREV_ISSUES=$(jq -r '.[] | "\(.path // "general"):\(.line // "0")"' "$PREV_FILE" | sort)
  CURR_ISSUES=$(jq -r '.[] | "\(.path // "general"):\(.line // "0")"' "$FEEDBACK_FILE" | sort)

  REPEATED=$(comm -12 <(echo "$PREV_ISSUES") <(echo "$CURR_ISSUES") | wc -l)

  if [[ "$REPEATED" -gt 0 ]]; then
    echo "⚠️  WARNING: $REPEATED issue(s) persist after fix attempt"
    echo ""
    echo "Repeated issues:"
    comm -12 <(echo "$PREV_ISSUES") <(echo "$CURR_ISSUES")
    echo ""
    echo "This may indicate:"
    echo "- Fix was not correctly applied"
    echo "- ClaudeBot requires different approach"
    echo "- Issue cannot be automatically fixed"
    echo ""
    echo "Stopping iteration to prevent infinite loop"
    echo "Manual review required"
    exit 1
  fi

  echo "✅ No repeated issues detected"
fi
```

### Step 12: Continue or Exit

```bash
# If we haven't hit max iterations, continue
if [[ $ITERATION -lt $MAX_ITERATIONS ]]; then
  echo ""
  echo "✅ Iteration $ITERATION complete"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  # Loop continues
else
  echo ""
  echo "⏰ Maximum iterations ($MAX_ITERATIONS) reached"
  echo ""
  echo "Status: Further fixes may be needed"
  echo "Recommendation: Manual review of PR"
  echo ""
  echo "Feedback history available in:"
  echo "  $FEEDBACK_DIR/"
  exit 1
fi
```

## Safety Mechanisms

### 1. Max Iterations Limit

Prevents infinite loops:

```
Default: 3 iterations
After 3 cycles: Stop and request manual review
```

### 2. Infinite Loop Detection

Compares file:line locations between iterations:

```
If same location appears in consecutive iterations:
  → Stop immediately
  → Report repeated issues
  → Require manual intervention
```

### 3. Timeout on Polling

Doesn't wait forever for comments:

```
Default: 10 attempts × 30 seconds = 5 minutes
After timeout: Assume PR is clean
```

### 4. No Changes Detection

If fixes result in no git changes:

```
→ Indicates non-actionable feedback
→ Stop iteration
→ Recommend manual review
```

## Error Handling

### PR Not Found

```
❌ ERROR: No PR found for current branch

Suggestions:
- Run pr-creator first to create a PR
- Check that you're on the correct branch
- Verify .claude/feedback/current-pr.txt exists
```

### GitHub CLI Auth Failure

```
❌ ERROR: Failed to fetch comments

gh: command not found
OR
gh: Not authenticated

Solution: Run 'gh auth login'
```

### No Bot Comments (Timeout)

```
✅ No feedback found after 300 seconds
PR appears clean - no comments from ClaudeBot

This could mean:
- ClaudeBot hasn't reviewed yet (may take longer)
- PR is clean and has no issues
- ClaudeBot is not configured for this repository
```

### Max Iterations Reached

```
⏰ Maximum iterations (3) reached

Status: Some issues may remain
Recommendation: Manual review of PR

Feedback history available in:
  .claude/feedback/

Recent iterations:
- Iteration 1: 5 comments addressed
- Iteration 2: 3 comments addressed
- Iteration 3: 2 comments addressed (CURRENT)
```

## Integration with Other Skills

**Depends on:**
- `pr-creator` (provides PR number via .claude/feedback/current-pr.txt)
- GitHub CLI (`gh`)
- **Official Claude GitHub App (recommended)** - for best results
- ClaudeBot or other bot configured on repository

**Provides:**
- Feedback history in `.claude/feedback/`
- Clean PR (or clear indication of what's left)

**Used by:**
- `thoughtful-pr-workflow` (orchestrates entire flow)

**Note:** While this skill works with any bot-generated PR comments, it's optimized for the official Claude GitHub App. Install via `/install-github-app` in Claude Code for the best experience.

## Examples

### Example 1: Successful Iteration to Clean PR

```
🔄 Starting feedback iteration loop (max 3 iterations)

Iteration 1:
⏳ Waiting for ClaudeBot feedback...
✅ Found 3 comments after 60 seconds
📊 Feedback: 2 blocking, 1 suggestion
🤖 Applying fixes...
✅ Changes committed and pushed

Iteration 2:
⏳ Waiting for ClaudeBot feedback...
✅ Found 1 comment after 30 seconds
📊 Feedback: 0 blocking, 1 suggestion
🤖 Applying fixes...
✅ Changes committed and pushed

Iteration 3:
⏳ Waiting for ClaudeBot feedback...
✅ No new comments after 300 seconds
✅ PR is clean!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Feedback Loop Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total iterations: 2
Comments addressed: 4
Status: PR ready for approval
```

### Example 2: Infinite Loop Detected

```
Iteration 2:
⏳ Waiting for ClaudeBot feedback...
✅ Found 2 comments after 45 seconds

🔍 Checking for repeated issues...
⚠️  WARNING: 2 issue(s) persist after fix attempt

Repeated issues:
src/api/auth.ts:42
src/utils/validation.ts:18

This may indicate:
- Fix was not correctly applied
- ClaudeBot requires different approach
- Issue cannot be automatically fixed

Stopping iteration to prevent infinite loop
Manual review required
```

### Example 3: Max Iterations Reached

```
Iteration 3:
⏳ Waiting for ClaudeBot feedback...
✅ Found 1 comment after 30 seconds
🤖 Applying fixes...
✅ Changes committed and pushed

⏰ Maximum iterations (3) reached

Some feedback may still be pending ClaudeBot review
Recommendation: Wait for final review or manually check PR

Feedback history:
- .claude/feedback/PR-42-iteration-1.json (3 comments)
- .claude/feedback/PR-42-iteration-2.json (2 comments)
- .claude/feedback/PR-42-iteration-3.json (1 comment)
```

## Success Criteria

✅ Automatically applies fixes based on structured feedback
✅ Detects and prevents infinite loops
✅ Stops at appropriate limits
✅ Provides clear status at each step
✅ Saves feedback history for debugging
✅ Integrates with PR creation workflow

## Technical Notes

**Requirements:**
- Git 2.23+
- GitHub CLI (`gh`) authenticated
- `jq` for JSON processing
- Bash or compatible shell
- ClaudeBot or similar bot configured on repository

**Files created:**
- `.claude/feedback/PR-{number}-iteration-{n}.json` (raw feedback)
- `.claude/feedback/PR-{number}-new.json` (filtered new comments)

**Assumptions:**
- ClaudeBot leaves comments via GitHub API
- Comments have standard structure (path, line, body, user, etc.)
- Bot usernames contain "claude", "bot", or "github-actions"

**Customization:**
- Adjust `MAX_ITERATIONS`, `POLL_INTERVAL`, `MAX_POLL_ATTEMPTS` as needed
- Modify blocking/suggestion detection patterns
- Customize commit message format
