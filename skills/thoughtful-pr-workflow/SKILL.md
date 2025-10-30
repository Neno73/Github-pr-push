---
name: thoughtful-pr-workflow
description: End-to-end orchestrator for complete GitHub PR workflow. Enforces git safety, optionally plans implementation, executes work, creates PR with security checks, and iterates on ClaudeBot feedback until clean. Integrates all workflow skills into a cohesive process. Activates when user requests feature implementation with full PR automation.
---

# Thoughtful PR Workflow

## Purpose

Orchestrate the complete development-to-PR workflow, ensuring git safety, code quality, security, and automated feedback iteration.

**Core principle:** From task description to clean PR, all automated with safety guardrails.

## When to Activate

**Automatically activate when:**
- User requests feature implementation: "implement X", "add Y", "build Z"
- User wants full automation: "implement X and create PR"
- Starting a significant development task
- User says "full workflow" or "auto PR"

**Do NOT activate for:**
- Simple code reviews or analysis
- Tasks already in progress (partial workflow)
- User prefers manual git workflow
- Trivial changes that don't need full ceremony

## Workflow Overview

```
User Request
    ↓
1. Parse Intent & Requirements
    ↓
2. Enforce Git Workflow (create feature branch)
    ↓
3. Optional: Plan Implementation (if non-trivial)
    ↓
4. Execute Implementation (write code, tests)
    ↓
5. Create Pull Request (with security checks)
    ↓
6. Iterate on ClaudeBot Feedback (until clean)
    ↓
7. Report Completion (PR URL, stats)
```

## Detailed Steps

### Step 1: Parse User Intent

Extract task information from user request:

```
Task description: [what to build]
Task type: [feature, fix, refactor, docs]
Complexity: [trivial, moderate, complex]
Planning needed: [yes/no based on complexity]
```

**Complexity assessment:**
- **Trivial:** Single file, <20 lines, obvious approach
- **Moderate:** Multiple files, standard patterns, some decisions
- **Complex:** Architecture changes, multiple approaches possible, significant scope

**Examples:**
- "Fix typo in README" → Trivial, no planning
- "Add input validation to form" → Moderate, maybe quick plan
- "Implement user authentication system" → Complex, definitely plan

### Step 2: Enforce Git Workflow

Invoke `git-workflow-enforcer` skill:

```
✅ Invoking git-workflow-enforcer...
```

**This ensures:**
- Never working on main/master
- Feature branch created with proper naming
- Safe to proceed with changes

**Output:**
```
Current branch: feature/[description]
Status: Ready for development
```

**Update todo list:**
```
✅ Enforce git workflow (completed)
```

### Step 3: Optional Planning Phase

If task is non-trivial or requirements are ambiguous:

**A. Requirements Clarification (if needed)**

If the request is ambiguous or missing key details:

```
✅ Invoking thoughtful-dev:requirements-clarifier...
```

This will:
- Restate understanding
- Ask clarifying questions
- Surface assumptions
- Get explicit agreement

**Only proceed after user confirms understanding.**

**B. Implementation Planning (for non-trivial tasks)**

For moderate to complex tasks:

```
✅ Invoking thoughtful-dev:implementation-planner...
```

This will:
- Analyze current codebase
- Propose approach(es) with trade-offs
- Break down work into steps
- Identify risks
- Get user approval on approach

**Skip planning if:**
- Trivial task
- User explicitly says "just do it"
- Continuing previously planned work

**Update todo list:**
```
✅ Clarify requirements (completed, if run)
✅ Plan implementation (completed, if run)
```

### Step 4: Execute Implementation

Perform the actual development work:

```
🤖 Implementing changes...
```

**This includes:**
- Writing/modifying code files
- Adding/updating tests (if applicable)
- Running tests to verify changes
- Fixing any issues that arise
- Committing changes incrementally

**Todo list during implementation:**
```
🔄 Implement [specific component] (in_progress)
⏳ Write tests (pending)
⏳ Verify functionality (pending)
```

**Commit strategy:**
- Make logical, atomic commits
- Write descriptive commit messages
- Can have multiple commits (will be included in PR)
- Follow git best practices

**Update todo list as work progresses:**
```
✅ Implement [component] (completed)
✅ Write tests (completed)
✅ Verify functionality (completed)
```

### Step 5: Create Pull Request

Invoke `pr-creator` skill:

```
✅ Invoking pr-creator...
```

