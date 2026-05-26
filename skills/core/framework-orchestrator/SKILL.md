---
name: framework-orchestrator
description: Use when starting any task to automatically select and compose behavioral frameworks (systematic-debugging, brainstorming, test-driven-development, verification-before-completion, writing-plans) based on task context
triggers:
  - model
  - user
---

# Framework Orchestrator

Automatically select and compose behavioral frameworks based on task context to improve agent decision quality without forcing rigid workflows.

## What This Does

Analyzes the incoming task and activates relevant behavioral frameworks in the correct order. Frameworks guide agent behavior at key decision points but remain advisory - the agent can skip steps when context clearly indicates they're unnecessary.

## Manual Invocation

Users can also invoke this skill directly with `/framework-orchestrator` to force framework analysis for a specific task, or to see which frameworks would be selected for the current context.

## Framework Detection Signals

| Signal | Detected By | Framework Applied |
|--------|-------------|-----------------|
| Error message, stack trace, test failure | Stack trace patterns, error keywords | `systematic-debugging` |
| "Build", "implement", "create", "add feature" | Task type classification | `brainstorming` → `writing-plans` |
| "Fix bug", "repair", "broken" | Context analysis | `systematic-debugging` → `verification-before-completion` |
| Code change request + test files exist | File pattern detection | `test-driven-development` |
| Complex multi-step task | Complexity heuristic (>3 files, >2 domains, or explicit multi-step language) | `writing-plans` checkpoint |
| Any task with clear completion criteria | Always active | `verification-before-completion` |

## Detection Implementation Guide

### Error Signal Detection (`contains_error_signals`)
**Patterns to check:**
- Stack traces in user input (lines with `at `, `Traceback`, `Error:`, `Exception:`)
- Error keywords: `failing`, `broken`, `crash`, `bug`, `doesn't work`, `not working`
- Test failure indicators: `FAIL`, `failed`, `AssertionError`, `expected but got`

### Implementation Task Detection (`is_implementation_task`)
**Keywords:** `build`, `implement`, `create`, `add`, `develop`, `write`, `make`, `design`
**Negative signals:** `explain`, `how do I`, `what is`, `review` (these are information-seeking)

### Trivial Task Detection (`is_trivial`)
**Criteria (ALL must be true):**
- Expected change: < 3 lines
- No new functions/classes
- No logic/algorithm changes
- Only variable renames, string updates, or comment changes

### Complexity Detection (`is_complex`)
**Thresholds (ANY triggers complexity):**
- Task mentions > 3 distinct files
- Task spans > 2 domains (e.g., frontend + backend + database)
- Explicit multi-step language: "first... then...", "step 1...", "after that..."

### Code Change Detection (`modifies_code`)
**Patterns:**
- User references specific files to edit
- User asks to "change", "update", "modify", "refactor" code
- User provides code snippets to alter

### Test Infrastructure Detection (`has_test_suite`)
**Check for:**
- Files: `test_*.py`, `*.test.js`, `*.spec.ts`, `*_test.go`
- Configs: `pytest.ini`, `jest.config.js`, `vitest.config.ts`, `Cargo.toml` (has [test] section)
- Directories: `tests/`, `__tests__/`, `spec/`

## Framework Priority Order

When multiple frameworks apply, compose them in this order:

1. `systematic-debugging` (errors block everything)
2. `brainstorming` (planning comes before execution)
3. `writing-plans` (complex tasks need decomposition)
4. `test-driven-development` (execution guidance)
5. `verification-before-completion` (final gate)

## Framework Selection Logic

```python
def select_frameworks(task):
    frameworks = []
    
    # Base framework: always verify if possible
    # has_verification_capability = (has_linter or has_typechecker or has_tests or has_build_command)
    if has_verification_capability():
        frameworks.append("verification-before-completion")
    
    # Error-oriented tasks
    if contains_error_signals(task):
        frameworks.append("systematic-debugging")
    
    # Creative/build tasks
    if is_implementation_task(task) and not is_trivial(task):
        frameworks.append("brainstorming")
        if is_complex(task):
            frameworks.append("writing-plans")
    
    # Code changes with test infrastructure
    # has_test_suite = (test files exist OR test framework config exists)
    if modifies_code(task) and has_test_suite():
        frameworks.append("test-driven-development")
    
    return frameworks
```

## When Frameworks Should NOT Apply

- **Trivial tasks** (definition: < 3 lines changed, no logic/algorithm changes, no new functions, only variable/string updates): Skip `brainstorming` and `writing-plans`
- **No test infrastructure** (no test files detected, no test framework config like pytest.ini, jest.config.js, etc.): Skip `test-driven-development`, still apply others
- **User override**: User can say "just fix it" to skip `systematic-debugging` formalism
- **Emergency mode**: `/bypass` mode disables all frameworks for speed

