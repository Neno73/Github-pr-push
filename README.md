# GitHub Push PR - Claude Code Plugin

> **Automate your entire GitHub PR workflow with built-in safety, security, and feedback iteration.**

Transform Claude Code into a complete PR automation system that enforces git best practices, prevents secret leaks, creates well-formatted pull requests, and automatically iterates on ClaudeBot feedback until your PR is clean.

## 🎯 What This Plugin Does

This plugin solves these common development workflow pain points:

1. ❌ **Claude working directly on main/master** → ✅ Automatic feature branch enforcement
2. ❌ **Manual PR creation after work** → ✅ Automated PR generation with meaningful descriptions
3. ❌ **Disconnected feedback loops** → ✅ ClaudeBot feedback automatically applied
4. ❌ **Risk of committing secrets** → ✅ Comprehensive security checks before every push
5. ❌ **Manual back-and-forth iterations** → ✅ Automated iteration until PR is clean

## ✨ Features

### 🔒 Security First
- **Comprehensive secret detection** (API keys, tokens, passwords, credentials)
- **Environment file blocking** (.env files never committed)
- **Automatic .gitignore validation**
- **Pattern-based scanning** for 20+ secret formats
- **Hard blocks on security violations**

### 🌿 Git Workflow Enforcement
- **Never work on main/master** - automatic feature branch creation
- **Smart branch naming** from task context
- **Handles uncommitted changes** safely
- **Branch conflict resolution**

### 🤖 Automated PR Creation
- **Security-gated pushing** - secrets checked before every push
- **Auto-generated PR titles** from commit messages
- **Rich PR descriptions** with summary, changes, and test plan
- **Claude Code attribution** footer

### 🔄 Feedback Iteration Loop
- **Smart polling** for ClaudeBot comments
- **Categorized feedback** (blocking vs suggestions)
- **Automatic fix application** and pushing
- **Infinite loop detection** (stops if same issue persists)
- **Max iteration limits** (prevents runaway loops)
- **Feedback history tracking**

### 🎭 Thoughtful Orchestration
- **End-to-end workflow automation**
- **Optional requirements clarification** (integrates with thoughtful-dev)
- **Optional implementation planning** (for complex tasks)
- **Clear progress tracking** with todo lists
- **Comprehensive completion reports**

## 📦 Installation

### Prerequisites

```bash
# Required
git --version        # Git 2.23+
gh --version         # GitHub CLI
jq --version         # JSON processor

# Optional (for enhanced workflow)
claude-code          # With thoughtful-dev plugin for planning
```

### Install GitHub CLI

```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows
winget install GitHub.cli
```

**Authenticate GitHub CLI:**

```bash
gh auth login
```

### Install Plugin

#### Option 1: Install from Marketplace (Recommended)

```bash
# Add the marketplace (if not already added)
claude plugin add-marketplace Neno73/github-push-pr-marketplace

# Install the plugin
claude plugin install github-push-pr
```

#### Option 2: Install from Source

```bash
# Clone the repository
git clone https://github.com/Neno73/github-push-pr.git
cd github-push-pr

# Install locally
claude plugin install .
```

#### Option 3: Manual Installation

1. Download the latest release ZIP
2. Extract to `~/.claude/plugins/github-push-pr`
3. Reload Claude Code

### Verify Installation

```bash
# List installed plugins
claude plugin list

# You should see: github-push-pr
```

### Optional: Install Official ClaudeBot (Recommended)

For the best experience with the feedback iteration loop, install the official Claude GitHub App:

```bash
# Option 1: Use Claude Code installer (easiest)
claude
> "/install-github-app"

# Option 2: Manual installation
# Visit: https://github.com/apps/claude
```

**Why install the GitHub App?**

The official ClaudeBot enhances this plugin's feedback loop functionality:

| Feature | Without GitHub App | With GitHub App |
|---------|-------------------|-----------------|
| **PR Comments** | Generic bot detection | Official ClaudeBot reviews |
| **@claude mentions** | ❌ Not available | ✅ Team can mention @claude in PRs |
| **Comment Structure** | Basic GitHub comments | Rich, structured feedback |
| **Integration** | Works but generic | Seamless integration |
| **Team Collaboration** | Manual only | @claude assists entire team |

**Note:** This plugin works standalone, but the feedback loop is optimized for official ClaudeBot reviews.

## 🚀 Usage

### Quick Start

```bash
# Start Claude Code in your repository
claude

# Then simply ask Claude to implement a feature:
> "Implement rate limiting for API endpoints and create a PR"
```

Claude will automatically:
1. ✅ Create a feature branch
2. ✅ Implement the feature
3. ✅ Run security checks
4. ✅ Create a GitHub PR
5. ✅ Iterate on ClaudeBot feedback
6. ✅ Report completion with PR URL

### Individual Skills

You can also invoke skills individually:

#### 1. Git Workflow Enforcer

```
> "Ensure I'm on a feature branch for this work"
```

