# Contributing to GitHub Push PR Plugin

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## 🎯 How to Contribute

### Reporting Bugs

**Before submitting a bug report:**
1. Check existing issues to avoid duplicates
2. Verify you're using the latest version
3. Confirm the issue is reproducible

**Bug report should include:**
- Clear, descriptive title
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Git version, gh version)
- Relevant logs or error messages
- Screenshots if applicable

**Example:**

```
**Bug:** Security check blocks valid .env.example file

**Steps to reproduce:**
1. Create .env.example with placeholder values
2. Commit file
3. Run pr-creator skill

**Expected:** .env.example should be allowed
**Actual:** Blocked as potential secret

**Environment:**
- OS: Ubuntu 22.04
- Git: 2.34.1
- gh: 2.40.0
- Plugin version: 1.0.0

**Error message:**
❌ BLOCKED: Environment file in commit
.env.example
```

### Suggesting Features

**Feature requests should include:**
- Clear use case (what problem does it solve?)
- Proposed solution
- Alternative approaches considered
- Impact on existing functionality
- Willingness to implement it yourself

**Good feature request example:**

```
**Feature:** Support for GitLab MR creation

**Use case:** Teams using GitLab instead of GitHub want the same
automated workflow.

**Proposed solution:**
- Add `gitlab-mr-creator` skill
- Use `glab` CLI instead of `gh`
- Keep same security checks
- Adapt feedback loop for GitLab API

**Alternatives:**
- Generic git platform abstraction layer
- Separate plugin for GitLab

**Implementation:** I can implement the glab integration if the
approach is approved.
```

### Pull Requests

**Before creating a PR:**
1. Discuss major changes in an issue first
2. Fork the repository
3. Create a feature branch (`git checkout -b feature/your-feature`)
4. Follow the coding standards (see below)
5. Add tests for new functionality
6. Update documentation

**PR checklist:**
- [ ] Code follows the project style
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commits are clear and descriptive
- [ ] No secrets or sensitive data
- [ ] Branch is up to date with main

**PR description template:**

```markdown
## Description
Brief description of what this PR does

## Motivation
Why is this change needed?

## Changes
- Bullet list of changes made

## Testing
How was this tested?

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No breaking changes (or documented)
```

## 🏗️ Development Setup

### Prerequisites

```bash
git --version      # 2.23+
gh --version       # Latest
jq --version       # Latest
bash --version     # 4.0+
```

### Local Development

1. **Fork and clone:**

```bash
git clone https://github.com/YOUR_USERNAME/github-push-pr.git
cd github-push-pr
```

2. **Create feature branch:**

```bash
git checkout -b feature/my-feature
```

3. **Make changes and test:**

```bash
# Run tests
./tests/run-all-tests.sh

# Test individual components
./tests/test-git-workflow-enforcer.sh
./tests/test-security-checks.sh
```

4. **Install locally for testing:**

```bash
# Link to Claude Code
ln -s $(pwd) ~/.claude/plugins/github-push-pr-dev

# Test with Claude Code
claude
```

### Testing

**Run all tests:**
```bash
./tests/run-all-tests.sh
```

**Add new tests:**
```bash
# Create test file
touch tests/test-new-feature.sh
chmod +x tests/test-new-feature.sh

# Add to run-all-tests.sh
# Follow existing test patterns
```

**Test structure:**
```bash
#!/bin/bash
set -e

# Setup
setup_test_repo() {
  # Create isolated test environment
}

# Cleanup
cleanup() {
  # Remove test artifacts
}
trap cleanup EXIT

# Test cases
test_feature_works() {
  echo "Testing: feature works correctly"
  # Test implementation
  echo "✅ Test passed"
}

# Run
main() {
  setup_test_repo
  test_feature_works
}
main
```

## 📝 Coding Standards

### Bash Scripts

**Style:**
```bash
# Use set -e for error handling
set -e

# Descriptive function names
create_feature_branch() {
  local task_description="$1"
  # Implementation
}

# Clear variable names
BRANCH_NAME="feature/my-feature"  # Good
BN="feature/my-feature"           # Bad

# Comments for complex logic
# This regex extracts the commit message subject
TITLE=$(git log main..HEAD --format=%s | head -1)
```

**Error handling:**
```bash
# Check for required commands
command -v gh >/dev/null 2>&1 || {
  echo "❌ ERROR: gh CLI not found"
  exit 1
}

# Validate inputs
if [[ -z "$PR_NUMBER" ]]; then
  echo "❌ ERROR: PR number required"
  exit 1
fi
```

