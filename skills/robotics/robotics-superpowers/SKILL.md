---
description: "Use when starting any conversation involving robotics topics. This skill ensures the correct specialized robotics skill is invoked before any response or action.\n\nAuto-triggers on:\n- 'ROS', 'robot', 'robotic', 'localization', 'odometry', 'SLAM'\n- 'sensor fusion', 'GPS', 'IMU', 'LiDAR', 'Gazebo', 'navigation'\n- 'kinematics', 'manipulator', 'autonomous', 'drifting', 'pose estimation'\n- 'tf frames', 'odom', 'amcl', 'move_base', 'rtabmap', 'cartographer'\n\nThis skill does not provide robotics advice directly — it routes to the correct specialized skill."
name: robotics-superpowers
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a robotics skill might apply to what you are doing, you ABSOLUTELY MUST invoke the correct specialized skill.

IF A ROBOTICS SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Robotics skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** — highest priority
2. **Robotics skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

## The Rule

**Invoke relevant or requested robotics skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke it. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

## Red Flags

| Symptom | Why It's Wrong | What To Do Instead |
|---|---|---|
| Answering a ROS or robotics question directly without invoking a skill | Robotics tasks have real-time, safety, and architecture implications that a default response will miss without domain context | Invoke the matching skill (e.g., `ros-robotics-expert`) before writing any answer or taking any action |
| Asking clarifying questions before checking for a relevant skill | Skills define how to gather information correctly; asking first means gathering it without the right domain framework | Invoke the most likely skill first, then use its methodology to guide any clarifying questions that remain |
| Exploring the codebase or reading files before invoking a robotics skill | Files lack robotics context; you will misinterpret what you find without the skill's domain framework in place | Invoke the relevant skill before opening any files so you know what to look for and how to interpret it |
| Deciding a skill is "overkill" for a request that looks simple | Simple robotics tasks regularly reveal hidden complexity in coordinate frames, timing, and hardware interactions that the skill catches | Invoke the skill unconditionally; if it genuinely does not apply, you lose only seconds |
| Relying on a remembered version of a skill instead of invoking it fresh | Skills are actively updated; a cached mental model will miss recent guidance changes and evolved methodology | Always invoke the skill to read the current version before acting, regardless of how recently you last used it |
| Starting a debugging session without invoking the domain skill first | Debugging robotic systems requires domain-specific methodology; generic debugging skips real-time constraints and hardware interactions | Identify the domain (localization, odometry, sensor fusion, etc.) and invoke the matching skill before beginning diagnosis |
| Treating skill invocation as optional because "this is just one quick thing" | Any action on a robotic system has consequences; quick actions taken without domain context cause hard-to-diagnose regressions | Check for a skill before every action, no matter how small or routine it appears |

## Decision Table: Which Robotics Skill to Invoke?

| User Says | Invoke |
|-----------|--------|
| "ROS", "topic", "node", "launch file", "package", "rviz", "rqt", "catkin", "colcon" | `ros-robotics-expert` |
| "drifting", "localization", "SLAM", "pose", "odom frame", "amcl", "rtabmap", "cartographer" | `robotics-localization-expert` |
| "odometry", "wheel encoder", "visual odometry", "DVL", "encoder", "dead reckoning" | `robotics-odometry-expert` |
| "sensor data", "ROS bag", "perception", "analyze data", "telemetry", "sensor log" | `robotics-data-analyzer` |
| "Kalman filter", "EKF", "UKF", "sensor fusion", "fuse GPS", "particle filter", "state estimation" | `fusion-filter-robotics-expert` |
| "GPS", "INS", "RTK", "DGPS", "GPS denied", "inertial navigation", "GNSS" | `gps-ins-localization-expert` |
| "deploy", "Docker", "Kubernetes", "CI/CD", "production robot", "containerize", "orchestrate" | `robotics-field-engineer` |

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach the task
2. **Domain skills second** — invoke the robotics skill matching the primary problem

"My robot is drifting in SLAM" → `robotics-localization-expert` first, then follow its methodology.
"Fix this bug in my ROS node" → `ros-robotics-expert` first, then follow its debugging process.

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you — follow it directly.

**In Copilot CLI:** Use the `skill` tool. Skills are auto-discovered from installed plugins.

**In Gemini CLI:** Skills activate via the `activate_skill` tool.

**In other environments:** Check your platform's documentation for how skills are loaded.

## Platform Adaptation

Skills use Claude Code tool names. Non-CC platforms: see `references/copilot-tools.md` (Copilot CLI), `references/codex-tools.md` (Codex) for tool equivalents.
