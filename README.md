# Unified Superpowers Toolkit

102 battle-tested AI skills for the complete development lifecycle. From brainstorming to bug bounty to robot deployment, in one place.

This is a curated integration of skills from four sources:

- **[obra/superpowers](https://github.com/obra/superpowers)** — 15 core process skills. The methodology framework: debugging, testing, planning, code review.
- **[Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter)** — 52 security skills. Built from real engagements with 681 disclosed vulnerability reports.
- **[robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers)** — 33 robotics and language skills. ROS, sensor fusion, localization, plus Python, C++, Rust, JavaScript, and more.
- **[stop-slop](https://github.com/hardikp/stop-slop)** — 1 writing skill. Remove AI-generated patterns from prose. Active voice, no filler, no adverbs.

Total: 102 skills.

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

Verify:
```bash
find skills -name "SKILL.md" | wc -l
# Should output: 102
```

## What's Inside

| Domain | Count | Highlights |
|--------|-------|------------|
| Security | 52 | 28 hunt modules, bug bounty, pentesting, OSINT |
| Robotics | 18 | ROS, GPS/INS fusion, SLAM, embedded systems |
| Languages | 15 | Python, C++, Rust, JavaScript, MATLAB, DevOps, Linux |
| Core Process | 16 | Debugging, TDD, planning, code review, parallel agents, framework orchestration |
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

## Installation Options

All scripts support `-d` (custom directory), `-y` (automated), `--skip-deps`, `--no-platforms`, `-v` (verbose).

```bash
# Universal (auto-detects platform)
./scripts/install-universal.sh

# Linux/macOS
./scripts/install.sh -d ~/skills --yes

# Cross-platform Python
python3 scripts/install.py

# Windows
.\scripts\install.ps1 -NoPlatforms
```

For full details, see [INSTALLATION.md](INSTALLATION.md).

## Documentation

- [SKILL_CATALOG.md](SKILL_CATALOG.md) — All 102 skills, organized by domain
- [docs/ENGAGEMENTS.md](docs/ENGAGEMENTS.md) — Security skill provenance: real engagement records
- [INSTALLATION.md](INSTALLATION.md) — Platform-specific setup and troubleshooting

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

This repo is the integration layer. It preserves original skill structure, maintains all original licenses, and handles cross-platform deployment.

## License

See individual skill directories. Each skill retains its original source repository's license.

---

Built by [RedEarth-Robotics](https://github.com/RedEarth-Robotics) by integrating skills from [obra](https://github.com/obra), [elementalsouls](https://github.com/elementalsouls), and [RedEarth-Robotics](https://github.com/RedEarth-Robotics).
