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

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple ROS question" | Robotics questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack robotics context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a robotics skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

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
