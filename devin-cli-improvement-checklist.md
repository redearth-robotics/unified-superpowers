# Devin CLI Improvement Checklist

## Keep `AGENTS.md` short
- Include only stable, non-negotiable rules.
- Put package manager, test commands, and architecture constraints here.
- Avoid long examples or repeated workflow instructions.

## Create narrow skills
- One skill = one task.
- Give each skill a clear trigger, inputs, outputs, and stop condition.
- Split planning, execution, and verification into separate skills when possible.

## Add verification gates
- Require lint, typecheck, and tests for changes.
- Add checkpoints for larger tasks: plan → implement → verify → review.
- Make failure states explicit so the agent knows when to stop or escalate.

## Improve helper tooling
- Add tiny scripts for common actions like running the right test, showing the first failure, or restarting local services.
- Prefer commands that return concise, actionable errors.

## Write better prompts
- Say exactly where to start.
- Mention files or patterns to mirror.
- State what must not change.
- Define the verification step before the task is considered done.

## Best first moves
1. Shrink `AGENTS.md`.
2. Create 5–10 high-frequency skills.
3. Add helper scripts for verification.
4. Tighten tests in risky areas.
5. Use staged checkpoints for bigger tasks.