**What it does:**
- Checks current branch
- Creates `feature/[description]` if on main/master
- Handles uncommitted changes safely

#### 2. PR Creator

```
> "Create a PR for my changes"
```

**What it does:**
- Runs comprehensive security checks
- Generates PR title/body from commits
- Pushes to remote
- Creates GitHub PR
- Saves PR number for feedback loop

**Requirements:**
- At least one commit on current branch
- Not on main/master branch
- Security checks pass

#### 3. ClaudeBot Feedback Loop

```
> "Apply ClaudeBot feedback on my PR"
```

**What it does:**
- Polls for ClaudeBot comments (max 5 minutes)
- Fetches and categorizes feedback
- Applies fixes automatically
- Commits and pushes changes
- Repeats until PR is clean (max 3 iterations)

**Stops when:**
- No new comments (PR is clean)
- Max iterations reached (3)
- Same issue appears twice (infinite loop detected)

#### 4. Thoughtful PR Workflow (Orchestrator)

```
> "Full workflow: implement user authentication and create PR"
```

**What it does:**
- Enforces git workflow
- Clarifies requirements (if needed)
- Plans implementation (if non-trivial)
- Executes implementation
- Creates PR with security checks
- Iterates on ClaudeBot feedback
- Reports completion

## 📚 Examples

### Example 1: Simple Feature

```
You: "Add a loading spinner to the submit button"

Claude:
✅ Git workflow enforced (created: feature/add-loading-spinner)
🤖 Implementing changes...
   - Modified Button component
   - Added loading prop
   - Updated styling
✅ Changes committed
🔒 Security checks passed
✅ PR created: #42
🔄 Waiting for ClaudeBot feedback...
✅ Found 1 comment (add accessibility label)
🤖 Applying fix...
✅ No new comments - PR is clean!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Workflow Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PR #42: https://github.com/user/repo/pull/42
Status: Ready for review
```

### Example 2: Security Block

```
You: "Add API configuration"

Claude:
✅ Git workflow enforced
🤖 Implementing changes...
✅ Changes committed
🔒 Running security checks...

❌ BLOCKED: Potential secret detected!
Pattern: ghp_[a-zA-Z0-9]{36}

Matching lines:
+ const githubToken = "ghp_abc123..."

Please remove these secrets before pushing.
Consider using environment variables.

Workflow stopped - fix security issues first

You: "Use environment variables instead"

Claude:
🤖 Updated to use process.env.GITHUB_TOKEN
✅ Changes committed
🔒 Security checks passed
✅ PR created: #43
```

### Example 3: Complex Feature with Planning

```
You: "Implement rate limiting for our API endpoints"

Claude:
✅ Git workflow enforced
🔄 Requirements need clarification...

Let me clarify:
1. Which endpoints should have rate limiting?
   - All authenticated endpoints
   - Public endpoints only
   - Specific routes

2. What are the rate limits?
   - Requests per minute
   - Per user or per IP?

3. How should we handle limit exceeded?
   - 429 status code
   - Retry-After header
   - Custom error message

You: "All authenticated endpoints, 100 req/min per user, 429 with retry-after"

Claude:
✅ Requirements clarified
🔄 Planning implementation...

Proposed approach:
- Middleware-based rate limiting
- Redis for distributed counting
- Per-user tracking via JWT
- Configurable limits

Risks:
- Redis dependency (mitigation: fallback to in-memory)
- Performance impact (mitigation: Redis pipeline)

Proceed with this approach?

You: "Yes, proceed"

Claude:
🤖 Implementing rate limit middleware...
✅ Created middleware/rateLimit.ts
✅ Added Redis client setup
✅ Configured per-endpoint limits
✅ Added tests
✅ Updated API documentation
🔒 Security checks passed
✅ PR created: #44
🔄 Iterating on ClaudeBot feedback...
   - Iteration 1: 4 comments (error handling, tests, docs)
   - Iteration 2: 2 comments (edge cases)
   - Iteration 3: No comments
✅ PR is clean!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Workflow Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commits: 8 total (6 implementation + 2 feedback fixes)
PR #44: https://github.com/user/repo/pull/44
Status: Ready for review
```

## 🔧 Configuration

### Default Settings

```bash
# Feedback loop
MAX_ITERATIONS=3              # Maximum feedback iterations
POLL_INTERVAL=30              # Seconds between comment checks
MAX_POLL_ATTEMPTS=10          # Max polling attempts (5 minutes)

# Security
FEEDBACK_DIR=.claude/feedback # Where feedback is stored
```

### Customization

Create `.claude/github-pr-config.json` in your repository:

```json
{
  "feedbackLoop": {
    "maxIterations": 5,
    "pollInterval": 20,
    "maxPollAttempts": 15
  },
  "security": {
    "additionalPatterns": [
      "custom-api-key-pattern"
    ],
    "excludePatterns": [
      "safe-pattern-to-ignore"
    ]
  },
  "prTemplate": {
    "additionalSections": [
      "## Screenshots",
      "## Performance Impact"
    ]
  }
}
```

