# Changelog

All notable changes to the GitHub Push PR plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-30

### Added

#### Core Skills
- **git-workflow-enforcer** - Automatic feature branch enforcement
  - Detects main/master branches and creates feature branches
  - Smart branch naming from task context
  - Handles uncommitted changes safely
  - Branch conflict resolution

- **pr-creator** - Automated PR creation with security
  - Comprehensive security checks (20+ secret patterns)
  - Environment file blocking (.env detection)
  - Auto-generated PR titles and descriptions
  - Integration with GitHub CLI
  - PR number tracking for feedback loop

- **claudebot-feedback-loop** - Feedback iteration automation
  - Smart polling for ClaudeBot comments
  - Feedback categorization (blocking vs suggestions)
  - Automatic fix application
  - Infinite loop detection
  - Max iteration limits (default: 3)
  - Feedback history tracking

- **thoughtful-pr-workflow** - End-to-end orchestrator
  - Complete workflow automation
  - Optional requirements clarification integration
  - Optional implementation planning integration
  - Todo list progress tracking
  - Comprehensive completion reports

#### Security Features
- Secret pattern detection for:
  - OpenAI API keys
  - GitHub tokens (all types)
  - AWS credentials
  - Google API keys
  - Stripe keys
  - Slack tokens
  - Database URLs with passwords
  - And 10+ more patterns
- .gitignore validation and auto-update
- Hardcoded credential detection
- Placeholder/example value allowance

#### Testing
- Git workflow enforcer test suite
- Security checks test suite
- Test runner with comprehensive reporting
- Isolated test environments

#### Documentation
- Comprehensive README with examples
- Individual skill documentation
- Architecture overview
- Security documentation
- Contributing guidelines
- MIT License

### Technical Details

**Requirements:**
- Git 2.23+
- GitHub CLI (gh)
- jq for JSON processing
- Bash or compatible shell

**Integration:**
- Works standalone
- Optional integration with thoughtful-dev plugin
- Claude Code skill format compliant

**Repository Structure:**
```
.claude-plugin/marketplace.json
skills/
  git-workflow-enforcer/SKILL.md
  pr-creator/SKILL.md
  claudebot-feedback-loop/SKILL.md
  thoughtful-pr-workflow/SKILL.md
scripts/
  check-secrets.sh
tests/
  test-git-workflow-enforcer.sh
  test-security-checks.sh
  run-all-tests.sh
```

### Known Limitations

- ClaudeBot must be configured on repository for feedback loop
- GitHub CLI must be authenticated
- Requires repository with GitHub remote
- Feedback loop assumes standard GitHub PR comment format

## [Unreleased]

### Added
- **INTEGRATION.md** - Comprehensive guide for using plugin with official Claude GitHub Action
- GitHub App installation instructions in README
- Enhanced claudebot-feedback-loop documentation with GitHub App integration details
- Clarification on complementary relationship with official GitHub Action

### Changed
- Updated README with optional GitHub App installation section
- Improved feedback loop skill documentation to highlight official ClaudeBot benefits
- Added comparison table showing features with/without GitHub App

### Documentation
- 537-line integration guide covering:
  - Solo developer workflow (plugin only)
  - Hybrid workflow (plugin + GitHub Action)
  - Team collaboration patterns
  - CI/CD automation examples
  - Troubleshooting common integration issues

### Planned Features
- GitLab support
- Bitbucket support
- Custom PR templates
- Configurable secret patterns
- More feedback categorization options
- Slack/Discord notifications on PR creation
- Integration tests with real GitHub API
- Performance metrics tracking

---

## Version History

### Versioning Scheme

- **Major (X.0.0):** Breaking changes, major features
- **Minor (0.X.0):** New features, backwards compatible
- **Patch (0.0.X):** Bug fixes, minor improvements

### Release Notes Format

Each version includes:
- **Added:** New features
- **Changed:** Changes to existing functionality
- **Deprecated:** Soon-to-be removed features
- **Removed:** Removed features
- **Fixed:** Bug fixes
- **Security:** Security improvements

---

[1.0.0]: https://github.com/Neno73/github-push-pr/releases/tag/v1.0.0
