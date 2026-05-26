---
name: using-superpowers
description: Use at session start to discover and load relevant skills before any response - ensures skills auto-trigger at the right moments
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Superpowers skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md, GEMINI.md, or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In Copilot CLI:** Use the `skill` tool. Skills are auto-discovered from installed plugins. The `skill` tool works the same as Claude Code's `Skill` tool.

**In Gemini CLI:** Skills activate via the `activate_skill` tool. Gemini loads skill metadata at session start and activates the full content on demand.

**In other environments:** Check your platform's documentation for how skills are loaded.

## Platform Adaptation

Skills use Claude Code tool names. Non-CC platforms: see `references/copilot-tools.md` (Copilot CLI), `references/codex-tools.md` (Codex) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

```dot
digraph skill_flow {
    "User message received" [shape=doublecircle];
    "About to EnterPlanMode?" [shape=doublecircle];
    "Already brainstormed?" [shape=diamond];
    "Invoke brainstorming skill" [shape=box];
    "Might any skill apply?" [shape=diamond];
    "Invoke Skill tool" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Has checklist?" [shape=diamond];
    "Create TodoWrite todo per item" [shape=box];
    "Follow skill exactly" [shape=box];
    "Respond (including clarifications)" [shape=doublecircle];

    "About to EnterPlanMode?" -> "Already brainstormed?";
    "Already brainstormed?" -> "Invoke brainstorming skill" [label="no"];
    "Already brainstormed?" -> "Might any skill apply?" [label="yes"];
    "Invoke brainstorming skill" -> "Might any skill apply?";

    "User message received" -> "Might any skill apply?";
    "Might any skill apply?" -> "Invoke Skill tool" [label="yes, even 1%"];
    "Might any skill apply?" -> "Respond (including clarifications)" [label="definitely not"];
    "Invoke Skill tool" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Has checklist?";
    "Has checklist?" -> "Create TodoWrite todo per item" [label="yes"];
    "Has checklist?" -> "Follow skill exactly" [label="no"];
    "Create TodoWrite todo per item" -> "Follow skill exactly";
}
```

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Symptom | Why It's Wrong | What To Do Instead |
|---------|----------------|-------------------|
| "This is just a simple question" | Questions are tasks; skills prevent mistakes | Check for skills before answering |
| "I need more context first" | Skill check comes BEFORE clarifying questions | Invoke relevant skill first, then ask clarifying questions |
| "Let me explore the codebase first" | Skills tell you HOW to explore | Check for skills before exploration |
| "I can check git/files quickly" | Files lack conversation context | Check for skills before file operations |
| "This doesn't need a formal skill" | If a skill exists, use it | Invoke the skill |
| "I remember this skill" | Skills evolve; current version may differ | Read current skill version each time |
| "This doesn't count as a task" | Any action = task | Check for skills before any action |
| "The skill is overkill" | Simple things become complex | Use the skill |
| "I'll just do this one thing first" | Check BEFORE doing anything | Invoke skill first |
| "This feels productive" | Undisciplined action wastes time | Follow skill guidance |
| "I know what that means" | Knowing concept ≠ using skill correctly | Invoke the skill |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) - these determine HOW to approach the task
2. **Implementation skills second** (frontend-design, mcp-builder) - these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## Domain-Specific Skills

Superpowers includes specialized skills for specific domains:

**Robotics & Automation:**
- `robotics-superpowers` — Gateway skill that auto-triggers on robotics topics and routes to specialized skills
- `ros-robotics-expert` - ROS (Robot Operating System) for robotics arms and mobile robotics
- `robotics-localization-expert` - Robotics localization problems including visual odometry, SLAM, GPS-based localization
- `robotics-odometry-expert` - Robotics odometry problems including visual odometry, ground-based odometry, underwater odometry
- `robotics-data-analyzer` - Analyze robotics sensor data, perception systems, localization systems, vehicle hardware telemetry
- `robotics-field-engineer` - Field deployment, containerization, and CI/CD for robotics field operations
- `fusion-filter-robotics-expert` - Fusion filters, sensor fusion, and localization challenges in robotics systems
- `gps-ins-localization-expert` - GPS and INS (Inertial Navigation System) integration for robotics localization

**Software Engineering:**
- `python-expert` - Python code, debugging, optimization, and best practices
- `cpp-expert` - C/C++ code review for bugs, security issues, logic errors, performance problems
- `cpp-misra-auditor` - C++ code review for safety and compliance, especially MISRA standards
- `matlab-expert` - MATLAB code, Simulink models, and related technical problems
- `linux-ubuntu-expert` - Linux or Ubuntu system administration, configuration, troubleshooting
- `security-pentester` - Security assessments, penetration testing, and vulnerability identification
- `data-pipeline-architect` - Design, build, or optimize data pipelines and collection systems

These domain-specific skills have detailed trigger phrases and examples in their descriptions.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