**Output formatting:**
```bash
# Use consistent symbols
echo "✅ Success message"
echo "❌ Error message"
echo "⚠️  Warning message"
echo "🔄 In progress"
echo "📋 Information"

# Use separators for sections
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section Title"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Claude Code Skills

**SKILL.md format:**
```markdown
---
name: skill-name-lowercase-hyphens
description: Clear, specific description of what this skill does and when to use it. Keep under 200 characters.
---

# Skill Name

## Purpose

Clear statement of what this skill accomplishes.

**Core principle:** One-sentence philosophy.

## When to Activate

**Automatically activate when:**
- Specific trigger condition 1
- Specific trigger condition 2

**Do NOT activate for:**
- Exclusion case 1
- Exclusion case 2

## Workflow

### Step 1: First Step

Clear description with code examples:

```bash
# Example code
VARIABLE="value"
```

### Step 2: Second Step

Continue with clear steps...

## Examples

### Example 1: Common Case

```
User: "Do X"

Action:
1. Step 1
2. Step 2

Output:
Expected output here
```

## Success Criteria

✅ Criterion 1
✅ Criterion 2
```

**Best practices:**
- Keep SKILL.md under 500 lines
- Use progressive disclosure
- Clear examples
- Specific activation criteria
- Concise writing

### Documentation

**Markdown style:**
- Use headers hierarchically (# → ## → ###)
- Code blocks with language tags (\`\`\`bash)
- Bullet points for lists
- Tables for comparisons
- Links for references

**README sections:**
1. What it does (brief)
2. Features
3. Installation
4. Usage with examples
5. Configuration
6. Documentation links
7. Contributing
8. License

## 🔒 Security

### Secret Detection

**Adding new patterns:**

Edit `scripts/check-secrets.sh`:

```bash
# Add to patterns array
local -a patterns=(
  # Existing patterns...
  'your-new-pattern-here'        # Description of what it detects
)
```

**Pattern guidelines:**
- Use regex that matches real secrets
- Avoid false positives
- Add comments explaining the pattern
- Test with real examples (in test suite only)

**Testing patterns:**
```bash
# Add test case in tests/test-security-checks.sh
test_new_secret_pattern() {
  cat > file.txt <<'EOF'
secret_value="your-test-pattern"
EOF

  if bash scripts/check-secrets.sh | grep -q "BLOCKED"; then
    echo "✅ Pattern detected correctly"
  fi
}
```

### Sensitive Data

**Never commit:**
- Real API keys or tokens
- .env files (even if fake-looking)
- User credentials
- Internal URLs or endpoints
- Company-specific information

**Use placeholders:**
```bash
# Good
API_KEY="your_api_key_here"
API_KEY="sk-example123placeholder"

# Bad
API_KEY="sk-abc123realkey789xyz"
```

## 📦 Release Process

### Versioning

Follow [Semantic Versioning](https://semver.org/):
- **Major (X.0.0):** Breaking changes
- **Minor (0.X.0):** New features, backwards compatible
- **Patch (0.0.X):** Bug fixes

### Release Checklist

1. Update version in `.claude-plugin/marketplace.json`
2. Update CHANGELOG.md with new version section
3. Update README.md if needed
4. Run full test suite
5. Create git tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
6. Push tag: `git push origin v1.0.0`
7. Create GitHub release with notes
8. Update plugin marketplace listing

## 🤝 Code Review

**Reviewers will check:**
- Code quality and style
- Test coverage
- Documentation updates
- Security considerations
- Performance impact
- Backwards compatibility

**Response time:**
- Bug fixes: 1-2 days
- Features: 3-5 days
- Major changes: 1-2 weeks

**Approval criteria:**
- At least one approving review
- All tests passing
- No merge conflicts
- Documentation complete

## 💬 Communication

**Channels:**
- GitHub Issues: Bug reports, feature requests
- GitHub Discussions: Questions, ideas
- Pull Requests: Code contributions

**Response expectations:**
- Issues: Within 48 hours
- PRs: Initial review within 5 days
- Security issues: Within 24 hours

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be:
- Listed in CHANGELOG.md for their contributions
- Mentioned in release notes
- Added to a CONTRIBUTORS.md file (if significant contributions)

## ❓ Questions?

- Check existing issues and discussions
- Ask in GitHub Discussions
- Tag maintainers in related issues

---

**Thank you for contributing! 🎉**

Every contribution, no matter how small, makes this project better for everyone.
