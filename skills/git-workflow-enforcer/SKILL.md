---
name: git-workflow-enforcer
description: Ensures Claude Code NEVER works directly on main or master branches. Automatically creates feature branches with descriptive names based on task context. Activates at the start of any implementation work to enforce safe git workflow practices.
---

# Git Workflow Enforcer

## Purpose

Prevent direct work on main/master branches by automatically creating feature branches before any implementation begins.

**Core principle:** All development work happens on feature branches. Main/master are sacred.

## When to Activate

**Automatically activate when:**
- Starting any implementation task
- About to make code changes
- User requests a new feature or bug fix
- Before running any git commit commands

**Do NOT activate for:**
- Read-only operations (code review, analysis)
- Already on a feature branch
- User explicitly working with git directly

## Workflow

### Step 1: Check Current Branch

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

### Step 2: Detect Main/Master

If on main or master:

```bash
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  # Need to create feature branch
fi
```

### Step 3: Generate Branch Name

Create descriptive branch name from task context:

**Naming convention:**
- `feature/[description]` - for new features
- `fix/[description]` - for bug fixes
- `refactor/[description]` - for refactoring
- `docs/[description]` - for documentation

**Branch name rules:**
- Lowercase only
- Words separated by hyphens
- Max 50 characters
- No special characters except hyphens

```bash
# Extract task type and description
TASK_TYPE="feature"  # or fix, refactor, docs based on context

# Sanitize description
DESCRIPTION=$(echo "$TASK_DESCRIPTION" |
  tr '[:upper:]' '[:lower:]' |
  tr -s ' ' '-' |
  tr -cd '[:alnum:]-' |
  head -c 50)

BRANCH_NAME="${TASK_TYPE}/${DESCRIPTION}"
```

### Step 4: Create and Switch Branch

```bash
git checkout -b "$BRANCH_NAME"
echo "✅ Created and switched to branch: $BRANCH_NAME"
```

### Step 5: Return Branch Info

Provide branch name for next steps in workflow:

```
Current branch: [branch-name]
Status: Ready for development
```

## Safety Mechanisms

### Hard Stop on Main/Master

**NEVER proceed with changes on main/master.** Always force branch creation first.

```bash
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  echo "❌ BLOCKED: Cannot work on $CURRENT_BRANCH directly"
  echo "Creating feature branch..."
  # Force branch creation
fi
```

### Handle Existing Feature Branches

If already on a feature branch, confirm and continue:

```bash
else
  echo "✅ Already on feature branch: $CURRENT_BRANCH"
  echo "Safe to proceed with development"
fi
```

## Examples

### Example 1: Starting Feature Work on Main

```
User: "Add rate limiting to the API"

Current branch: main

Action:
1. Detect on main branch
2. Parse task: "Add rate limiting to the API"
3. Create branch: feature/add-rate-limiting-to-api
4. Switch to new branch
5. Confirm ready for development

Output:
❌ Currently on main branch - creating feature branch
✅ Created and switched to: feature/add-rate-limiting-to-api
✅ Ready for development
```

### Example 2: Bug Fix on Master

```
User: "Fix authentication timeout issue"

Current branch: master

Action:
1. Detect on master branch
2. Parse task type: "Fix" → use fix/ prefix
3. Create branch: fix/authentication-timeout-issue
4. Switch to new branch
5. Confirm ready for development

Output:
❌ Currently on master branch - creating feature branch
✅ Created and switched to: fix/authentication-timeout-issue
✅ Ready for development
```

### Example 3: Already on Feature Branch

```
User: "Continue working on the dashboard"

Current branch: feature/dashboard-improvements

Action:
1. Detect on feature branch
2. Confirm safe to continue
3. No branch creation needed

Output:
✅ Already on feature branch: feature/dashboard-improvements
✅ Safe to proceed with development
```

## Integration with Other Skills

This skill should run BEFORE:
- Any code changes
- `pr-creator` skill
- `thoughtful-pr-workflow` orchestrator

This skill outputs:
- Current branch name
- Safety status (ready/blocked)

## Error Handling

### Uncommitted Changes on Main

If on main/master with uncommitted changes:

```bash
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "⚠️  WARNING: Uncommitted changes detected on $CURRENT_BRANCH"
  echo "These changes will move to the new feature branch"
  # Continue with branch creation - changes will carry over
fi
```

### Branch Name Conflicts

If proposed branch name already exists:

```bash
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  # Append timestamp to make unique
  BRANCH_NAME="${BRANCH_NAME}-$(date +%s)"
  echo "Branch exists, using: $BRANCH_NAME"
fi
```

## Success Criteria

✅ Never allows work to proceed on main/master
✅ Creates descriptive, well-formatted branch names
✅ Handles edge cases (uncommitted changes, name conflicts)
✅ Provides clear status output
✅ Integrates seamlessly with PR workflow

## Technical Notes

**Requirements:**
- Git 2.23+ (for `git branch --show-current`)
- Bash or compatible shell
- Git repository with main or master branch

**No external dependencies** - uses only git and standard shell commands.
