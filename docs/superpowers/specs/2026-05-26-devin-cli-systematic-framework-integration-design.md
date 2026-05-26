# Devin CLI Systematic Framework Integration Design

**Date**: 2026-05-26  
**Type**: Core Agent Behavior Enhancement  
**Approach**: Systematic Framework Integration

**Scope Note**: This is a large architectural change affecting core agent behavior. Consider decomposing into smaller implementation phases: (1) Framework router + verification-before-completion, (2) systematic-debugging integration, (3) brainstorming + writing-plans, (4) test-driven-development integration.

## Problem Statement

The Devin CLI improvement checklist identifies key areas for agent improvement: narrow skills, verification gates, better prompts, and helper tooling. The current agent lacks structured behavioral frameworks that guide decision-making, leading to inconsistent quality and avoidable errors.

## Solution Overview

Embed proven methodologies from obra/superpowers as **behavioral frameworks** that guide the agent's decision-making without forcing rigid workflows. These frameworks act as an "expert mode" layer between user input and agent action.

## Architecture

### Core Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Input Layer                          │
│  (task description, prompt, file context)                   │
└────────────────────┬──────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Behavioral Framework Router                    │
│  Analyzes task type → selects appropriate frameworks        │
└────────────────────┬──────────────────────────────────────────┘
                     │
         ┌──────────┼──────────┬──────────┐
         ▼          ▼          ▼          ▼
    ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
    │Brain-  │ │System- │ │Test-   │ │Verify- │
    │storming│ │atic    │ │Driven  │ │Before  │
    │Gate    │ │Debug   │ │Dev     │ │Complete│
    └────────┘ └────────┘ └────────┘ └────────┘
         │          │          │          │
         └──────────┴──────────┴──────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Agent Action Execution                         │
│  (reads, writes, shell commands, reasoning)                 │
└─────────────────────────────────────────────────────────────┘
```

### Key Principle

Frameworks are **advisory, not mandatory**. The agent uses them to improve decision quality, but can skip steps when context clearly indicates they're unnecessary (e.g., a one-line bugfix doesn't need brainstorming).

## Framework Detection & Routing

### Detection Signals

| Signal | Detected By | Framework Applied |
|--------|-------------|-----------------|
| Error message, stack trace, test failure | Stack trace patterns, error keywords | `systematic-debugging` |
| "Build", "implement", "create", "add feature" | Task type classification | `brainstorming` → `writing-plans` |
| "Fix bug", "repair", "broken" | Context analysis | `systematic-debugging` → `verification-before-completion` |
| Code change request + test files exist | File pattern detection | `test-driven-development` |
| Complex multi-step task | Complexity heuristic (>3 files, >2 domains, or explicit multi-step language) | `writing-plans` checkpoint |
| Any task with clear completion criteria | Always active | `verification-before-completion` |

### Routing Logic

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

### Framework Composition

Frameworks can be **layered** - a bug fix might use `systematic-debugging` + `test-driven-development` + `verification-before-completion` simultaneously.

## Framework Integration in Agent Loop

Each framework modifies specific **decision points** in the agent's action loop without replacing the core reasoning engine.

### Agent Decision Loop with Frameworks

```
┌─────────────────┐
│ 1. Understand   │ ← Framework: context gathering enhancement
│    Context      │   (brainstorming: check files, commits, docs)
└────────┬────────┘
         │
┌────────▼────────┐
│ 2. Plan Action  │ ← Framework: plan validation
│                 │   (writing-plans: decompose complex tasks)
└────────┬────────┘
         │
┌────────▼────────┐
│ 3. Execute      │ ← Framework: execution guidance
│                 │   (test-driven-development: write test first)
└────────┬────────┘
         │
┌────────▼────────┐
│ 4. Verify       │ ← Framework: verification gates
│                 │   (verification-before-completion: must pass)
└────────┬────────┘
         │
