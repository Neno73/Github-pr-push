# Integration Guide: Plugin + Official Claude GitHub Action

This guide explains how to use the **GitHub Push PR plugin** alongside the **official Claude GitHub Action** for a complete development workflow.

## 🎯 Overview

### Two Complementary Tools

| Tool | Purpose | Where It Runs | Best For |
|------|---------|---------------|----------|
| **This Plugin** | Local development automation | Your machine (via Claude Code CLI) | Pre-PR workflow, security checks, local iteration |
| **Official GitHub Action** | CI/CD & team collaboration | GitHub Actions (cloud) | Team collaboration, automated reviews, @claude mentions |

### Why Use Both?

**This Plugin Provides:**
- ✅ Enforced git workflow (feature branches)
- ✅ Pre-push security checks (blocks secrets)
- ✅ Automated PR creation
- ✅ Local feedback iteration
- ✅ Solo developer workflow

**Official GitHub Action Adds:**
- ✅ Team collaboration via @claude mentions
- ✅ Automatic PR reviews
- ✅ CI/CD pipeline integration
- ✅ Scheduled automation
- ✅ GitHub-native experience

## 🚀 Setup Guide

### Step 1: Install This Plugin

Follow the [main installation guide](README.md#installation):

```bash
# Via marketplace
claude plugin install github-push-pr

# Or from source
git clone https://github.com/Neno73/github-push-pr.git
cd github-push-pr
claude plugin install .
```

### Step 2: Install Official Claude GitHub App

**Option A: Quick Install via Claude Code**

```bash
claude
> "/install-github-app"
```

This command will:
1. Guide you through GitHub App installation
2. Help configure repository secrets
3. Verify the setup

**Option B: Manual Installation**

1. Visit https://github.com/apps/claude
2. Click "Install"
3. Select repositories
4. Add `ANTHROPIC_API_KEY` to repository secrets

### Step 3: Configure GitHub Action (Optional)

If you want automated workflows beyond @claude mentions, create `.github/workflows/claude.yml`:

```yaml
name: Claude Code Automation

on:
  # Respond to @claude mentions in PR comments
  issue_comment:
    types: [created]

  # Respond to @claude mentions in PR review comments
  pull_request_review_comment:
    types: [created]

permissions:
  contents: write
  pull-requests: write
  issues: write

jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Claude Code
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: "--max-turns 5"
```

**Note:** For @claude mentions, the workflow above is sufficient. The GitHub App handles the magic!

## 📊 Workflow Patterns

### Pattern 1: Solo Developer (Plugin Only)

**Use case:** You're working alone and want full local automation.

```bash
# 1. Start work (plugin enforces branch)
cd your-project
claude

> "Implement user authentication and create PR"

# Plugin does everything:
# - Creates feature branch
# - Implements feature
# - Runs security checks
# - Creates PR
# - Fetches ClaudeBot feedback
# - Applies fixes locally
# - Repeats until clean
```

**Advantages:**
- Complete local control
- Fast iteration
- No GitHub Action credits used

### Pattern 2: Hybrid Local + Cloud (Recommended)

**Use case:** You want local automation + team collaboration.

```bash
# 1. Use plugin for initial PR creation
claude

> "Implement rate limiting and create PR"

# Plugin creates PR with security checks

# 2. Team uses @claude in PR for feedback
# (In GitHub PR comments)
"@claude review this implementation"
"@claude suggest performance improvements"

# 3. Optionally apply feedback locally
> "Apply ClaudeBot feedback from PR #42"

# Plugin fetches comments and applies fixes
```

**Advantages:**
- Best of both worlds
- Team can collaborate via @claude
- You maintain local workflow
- Security enforced before push

### Pattern 3: Team Collaboration (GitHub Action Focus)

**Use case:** Multiple developers, cloud-first workflow.

```bash
# 1. Use plugin for branch enforcement only
claude

> "Ensure I'm on a feature branch"

# 2. Implement changes manually or with Claude locally

# 3. Create PR manually or via plugin
git push
gh pr create

# 4. Team uses @claude extensively in PR
"@claude review this"
"@claude write tests for the new API endpoint"
"@claude check for security issues"

# 5. @claude responds automatically in PR
```

**Advantages:**
- Full team collaboration
- Cloud-based automation
- GitHub-native experience
- No local tooling required (beyond git)

### Pattern 4: CI/CD Automation (Advanced)

**Use case:** Automated PR creation from issues.

```yaml
# .github/workflows/claude-issue-to-pr.yml
name: Issue to PR Automation

on:
  issues:
    types: [labeled]

jobs:
  create-pr:
    if: contains(github.event.label.name, 'auto-implement')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create PR from Issue
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Read issue #${{ github.event.issue.number }} and implement the requested feature.
            Create a pull request with the implementation.
          claude_args: "--max-turns 10"
```

**Advantages:**
- Fully automated workflow
- Issue → Implementation → PR
- No manual intervention
- Great for team backlogs

## 🔄 Detailed Integration Scenarios

### Scenario A: Starting Fresh on a Task

**Using both tools optimally:**

```bash
# Day 1: Local development
claude

> "Implement OAuth login and create PR"

# Plugin:
# ✅ Creates feature/implement-oauth-login
# ✅ Implements OAuth
# ✅ Security checks pass
# ✅ Creates PR #123
# ✅ Fetches ClaudeBot initial feedback
# ✅ Applies obvious fixes

# PR is now in good shape but has 2 remaining comments
```

```
# Day 2: Team collaboration
# Team member in GitHub PR:
"@claude the token refresh logic seems off, can you fix it?"

# ClaudeBot responds in PR with fix

# You pull latest:
git pull

# Or use plugin to apply:
claude

> "Apply latest ClaudeBot feedback from my PR"
```

### Scenario B: Code Review Integration

**Combining human + bot reviews:**

```bash
# 1. Create PR via plugin (clean, security-checked)
claude

> "Create PR for my authentication changes"

# 2. Request reviews (in GitHub)
- Assign human reviewers
- @claude for automated check

# 3. Both provide feedback:
- Human: "Nice work! One concern about error handling..."
- @claude: "Detected potential SQL injection risk in line 42..."

# 4. Apply feedback
claude

> "Apply ClaudeBot feedback"

# Plugin applies automated suggestions

# Fix human feedback manually or:
> "@claude fix the error handling concern from @reviewer"
```

### Scenario C: Security-First Workflow

**Using plugin's security checks with GitHub Action:**

```bash
# 1. Plugin prevents secrets from reaching GitHub
claude

> "Add Stripe integration and create PR"

# Plugin catches:
❌ BLOCKED: Potential secret detected!
Pattern: sk_live_[0-9a-zA-Z]{24,}

# You fix it (move to .env)

# 2. PR created successfully

# 3. GitHub Action adds additional checks
# .github/workflows/security-check.yml
name: Additional Security Scan
on: [pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Claude Security Review
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Review this PR for security issues"
```

**Defense in depth:**
- Plugin blocks obvious secrets locally
- GitHub Action adds cloud-based scanning
- Human review for final approval

## 🛠️ Configuration Best Practices

### For This Plugin

Create `.claude/github-pr-config.json` (optional):

```json
{
  "feedbackLoop": {
    "maxIterations": 5,
    "pollInterval": 30
  },
  "security": {
    "strictMode": true
  }
}
```

### For GitHub Action

**Minimal configuration** (responds to @claude):

```yaml
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
```

**Advanced configuration** (scheduled checks):

```yaml
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Monday 9am

jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: "--max-turns 10 --model opus"
```

### Project Standards (CLAUDE.md)

Create `.claude/CLAUDE.md` or `CLAUDE.md` in your repo root:

```markdown
# Project Standards for Claude

## Code Style
- Use TypeScript strict mode
- Follow Airbnb style guide
- Max line length: 100 characters

## Testing
- Write tests for all new features
- Minimum 80% coverage
- Use Jest for unit tests

## Security
- Never commit secrets
- All API keys via environment variables
- Validate all user input

## Git Workflow
- Feature branches only (enforced by github-push-pr plugin)
- Conventional commit messages
- Squash merge to main
```

Both this plugin and the GitHub Action will respect these standards!

## 📈 Metrics & Monitoring

### Track Plugin Usage

```bash
# View plugin activity
ls -la .claude/feedback/

# Check recent PRs created via plugin
gh pr list --author "@me" --limit 10
```

### Track GitHub Action Usage

```bash
# View action runs
gh run list --workflow=claude.yml

# View action logs
gh run view <run-id> --log
```

### Cost Monitoring

**This Plugin:**
- Uses your local Claude Code API key
- Only calls API during actual work
- No cost for git operations or security checks

**GitHub Action:**
- Uses repository secret API key
- Charges per @claude mention response
- Set `--max-turns` to control cost

**Tip:** Use plugin for bulk work (implementation), use @claude for specific questions.

## 🚨 Troubleshooting

### Plugin Can't Find ClaudeBot Comments

**Symptoms:**
```
⏳ Waiting for ClaudeBot feedback...
✅ No feedback found after 300 seconds
```

**Solutions:**
1. Verify GitHub App is installed: `gh auth status`
2. Check if ClaudeBot reviewed the PR (visit PR in browser)
3. Ensure bot username matches detection pattern
4. Try manual @claude mention in PR to trigger review

### GitHub Action Not Responding to @claude

**Symptoms:**
- @claude mention but no response
- Action doesn't trigger

**Solutions:**
1. Check workflow file triggers include `issue_comment`
2. Verify `ANTHROPIC_API_KEY` secret exists
3. Check action permissions (needs `write` for comments)
4. View action logs: `gh run list --workflow=claude.yml`

### Conflicts Between Local and Cloud Changes

**Symptoms:**
```
git push
! [rejected] feature/my-branch -> feature/my-branch (non-fast-forward)
```

**Solution:**
```bash
# Pull and rebase
git pull --rebase origin feature/my-branch

# Resolve conflicts if any
git push
```

## 🎓 Best Practices

### Do's

✅ Use plugin for initial PR creation (security enforced)
✅ Use @claude for team collaboration in PRs
✅ Set up both for best workflow
✅ Keep `CLAUDE.md` updated with project standards
✅ Monitor API usage (both local and cloud)
✅ Use plugin's security checks before every push

### Don'ts

❌ Don't skip plugin security checks
❌ Don't set unlimited `--max-turns` in GitHub Action
❌ Don't commit secrets (plugin blocks but still be careful)
❌ Don't use @claude for every single comment (cost)
❌ Don't bypass feature branch enforcement

## 📚 Additional Resources

- **This Plugin:** [Full Documentation](README.md)
- **GitHub Action:** [Official Docs](https://docs.claude.com/en/docs/claude-code/github-actions)
- **Claude Code CLI:** [Getting Started](https://docs.claude.com/en/docs/claude-code)
- **Best Practices:** [thoughtful-dev methodology](https://github.com/Neno73/thoughtful-dev)

## 💬 Support

**Plugin Issues:**
- GitHub Issues: https://github.com/Neno73/github-push-pr/issues

**GitHub Action Issues:**
- Official Support: Check GitHub Action logs
- Claude Code Docs: https://docs.claude.com

**Integration Questions:**
- Review this guide
- Check both repositories for examples
- Test with a small PR first

---

**TL;DR:** Use this plugin for local workflow automation and security. Add the official GitHub Action for team collaboration via @claude mentions. Together, they provide a complete development → review → merge workflow.