## Framework Composition Examples

**Bug fix with tests:**
```
systematic-debugging → test-driven-development → verification-before-completion
```

**New feature implementation:**
```
brainstorming → writing-plans → test-driven-development → verification-before-completion
```

**Simple variable update:**
```
verification-before-completion (only)
```

**Complex multi-feature:**
```
brainstorming → writing-plans → systematic-debugging (if errors) → test-driven-development → verification-before-completion
```

## User Experience

**Transparency**: Explicitly state which frameworks are active:
> "Using systematic-debugging framework: I'll reproduce this error first before proposing a fix."

**Control**: User can override at any point:
> "This is taking too long, just fix it" → Agent skips remaining debugging steps

**Progress Indicators**: For long-running framework steps:
> "[Step 2/4] Running tests to verify fix..."

**Learning**: Agent remembers user preferences per project:
> "You usually skip brainstorming for CSS changes. I'll apply that here."

## Integration with Existing Skills

This orchestrator **invokes** existing framework skills rather than reimplementing them:

- `systematic-debugging` - For error scenarios
- `brainstorming` - For creative tasks with unclear requirements
- `test-driven-development` - For code changes with test infrastructure
- `verification-before-completion` - For final verification gates
- `writing-plans` - For complex multi-step tasks

**Important**: Do not duplicate these existing skills. This orchestrator is about **selection and composition**, not implementation.

## Red Flags

| Symptom | Why It's Wrong | What To Do Instead |
|---------|----------------|-------------------|
| Applying frameworks to trivial tasks | Unnecessary overhead, slows down simple work | Skip brainstorming/writing-plans for <3 line changes |
| Ignoring user override signals | Frustrates users who want speed | Respect "just fix it" and similar override phrases |
| Applying test-driven-development without test infrastructure | Fails immediately, wastes time | Check for test files/config before requiring TDD |
| Forcing frameworks in bypass mode | User explicitly chose speed over structure | Disable all frameworks in `/bypass` mode |
| Not stating which frameworks are active | User doesn't understand agent behavior | Always announce active frameworks at start |
| Applying frameworks in wrong priority order | systematic-debugging should precede brainstorming | Follow priority order: errors → planning → execution → verification |
| Skipping verification-before-completion | Risky to claim success without checks | Always apply verification as base framework |
| Reimplementing framework logic | Violates DRY, creates maintenance burden | Invoke existing skills using `skill` tool, never duplicate |
| Not respecting consistent user overrides | Wastes time repeatedly | Log preferences and auto-skip frameworks user consistently overrides |

## Framework Invocation Mechanism

### How Frameworks Are Activated

The orchestrator does NOT reimplement framework logic. It **invokes existing skills** using the Skill tool:

```
1. Select frameworks using detection logic
2. For each selected framework in priority order:
   a. Announce: "Activating [framework-name] framework..."
   b. Invoke skill with `skill` tool: name=[framework-name]
   c. Skill injects its instructions into the conversation
   d. Continue to next framework
3. After all frameworks activated, proceed with task execution
```

### Execution Model

**Sequential by default**: Frameworks run one after another, not in parallel.
- `brainstorming` completes before `writing-plans` starts
- Each framework's instructions are added to the context window
- Framework effects persist through the task (they modify agent behavior)

**Exception**: `verification-before-completion` is not "active" during execution - it's a checkpoint at the END of the task.

## User Override Handling

### Explicit Override Phrases

When the user says any of these, skip ALL non-essential frameworks:
- "just fix it"
- "skip debugging"
- "no planning needed"
- "do it quickly"
- "I don't need a plan"
- "skip the formalities"
- "fast mode"

### Contextual Override Detection

Also detect override intent from:
- Urgency signals: "quickly", "ASAP", "now", "hurry"
- Frustration signals: "this is taking too long", "why are you asking so many questions"
- Explicit permission: "you have permission to...", "just go ahead and..."

### Override Behavior

When override detected:
1. Announce: "User override detected. Skipping [framework names] to proceed directly."
2. Only apply: `systematic-debugging` (if errors present) and `verification-before-completion`
3. All other frameworks skipped for this task
4. Log override preference for future tasks (if user consistently overrides for similar tasks)

## Implementation Notes

This skill should be invoked **automatically at the start of any task** (via triggers: [model]) to ensure frameworks are applied consistently without manual invocation.

The skill should:
1. Analyze the incoming task context using the Detection Implementation Guide
2. Select appropriate frameworks using the selection logic
3. Announce which frameworks are active
4. Invoke those framework skills using the Skill tool in priority order
5. Handle user overrides gracefully using the override detection patterns
6. Adapt based on user preferences over time