---
description: Run complete end-to-end PR workflow - from feature branch to clean PR with feedback iteration
---

Invoke the `github-push-pr:thoughtful-pr-workflow` skill to orchestrate the complete development workflow:

1. Enforce git safety (create feature branch if needed)
2. Optionally plan implementation (for non-trivial work)
3. Execute your implementation
4. Create PR with security checks
5. Iterate on ClaudeBot feedback until clean

**Usage:** Describe what you want to implement, and this command will handle the entire workflow automatically.
