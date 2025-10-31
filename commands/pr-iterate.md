---
description: Iterate on ClaudeBot PR feedback automatically until all issues are resolved
---

Invoke the `github-push-pr:claudebot-feedback-loop` skill to automatically apply ClaudeBot review feedback on your current PR.

The skill will:
- Poll for new ClaudeBot comments on the PR
- Categorize feedback (blocking vs suggestions)
- Apply fixes automatically
- Commit and push changes
- Repeat until no more blocking issues

**Safety features:**
- Maximum 5 iterations (prevents infinite loops)
- Smart polling with exponential backoff
- Detects and prevents infinite feedback loops
