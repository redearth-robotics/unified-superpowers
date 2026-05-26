---
name: requesting-code-review
description: Use when finishing implementation tasks or major features, before merge - ensures code meets requirements and catches issues early
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Use Task tool with `general-purpose` type, fill template at `code-reviewer.md`

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

| Symptom | Why It's Wrong | What To Do Instead |
|---------|----------------|-------------------|
| Skipping review because "it's simple" | Simple changes break things too | Always request review before proceeding |
| Ignoring Critical issues | Bugs reach production | Fix Critical issues immediately |
| Proceeding with unfixed Important issues | Technical debt accumulates | Fix Important issues before next task |
| Arguing with valid feedback without evidence | Missed learning, bad code persists | Consider feedback carefully; push back only with tests/code proof |
| Reviewing own session history | Reviewer distracted by process, not product | Provide precisely crafted context, not session history |
| Review only at the end | Issues compound across tasks | Review after each task in subagent-driven development |
| No git SHAs provided | Reviewer cannot see actual diff | Always provide BASE_SHA and HEAD_SHA |
| Vague description of changes | Reviewer doesn't understand scope | Write clear summary of what was built and why |

See template at: requesting-code-review/code-reviewer.md
