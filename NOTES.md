## 2026-06-04 01:15 — Create unified installers

Created modular menu system for unified-superpowers scripts:
- `install-mcp-stack.sh` — consolidated MCP/token optimization stack installer
  - Replaces setup-token-optimizer.sh with cleaner interactive menu
  - Supports --dry-run, --minimal, --full modes
  - Categories: Core Stack, MCP Servers, Tools, Configuration
- `scripts-manager.sh` — unified script manager
  - Hierarchical menu: Installation, Utilities, Setup, MCP Stack, Custom, Help
  - Auto-discovers available scripts
  - Remembers state between sessions
- Updated `scripts/README.md` with new installer documentation
- Both scripts made executable

Open follow-ups: Test both installers in a fresh environment

## 2026-06-04 00:56 — Integrate agentic_installers_tools skills and scripts

Integrated skills and scripts from agentic_installers_tools into unified-superpowers:
- Extracted skills from skills_navya_doyle_spellcaster.zip
- Added `find-skills` to `skills/core/` (skill discovery and installation)
- Added `likec4-dsl` to `skills/languages/` (architecture modeling DSL)
- Added `slidev` to `skills/languages/` (presentation tool)
- Created new `skills/navya/` directory and added Navya ecosystem skills:
  - `navya` (umbrella skill for Navya development ecosystem)
  - `navya-git-flow` (git workflow for C++ projects and Chaudron integration)
  - `doyle` (Navya C++ workspace and build manager)
  - `grimoire` (configuration library)
  - `rtmaps` (real-time data-flow middleware)
  - `spellcaster` (drive composition CLI)
- Copied scripts to `scripts/`:
  - `backup-restore-ai-configs.sh` (AI configuration backup/restore)
  - `maintain-stack.sh` (stack maintenance script)
  - `run-benchmark.sh` (benchmark runner)
  - `setup-global-token-rules.sh` (global token rules setup)
  - `setup-token-optimizer.sh` (token optimizer setup)
  - `README.md` (scripts documentation)
- Made all scripts executable

Open follow-ups: Update skill counts in config files and documentation

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

Open follow-ups:
- Fixed README.md counts: line 3 (100→101), line 31 (100→101), line 108 (100→101)
- Fixed docs/README-super-description-design.md: 100→101
- Fixed config/skills-list.txt: 100→101
- Enhanced framework-orchestrator SKILL.md:
  - Added Detection Implementation Guide with concrete patterns
  - Added Framework Invocation Mechanism section
  - Added User Override Handling with explicit phrases
  - Expanded Red Flags with framework-specific pitfalls

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