### Integration with Official GitHub Action

This plugin works standalone but combines powerfully with the **official Claude GitHub Action**:

- **This plugin:** Local workflow automation + security enforcement
- **GitHub Action:** Team collaboration via @claude mentions + CI/CD

**See the complete integration guide:** [INTEGRATION.md](INTEGRATION.md)

Quick setup:
```bash
# 1. Install this plugin
claude plugin install github-push-pr

# 2. Install official GitHub App
claude
> "/install-github-app"

# 3. Now you have both local automation AND team collaboration!
```

### Integration with thoughtful-dev

This plugin works standalone but integrates beautifully with [thoughtful-dev](https://github.com/Neno73/thoughtful-dev):

- **requirements-clarifier** - Automatically clarifies ambiguous requests
- **implementation-planner** - Plans complex implementations
- **breakthrough-generator** - Helps when stuck on problems

Install both for the complete thoughtful development experience:

```bash
claude plugin install thoughtful-dev
claude plugin install github-push-pr
```

## 🧪 Testing

Run the test suite to verify everything works:

```bash
# Run all tests
./tests/run-all-tests.sh

# Run individual tests
./tests/test-git-workflow-enforcer.sh
./tests/test-security-checks.sh
```

**Test coverage:**
- ✅ Git workflow enforcement
- ✅ Branch naming conventions
- ✅ Security checks (secrets, .env files)
- ✅ .gitignore validation
- ✅ Placeholder vs real secret detection

## 📖 Documentation

### Skills

- **[git-workflow-enforcer](skills/git-workflow-enforcer/SKILL.md)** - Ensures feature branch usage
- **[pr-creator](skills/pr-creator/SKILL.md)** - Creates PRs with security checks
- **[claudebot-feedback-loop](skills/claudebot-feedback-loop/SKILL.md)** - Iterates on feedback
- **[thoughtful-pr-workflow](skills/thoughtful-pr-workflow/SKILL.md)** - End-to-end orchestrator

### Scripts

- **[check-secrets.sh](scripts/check-secrets.sh)** - Security scanning script

### Architecture

```
User Request
    ↓
┌─────────────────────────────┐
│ thoughtful-pr-workflow      │  Orchestrator
│ (Manages entire flow)       │
└──────────┬──────────────────┘
           │
           ├──▶ git-workflow-enforcer
           │    └─ Ensure feature branch
           │
           ├──▶ thoughtful-dev (optional)
           │    ├─ requirements-clarifier
           │    └─ implementation-planner
           │
           ├──▶ Implementation
           │    └─ Write code, commit
           │
           ├──▶ pr-creator
           │    ├─ Run security checks
           │    ├─ Push to remote
           │    └─ Create GitHub PR
           │
           └──▶ claudebot-feedback-loop
                ├─ Poll for comments
                ├─ Apply fixes
                ├─ Push changes
                └─ Repeat until clean
```

## 🛡️ Security

### Secret Detection Patterns

The plugin detects these secret types:

- OpenAI API keys (`sk-...`)
- GitHub tokens (`ghp_...`, `gho_...`, `ghs_...`, etc.)
- AWS credentials (`AKIA...`, `access:secret`)
- Google API keys (`AIza...`)
- Stripe keys (`sk_live_...`, `pk_live_...`)
- Slack tokens (`xoxb-...`, `xoxp-...`)
- Database URLs with passwords
- Generic API keys and tokens
- And 10+ more patterns

### What Gets Checked

1. **Staged files** - Never commit .env files
2. **Diff content** - Scan for secret patterns in code changes
3. **Hardcoded values** - Detect `API_KEY="real_value"` patterns
4. **.gitignore** - Ensure sensitive patterns are ignored

### Bypass Protection

**Security checks CANNOT be bypassed.** If a secret is detected:

1. Workflow stops immediately
2. Secret pattern is displayed
3. User must fix before continuing
4. No force-push options

This is by design - better to stop and fix than leak secrets.

## 🤝 Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Areas for contribution:**
- Additional secret detection patterns
- Support for other CI/CD systems (GitLab, Bitbucket)
- Custom PR templates
- Integration tests
- Documentation improvements

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Built following [thoughtful-dev](https://github.com/Neno73/thoughtful-dev) methodology
- Inspired by GitHub Actions workflows and reviewdog
- Secret patterns adapted from industry best practices

## 🔗 Links

- **GitHub Repository:** https://github.com/Neno73/github-push-pr
- **Plugin Marketplace:** [Claude Code Plugins](https://github.com/Neno73/thoughtful-dev-marketplace)
- **Related Plugin:** [thoughtful-dev](https://github.com/Neno73/thoughtful-dev)
- **Issues & Support:** https://github.com/Neno73/github-push-pr/issues

## 📊 Version

**Current Version:** 1.0.0

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

**Built with ❤️ by [Neno73](https://github.com/Neno73)**

*Transform your Claude Code into a complete GitHub workflow automation system.*
