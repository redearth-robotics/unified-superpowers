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

## Implementation Notes

This skill should be invoked **automatically at the start of any task** (via triggers: [model]) to ensure frameworks are applied consistently without manual invocation.

The skill should:
1. Analyze the incoming task context
2. Select appropriate frameworks using the detection logic
3. Announce which frameworks are active
4. Invoke those framework skills in priority order
5. Handle user overrides gracefully
6. Adapt based on user preferences over time