**This will:**
1. Run security checks (prevent secret leaks)
2. Generate PR title and body from commits
3. Push branch to remote
4. Create GitHub PR
5. Save PR number for feedback loop

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Pull Request Created Successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PR #42
🔗 https://github.com/user/repo/pull/42
📝 Title: [PR title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If security check fails:**
- Workflow stops
- Display what was found
- User must fix before continuing

**Update todo list:**
```
✅ Create PR (completed)
```

### Step 6: Iterate on ClaudeBot Feedback

Invoke `claudebot-feedback-loop` skill:

```
✅ Invoking claudebot-feedback-loop...
```

**This will:**
1. Wait for ClaudeBot comments (smart polling)
2. Fetch and categorize feedback
3. Apply fixes
4. Commit and push
5. Repeat until PR is clean or max iterations

**Update todo list during iteration:**
```
🔄 Wait for ClaudeBot feedback (iteration 1) (in_progress)
⏳ Apply feedback (iteration 2) (pending)
⏳ Apply feedback (iteration 3) (pending)
```

**Possible outcomes:**

**A. Success - PR is clean:**
```
✅ No new comments
✅ PR is clean and ready for approval!
```

**B. Max iterations reached:**
```
⏰ Maximum iterations (3) reached
Some issues may remain - manual review recommended
```

**C. Infinite loop detected:**
```
⚠️  Repeated issues detected
Manual intervention required
```

**D. No ClaudeBot comments (timeout):**
```
✅ No feedback after 5 minutes
PR appears clean or ClaudeBot pending review
```

### Step 7: Report Completion

Provide comprehensive summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Workflow Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Task: [original user request]
🌿 Branch: feature/[description]
📦 Commits: 3 commits
🔗 PR: https://github.com/user/repo/pull/42

📊 Feedback Iteration Stats:
- Iterations: 2
- Comments addressed: 5
- Status: ✅ PR clean and ready

🎯 Next Steps:
- PR is ready for team review
- Automated checks should pass shortly
- Merge when approved

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Todo List Integration

This skill maintains a detailed todo list throughout the workflow:

### Initial Planning Phase

```
TodoWrite({
  todos: [
    { content: "Enforce git workflow", status: "pending", activeForm: "Enforcing git workflow" },
    { content: "Clarify requirements (if needed)", status: "pending", activeForm: "Clarifying requirements" },
    { content: "Plan implementation (if needed)", status: "pending", activeForm: "Planning implementation" },
    { content: "Implement changes", status: "pending", activeForm: "Implementing changes" },
    { content: "Create PR", status: "pending", activeForm: "Creating PR" },
    { content: "Apply ClaudeBot feedback", status: "pending", activeForm: "Applying feedback" }
  ]
})
```

### During Implementation

Break down "Implement changes" into specifics:

```
TodoWrite({
  todos: [
    { content: "Enforce git workflow", status: "completed" },
    { content: "Create component structure", status: "in_progress", activeForm: "Creating component structure" },
    { content: "Implement business logic", status: "pending", activeForm: "Implementing business logic" },
    { content: "Add tests", status: "pending", activeForm: "Adding tests" },
    { content: "Create PR", status: "pending", activeForm: "Creating PR" },
    ...
  ]
})
```

### During Feedback Iteration

Add iteration-specific tasks:

```
TodoWrite({
  todos: [
    ...(previous completed tasks),
    { content: "Create PR", status: "completed" },
    { content: "Wait for feedback (iteration 1)", status: "completed" },
    { content: "Apply fixes (iteration 1)", status: "completed" },
    { content: "Wait for feedback (iteration 2)", status: "in_progress", activeForm: "Waiting for ClaudeBot feedback" },
    { content: "Apply fixes (iteration 2)", status: "pending", activeForm: "Applying fixes" }
  ]
})
```

## Decision Logic

### When to Skip Planning

Skip requirements clarification if:
- Request is crystal clear
- Standard, well-known pattern
- User has provided detailed spec
- Continuing already-clarified work

Skip implementation planning if:
- Trivial change (<20 lines, single file)
- Obvious implementation approach
- User explicitly requests "just do it"
- Emergency hotfix

### When to Skip Feedback Loop

Skip claudebot-feedback-loop if:
- ClaudeBot not configured on repository
- User requests manual review only
- PR is marked as draft/WIP
- User explicitly opts out

### Error Recovery

**If git-workflow-enforcer fails:**
- Stop workflow
- Report issue to user
- Don't proceed with changes

**If pr-creator security check fails:**
- Stop workflow
- Display security violations
- User must fix before retrying

**If feedback loop gets stuck:**
- After max iterations: stop and report
- After infinite loop detection: stop and report
- User can manually continue or fix

## Integration Points

### Depends On

**Required skills:**
- `git-workflow-enforcer` - Must run first
- `pr-creator` - Creates the PR

**Optional skills:**
- `thoughtful-dev:requirements-clarifier` - If requirements unclear
- `thoughtful-dev:implementation-planner` - If task is non-trivial
- `claudebot-feedback-loop` - If automated iteration desired

### Provides

**Outputs:**
- Clean feature branch with changes
- GitHub PR with all commits
- Feedback history (if iterations ran)
- Comprehensive completion report

**Side effects:**
- Feature branch created and pushed
- PR created on GitHub
- Multiple commits (from implementation and feedback fixes)
- Files in `.claude/feedback/` directory

## Examples

### Example 1: Simple Feature (No Planning)

```
User: "Add a loading spinner to the submit button"

Workflow:
1. ✅ Task parsed: Simple UI addition (trivial)
2. ✅ Git workflow: Created feature/add-loading-spinner
3. ⏭️  Planning skipped (trivial task)
4. 🤖 Implementation:
   - Modified Button component
   - Added loading prop
   - Updated styling
   - Committed changes
5. ✅ PR created: #42
6. 🔄 ClaudeBot feedback:
   - Iteration 1: 1 comment (add accessibility label)
   - Iteration 2: No comments
7. ✅ Complete!

Time: 3 minutes
PR: https://github.com/user/repo/pull/42
Status: Ready for review
```

### Example 2: Complex Feature (With Planning)

```
User: "Implement rate limiting for our API endpoints"

Workflow:
1. ✅ Task parsed: Complex feature (requires planning)
2. ✅ Git workflow: Created feature/implement-rate-limiting
3. ✅ Requirements clarified:
   - Which endpoints? (All authenticated endpoints)
   - Rate limit? (100 requests per minute per user)
   - Response? (429 status with retry-after header)
4. ✅ Implementation planned:
   - Approach: Middleware with Redis backend
   - Files: middleware/rateLimit.ts, tests/, config
   - Risks: Redis dependency, configuration
5. 🤖 Implementation:
   - Created rate limit middleware
   - Added Redis client setup
   - Configured per-endpoint limits
   - Added tests
   - Updated API documentation
   - 6 commits total
6. ✅ PR created: #43
7. 🔄 ClaudeBot feedback:
   - Iteration 1: 4 comments (error handling, tests, docs)
   - Iteration 2: 2 comments (edge cases)
   - Iteration 3: No comments
8. ✅ Complete!

Time: 25 minutes
Commits: 6 (implementation) + 2 (feedback fixes) = 8
PR: https://github.com/user/repo/pull/43
Status: Ready for review
```

### Example 3: Security Check Blocks PR

```
User: "Add API key configuration"

Workflow:
1. ✅ Git workflow: Created feature/add-api-key-config
2. ⏭️  Planning skipped
3. 🤖 Implementation:
   - Added config file with API key
   - Committed changes (accidentally included .env)
4. ❌ PR creation BLOCKED:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Security Check Failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BLOCKED: Environment file in commit
  .env

Please remove these files and use .env.example instead

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Workflow stopped - fix security issues first
```

User fixes issue, then:

```
User: "Try again"

4. 🤖 Fixed .env issue:
   - Removed .env from commit
   - Created .env.example
   - Updated .gitignore
5. ✅ PR created: #44
6. 🔄 ClaudeBot: No comments
7. ✅ Complete!
```

## Success Criteria

✅ Complete end-to-end automation
✅ Safety enforced at every step (git, security)
✅ Appropriate planning for task complexity
✅ Clean PR with good description
✅ Feedback automatically applied
✅ Clear status reporting throughout
✅ Handles errors gracefully

## Technical Notes

**Requirements:**
- All component skills available (git-workflow-enforcer, pr-creator, claudebot-feedback-loop)
- Optional: thoughtful-dev skills (requirements-clarifier, implementation-planner)
- Git repository with GitHub remote
- GitHub CLI authenticated
- Bash/shell environment

**Characteristics:**
- Idempotent where possible
- Clear status at each step
- Graceful degradation (can skip optional steps)
- Comprehensive error handling
- User always in control (can interrupt)

**Performance:**
- Simple tasks: 2-5 minutes
- Complex tasks: 15-30 minutes
- Depends on ClaudeBot response time
- Most time in implementation and feedback waiting

## Customization

Adjust behavior via parameters:

```
# Skip planning phase
thoughtful-pr-workflow --no-planning

# Skip feedback iteration
thoughtful-pr-workflow --no-feedback

# Custom max iterations
thoughtful-pr-workflow --max-iterations 5

# Specify base branch
thoughtful-pr-workflow --base main
```

(Implementation of parameters depends on how skills receive configuration)