┌────────▼────────┐
│ 5. Handle Errors│ ← Framework: structured debugging
│                 │   (systematic-debugging: reproduce → isolate → fix)
└─────────────────┘
```

### Detailed Framework Behaviors

#### systematic-debugging
- **Trigger**: Error encountered, test failure, unexpected behavior
- **Action**: Forces structured investigation before proposing fixes
- **Steps**: Reproduce → Trace code path → Add logging → Identify root cause → Fix → Verify
- **Stop condition**: Root cause identified and fix verified, OR user explicitly overrides

#### brainstorming
- **Trigger**: Implementation task with unclear requirements
- **Action**: Adds exploration phase before coding
- **Steps**: Explore context → Ask clarifying questions → Propose approaches → Get approval
- **Stop condition**: User approves design, OR task is trivial enough to skip

#### test-driven-development
- **Trigger**: Code modification in project with test infrastructure
- **Action**: Requires test-first approach
- **Steps**: Write failing test → Implement minimal code → Run test → Refactor
- **Stop condition**: Test passes, OR no test framework detected

#### verification-before-completion
- **Trigger**: Every task with clear completion criteria
- **Action**: Mandatory verification before claiming success
- **Steps**: Run relevant checks (lint, typecheck, tests) → Confirm output → Report results
- **Stop condition**: Verification passes, OR user acknowledges failure

#### writing-plans
- **Trigger**: Complex multi-step tasks
- **Action**: Creates structured implementation plan
- **Steps**: Decompose into subtasks → Identify dependencies → Estimate order → Execute with checkpoints
- **Stop condition**: Plan created and approved (explicitly or implicitly)

## Error Handling & Edge Cases

### Framework Conflicts
When multiple frameworks apply, they must be **composed** rather than conflicting. Priority order:
1. `systematic-debugging` (errors block everything)
2. `brainstorming` (planning comes before execution)
3. `writing-plans` (complex tasks need decomposition)
4. `test-driven-development` (execution guidance)
5. `verification-before-completion` (final gate)

### When Frameworks Should NOT Apply
- **Trivial tasks** (definition: < 3 lines changed, no logic/algorithm changes, no new functions, only variable/string updates): Skip `brainstorming` and `writing-plans`
- **No test infrastructure** (no test files detected, no test framework config like pytest.ini, jest.config.js, etc.): Skip `test-driven-development`, still apply others
- **User override**: User can say "just fix it" to skip `systematic-debugging` formalism
- **Emergency mode**: `/bypass` mode disables all frameworks for speed

### Failure States
| Scenario | Agent Behavior |
|----------|----------------|
| Verification fails | Report failure explicitly, don't claim success, offer options |
| Can't reproduce bug | Escalate to user with investigation summary |
| No clear requirements | Ask user rather than guessing |
| Framework overhead too high | Suggest simplifying to user |

## User Experience

### Transparency
Agent explicitly states which frameworks are active:
> "Using systematic-debugging framework: I'll reproduce this error first before proposing a fix."

### Control
User can override at any point:
> "This is taking too long, just fix it" → Agent skips remaining debugging steps

### Progress Indicators
For long-running framework steps:
> "[Step 2/4] Running tests to verify fix..."

### Learning
Agent remembers user preferences per project:
> "You usually skip brainstorming for CSS changes. I'll apply that here."

## Implementation Strategy

### Phase 1: Foundation
- Implement framework router and detection logic
- Add `verification-before-completion` as base framework (always on)
- Create framework status reporting in agent output

### Phase 2: Error Handling
- Integrate `systematic-debugging` for error scenarios
- Add reproduction-first behavior for bugs

### Phase 3: Planning
- Add `brainstorming` gates for creative tasks
- Implement `writing-plans` for complex tasks

### Phase 4: Quality
- Add `test-driven-development` when test infrastructure exists
- Fine-tune trivial task detection to avoid overhead

### Backward Compatibility
All frameworks are **opt-out** via settings or user override. Default behavior gradually improves without breaking existing workflows.

## Success Criteria

- Frameworks activate automatically based on task context
- Agent explicitly states which frameworks are in use
- Users can override frameworks without breaking workflow
- Framework overhead is minimal for trivial tasks
- Error handling becomes more systematic and reliable
- Verification gates reduce preventable mistakes
