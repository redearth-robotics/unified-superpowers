# Unified Superpowers Toolkit

111 battle-tested AI skills for the complete development lifecycle. From brainstorming to bug bounty to robot deployment, in one place.

This is a curated integration of skills from five sources:

- **[obra/superpowers](https://github.com/obra/superpowers)** — 15 core process skills. The methodology framework: debugging, testing, planning, code review.
- **[Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter)** — 52 security skills. Built from real engagements with 681 disclosed vulnerability reports.
- **[robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers)** — 33 robotics and language skills. ROS, sensor fusion, localization, plus Python, C++, Rust, JavaScript, and more.
- **[stop-slop](https://github.com/hardikp/stop-slop)** — 1 writing skill. Remove AI-generated patterns from prose. Active voice, no filler, no adverbs.
- **[agentic_installers_tools](https://github.com/navya/agentic_installers_tools)** — 9 skills. Navya autonomous vehicle ecosystem (C++ build, Git flow, RTMaps), skill discovery, and developer tooling.

Total: 111 skills.

## Quick Start

Clone it:
```bash
git clone git@github.com:RedEarth-Robotics/unified-superpowers.git
cd unified-superpowers
```

Or use the installer:
```bash
./scripts/install-universal.sh
```

The installer auto-deploys skills to 7 AI coding platforms: .claude, .opencode, .devin, .codeium, .codex, .copilot, .cursor. Skip with `--no-platforms`.

Or use the new interactive installers:
```bash
# Unified token installer (DCP, skills framework, MCP servers, tools)
bash scripts/unified-token-installer.sh

# Script manager (browse and run all scripts)
bash scripts/scripts-manager.sh
```

Verify:
```bash
find skills -name "SKILL.md" | wc -l
# Should output: 111
```

## What's Inside

| Domain | Count | Highlights |
|--------|-------|------------|
| Security | 52 | 28 hunt modules, bug bounty, pentesting, OSINT |
| Core Process | 17 | Debugging, TDD, planning, code review, parallel agents, framework orchestration, skill discovery |
| Robotics | 18 | ROS, GPS/INS fusion, SLAM, embedded systems |
| Languages | 17 | Python, C++, Rust, JavaScript, MATLAB, DevOps, Linux, likec4, Slidev |
| Navya | 6 | C++ build (Doyle), Git flow, RTMaps, configuration (Grimoire), drive composition (Spellcaster) |
| Writing | 1 | Remove AI slop from prose. Active voice, no filler |

See [SKILL_CATALOG.md](SKILL_CATALOG.md) for the full list.

## How It Works

Skills auto-trigger based on what you ask. No manual loading, no configuration files.

**Security example:**
```
"Audit this auth system for vulnerabilities"
→ Activates security-pentester + hunt-auth-bypass
```

**Robotics example:**
```
"My underwater drone loses position when GPS is weak"
→ Activates gps-ins-localization-expert + fusion-filter-robotics-expert
```

**Development example:**
```
"This Python function is slow"
→ Activates python-expert + systematic-debugging
```

**Writing example:**
```
"This README sounds like AI wrote it"
→ Activates stop-slop
```

**Navya example:**
```
"How do I build this C++ project with Doyle?"
→ Activates doyle + navya
```

## Popular Skills

**Security**
- `bug-bounty` — Complete workflow: recon → hunt → report
- `security-pentester` — General pentesting with payloads and bypass tables
- `hunt-xss` — Cross-site scripting hunting methodology
- `offensive-osint` — Open-source intelligence gathering

**Robotics**
- `ros-robotics-expert` — ROS development, debugging, integration
- `gps-ins-localization-expert` — GPS/INS sensor fusion for localization
- `robotics-data-analyzer` — Sensor data analysis and diagnostics

**Development**
- `systematic-debugging` — Structured bug investigation methodology
- `brainstorming` — Design and specification creation
- `python-expert` — Debugging, optimization, best practices
- `cpp-expert` — Review, safety, MISRA compliance
- `find-skills` — Discover and install skills from the open ecosystem

**Navya**
- `doyle` — C++ workspace and build manager (Conan/CMake)
- `navya-git-flow` — Git workflow for C++ projects and Chaudron integration
- `spellcaster` — Drive composition and deployment CLI

## Installation Options

### Skill Deployment

All scripts support `-d` (custom directory), `-y` (automated), `--skip-deps`, `--no-platforms`, `-v` (verbose).

```bash
# Universal (cross-platform)
./scripts/install-universal.sh -d ~/skills --yes
```

### MCP Stack & Tooling

Interactive installers with menus, dry-run support, and component selection:

```bash
# Unified token installer — DCP, skills framework, MCP servers, tools
bash scripts/unified-token-installer.sh              # Full auto mode
bash scripts/unified-token-installer.sh --interactive # Menu-driven selection
bash scripts/unified-token-installer.sh --minimal     # Core stack only
bash scripts/unified-token-installer.sh --dry-run     # Preview without installing

# Script manager — browse and run all project scripts
bash scripts/scripts-manager.sh            # Interactive menu
bash scripts/scripts-manager.sh --dry-run  # Preview mode
```

### Utility Scripts

```bash
# Backup/restore AI configurations
bash scripts/backup-restore-ai-configs.sh save
bash scripts/backup-restore-ai-configs.sh restore --from=~/backups/latest

# Maintain and update stack components
bash scripts/maintain-stack.sh --check     # Check for updates
bash scripts/maintain-stack.sh --update    # Interactive update

# Run benchmark suite
bash scripts/run-benchmark.sh
```

For full details, see [INSTALLATION.md](INSTALLATION.md) and [scripts/README.md](scripts/README.md).

## Documentation

- [SKILL_CATALOG.md](SKILL_CATALOG.md) — All 111 skills, organized by domain
- [docs/ENGAGEMENTS.md](docs/ENGAGEMENTS.md) — Security skill provenance: real engagement records
- [INSTALLATION.md](INSTALLATION.md) — Platform-specific setup and troubleshooting
- [scripts/README.md](scripts/README.md) — Scripts and installer documentation

## Updates

This is a curated integration. Update from upstreams manually:

```bash
cd /path/to/superpowers && git pull          # core process skills
cd /path/to/Claude-BugHunter && git pull     # security skills
cd /path/to/robotics-superpowers && git pull # robotics & language skills
```

We check for upstream updates monthly.

## Contributing

Contribute to the original repositories, not here:

- [obra/superpowers](https://github.com/obra/superpowers) — Core process skills
- [Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter) — Security skills
- [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers) — Robotics & language skills
- [stop-slop](https://github.com/hardikp/stop-slop) — Writing skills
- [agentic_installers_tools](https://github.com/navya/agentic_installers_tools) — Navya ecosystem and developer tooling

This repo is the integration layer. It preserves original skill structure, maintains all original licenses, and handles cross-platform deployment.

## License

See individual skill directories. Each skill retains its original source repository's license.

---

Built by [RedEarth-Robotics](https://github.com/RedEarth-Robotics) by integrating skills from [obra](https://github.com/obra), [elementalsouls](https://github.com/elementalsouls), and [RedEarth-Robotics](https://github.com/RedEarth-Robotics).
