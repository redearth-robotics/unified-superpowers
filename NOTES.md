## 2025-05-26 22:15 — Add super description to README.md

Comprehensive rewrite of README.md with narrative, technical details, and benefits:
- Enhanced hero section with narrative hook and value proposition
- New 'Why This Matters' section explaining the fragmentation problem
- Correct attribution of core process skills to obra/superpowers (15 skills)
- Detailed source repository highlights for all three sources with proper credit
- New 'Who This Is For' section with primary/secondary audiences
- Enhanced 'What Makes This Different' section with comprehensive comparison
- Updated 'Contributing' section with detailed source repository information
- Updated 'Updates & Maintenance' section with all three sources
- Enhanced 'Links' section with documentation references

Open follow-ups: none

## 2026-05-26 — Add framework-orchestrator skill

Created new core process skill to implement the Devin CLI systematic framework integration design:
- `framework-orchestrator` skill at `skills/core/framework-orchestrator/SKILL.md`
- Automatically selects and composes behavioral frameworks based on task context
- Integrates existing skills: systematic-debugging, brainstorming, test-driven-development, verification-before-completion, writing-plans
- Updated skill counts: core process 15→16, total 100→101
- Updated config/skills.json, README.md, SKILL_CATALOG.md
- Skill supports both model-trigger (automatic) and user-trigger (manual `/framework-orchestrator`) invocation
- Designed to avoid redundancy with existing orchestration skills (using-superpowers, subagent-driven-development, dispatching-parallel-agents)

Open follow-ups: none
