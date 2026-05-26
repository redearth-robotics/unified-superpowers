# Unified Superpowers Toolkit

**100 battle-tested AI skills for the complete development lifecycle — from brainstorming to bug bounty to robot deployment.**

## 🎯 The Problem We Solve

You need AI assistance across the entire development lifecycle, but the tools are fragmented:
- **Security researchers** struggle with scattered vulnerability databases and inconsistent methodologies
- **Robotics engineers** face complex sensor fusion and localization challenges with no systematic approach
- **Developers** waste time context-switching between debugging, testing, and planning tools

**Unified Superpowers solves this by bringing together 100 specialized skills from three expert sources into one cohesive toolkit.**

## 💡 What You Get

A unified skill collection that covers the complete development lifecycle:
- **🔒 Security Testing** — Bug bounty methodology, vulnerability hunting, penetration testing (52 skills from [Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter))
- **🤖 Robotics Engineering** — ROS, sensor fusion, localization, embedded systems (18 skills from [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers))
- **💻 Software Development** — Debugging, testing, code review, project planning (15 language skills + 15 core process skills)

## 🏗️ Why This Matters

### The Fragmentation Problem
Modern development requires expertise across multiple domains, but AI assistance tools are siloed. You need one tool for debugging, another for security testing, and yet another for robotics. This fragmentation wastes time and creates inconsistent workflows.

### The Unified Solution
**Unified Superpowers** brings together skills from three specialized repositories:
- **obra/superpowers** provides the foundational core process skills (15) that govern how you approach any development task
- **Claude-BugHunter** contributes battle-tested security skills (52) developed from real authorized engagements with 681 disclosed reports
- **robotics-superpowers** adds specialized robotics and language expertise (33) for complex engineering challenges

### The Impact
With 100 skills auto-deploying to 7 AI coding platforms, you get comprehensive assistance that adapts to your workflow — not the other way around. Skills auto-trigger based on natural language queries, providing expert guidance exactly when you need it.

## 📊 Quick Stats

| Domain | Skills | Use For |
|--------|--------|---------|
| 🔒 Security | 52 | Bug bounty, pentesting, vulnerability research |
| 🤖 Robotics | 18 | ROS, GPS/INS, SLAM, embedded systems |
| 💻 Languages | 15 | Python, C++, Rust, JavaScript, MATLAB, DevOps |
| ⚙️ Core Process | 15 | Debugging, testing, planning, code review |
| **Total** | **100** | **Complete development lifecycle** |

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone git@github.com:RedEarth-Robotics/unified-superpowers.git
cd unified-superpowers

# Skills are ready to use — no additional setup required
```

### Basic Usage

Skills auto-trigger based on your queries. Just ask naturally:

**Security Testing:**
```
"Can you audit this authentication system for vulnerabilities?"
"Help me find XSS vulnerabilities in this web app"
"Perform a penetration test on this API"
```

**Robotics:**
```
"My robot keeps drifting, can you help debug the localization?"
"How do I fuse GPS with IMU data for better positioning?"
"Review my ROS node for sensor integration issues"
```

**Development:**
```
"Help me debug this Python code"
"Review my implementation for bugs"
"I need to plan a new feature"
```

## 📁 Structure

```
unified-superpowers/
├── skills/
│   ├── core/              # Process skills (15)
│   │   ├── brainstorming          # Design & spec creation
│   │   ├── systematic-debugging   # Bug investigation
│   │   ├── test-driven-development # TDD methodology
│   │   └── ...
│   ├── security/          # Security skills (52)
│   │   ├── bug-bounty             # Complete bug bounty workflow
│   │   ├── hunt-xss               # XSS vulnerability hunting
│   │   ├── hunt-sqli              # SQL injection testing
│   │   ├── security-pentester     # General pentesting (merged)
│   │   └── ...
│   ├── robotics/          # Robotics skills (18)
│   │   ├── ros-robotics-expert    # ROS development
│   │   ├── gps-ins-localization   # GPS/INS sensor fusion
│   │   ├── fusion-filter-robotics # Kalman/EKF filters
│   │   └── ...
│   └── languages/         # Language expertise (15)
│       ├── python-expert          # Python debugging & optimization
│       ├── cpp-expert             # C++ review & MISRA compliance
│       ├── rust-expert            # Rust safety & performance
│       └── ...
├── config/
│   ├── skills.json        # Complete skill catalog
│   └── skills-list.txt    # Quick reference list
└── README.md
```

## 🔥 Popular Skills

### Security
- **`bug-bounty`** — Complete bug bounty workflow (recon → hunt → report)
- **`security-pentester`** — General pentesting with payloads & bypass tables
- **`hunt-xss`** — Cross-site scripting vulnerability hunting
- **`hunt-sqli`** — SQL injection testing techniques
- **`offensive-osint`** — Open-source intelligence for security research

### Robotics
- **`ros-robotics-expert`** — ROS development, debugging, integration
- **`gps-ins-localization-expert`** — GPS/INS sensor fusion for localization
- **`fusion-filter-robotics-expert`** — Kalman/EKF filter implementation
- **`robotics-data-analyzer`** — Sensor data analysis & diagnostics
- **`robotics-localization-expert`** — SLAM, visual odometry, pose estimation

### Development
- **`systematic-debugging`** — Structured bug investigation methodology
- **`test-driven-development`** — TDD workflow and best practices
- **`brainstorming`** — Design and specification creation
- **`python-expert`** — Python debugging, optimization, best practices
- **`cpp-expert`** — C++ review, safety, performance

## 🎯 Who This Is For

### Primary Audiences
- **Security Researchers** conducting bug bounty programs, penetration testing, and vulnerability research
- **Robotics Engineers** working on autonomous systems, sensor fusion, and embedded systems
- **Software Developers** building production applications across multiple languages

### Secondary Audiences
- **DevOps Engineers** managing CI/CD pipelines and infrastructure
- **Embedded Systems Developers** working on hardware-software integration
- **Data Engineers** building data pipelines and processing systems

### Use Cases
- **Bug Bounty Programs**: Systematic vulnerability hunting with 28 hunt modules covering XSS, SQLi, RCE, and more
- **Robotics Projects**: ROS development, GPS/INS sensor fusion, SLAM implementation, embedded systems
- **Software Development**: Multi-language debugging, TDD, code review, architecture design
- **DevOps Automation**: CI/CD pipeline design, Linux administration, software architecture

## 💡 Use Case Examples

### Bug Bounty Hunter
```
User: "I'm starting a bug bounty program for example.com. Where should I begin?"

AI: [Activates bug-bounty skill]
Let me help you set up a systematic approach. We'll start with:
1. Scope verification and asset discovery
2. Technology fingerprinting
3. Vulnerability hunting strategy
4. Report writing and submission
```

### Robotics Engineer
```
User: "My underwater drone keeps losing position when GPS signal is weak"

AI: [Activates gps-ins-localization-expert skill]
This is a classic GPS denial scenario. Let me help you:
1. Analyze your current sensor fusion setup
2. Implement dead-reckoning fallback
3. Optimize your EKF parameters for underwater conditions
```

### Software Developer
```
User: "This Python function is running slowly, can you help optimize it?"

AI: [Activates python-expert skill]
I'll analyze the performance bottlenecks and suggest optimizations:
1. Profile the function to identify hotspots
2. Check for algorithmic improvements
3. Suggest Pythonic optimizations
4. Verify the fix doesn't break functionality
```

## 🔧 Installation & Setup

### Quick Install (Recommended)

Use the provided installation scripts for easy setup:

```bash
# Universal installer (auto-detects platform)
./scripts/install-universal.sh

# Or use platform-specific scripts
./scripts/install.sh          # Linux/macOS
python3 scripts/install.py     # Cross-platform Python
```

For detailed installation options, see [INSTALLATION.md](INSTALLATION.md).

### Manual Installation

1. **Clone the repository**
```bash
git clone git@github.com:RedEarth-Robotics/unified-superpowers.git
cd unified-superpowers
```

2. **Configure your AI assistant**
- Point your assistant to the `skills/` directory
- Skills will auto-discover based on your platform

3. **Verify installation**
```bash
# Check skill count
find skills -name "SKILL.md" | wc -l
# Should output: 100
```

### Platform-Specific Setup

**Devin CLI:**
```bash
# Skills auto-discover from .devin/skills/ or project root
# No additional configuration needed
```

**Claude Code:**
```bash
# Ensure skills directory is in your project root
# Skills auto-load via Claude Code's skill system
```

**Other Platforms:**
- Consult your platform's documentation for skill integration
- Most platforms support auto-discovery from `skills/` directories

### Installation Script Options

All installation scripts support:
- `-d, --directory DIR` - Custom installation directory
- `-y, --yes` - Automated mode (no prompts)
- `--skip-deps` - Skip dependency checks
- `-v, --verbose` - Verbose output
- `-h, --help` - Show help message

Example:
```bash
./scripts/install.sh -d ~/my-skills --yes
```

## 📚 Skill Catalog

For a complete listing of all 100 skills organized by domain, see [SKILL_CATALOG.md](SKILL_CATALOG.md).

## 📖 Documentation

- [SKILL_CATALOG.md](SKILL_CATALOG.md) — Complete skill listing by domain
- [docs/ENGAGEMENTS.md](docs/ENGAGEMENTS.md) — Authorized engagement records for security skills
- [INSTALLATION.md](INSTALLATION.md) — Detailed installation instructions

## 🔄 Updates & Maintenance

This is a curated integration from three upstream repositories. To update from sources:

```bash
# Update from obra/superpowers (core process skills)
cd /path/to/superpowers
git pull

# Update from Claude-BugHunter (security skills)
cd /path/to/Claude-BugHunter
git pull

# Update from robotics-superpowers (robotics & language skills)
cd /path/to/robotics-superpowers
git pull

# Manually sync changes to unified-superpowers
# Review and merge relevant skill updates
```

**Update Frequency**: We recommend checking for updates monthly. Security skills from Claude-BugHunter are updated based on new vulnerability research. Core process skills from obra/superpowers are updated based on methodology improvements. Robotics skills are updated based on new engineering patterns.

## ✨ What Makes This Different

### Comprehensive Coverage
**100 skills from three expert sources** vs fragmented single-domain tools. You get security testing, robotics engineering, software development, and core process skills — all working together seamlessly.

### Battle-Tested Quality
- **Security skills** developed from real authorized engagements (681 disclosed reports)
- **Core process skills** refined through production use across thousands of development sessions
- **Robotics skills** validated on real autonomous systems and embedded platforms

### Three Expert Sources, One Unified Toolkit

**obra/superpowers** — The Foundation
- **15 core process skills** that govern how you approach any development task
- Skills: brainstorming, systematic-debugging, test-driven-development, verification-before-completion, writing-plans, and more
- Provides the methodology framework that makes all other skills more effective

**Claude-BugHunter** — The Security Arsenal
- **52 security skills** battle-tested from real authorized engagements
- Skills: bug-bounty, hunt-xss, hunt-sqli, security-pentester, offensive-osint, and more
- Developed from 2 authorized engagements with 681 disclosed vulnerability reports

**robotics-superpowers** — The Engineering Expertise
- **33 robotics and language skills** for complex engineering challenges
- Skills: ros-robotics-expert, gps-ins-localization-expert, python-expert, devops-engineer, and more
- Specialized expertise for ROS, sensor fusion, localization, and multi-language development

### Seamless Integration
- **Auto-deployment** to 7 AI coding platforms (.claude, .opencode, .devin, .codeium, .codex, .copilot, .cursor)
- **Cross-platform installers** for Linux, macOS, and Windows
- **Natural language triggers** — skills activate based on what you're actually asking
- **Unified workflow** — no context switching between different AI assistance tools

## 🤝 Contributing

This toolkit is a curated integration combining skills from three expert repositories:

### Source Repositories

**Core Process Skills (15 skills)**
- Source: [obra/superpowers](https://github.com/obra/superpowers)
- Author: [obra](https://github.com/obra)
- Skills: brainstorming, systematic-debugging, test-driven-development, verification-before-completion, writing-plans, subagent-driven-development, executing-plans, finishing-a-development-branch, requesting-code-review, receiving-code-review, using-git-worktrees, using-superpowers, writing-skills, token-optimizer
- Purpose: Foundational methodology and process framework for all development work
- License: See individual skill directories

**Security Skills (52 skills)**
- Source: [Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter)
- Author: [elementalsouls](https://github.com/elementalsouls)
- Skills: Bug bounty methodology, vulnerability hunting (28 hunt modules), penetration testing, OSINT, red team operations
- Purpose: Comprehensive security testing with battle-tested techniques
- License: See individual skill directories

**Robotics & Language Skills (33 skills)**
- Source: [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers)
- Author: [RedEarth-Robotics](https://github.com/RedEarth-Robotics)
- Skills: ROS development, GPS/INS fusion, SLAM, embedded systems, Python, C++, Rust, JavaScript, MATLAB, Go, Java, DevOps, Linux, Software Architecture
- Purpose: Specialized engineering expertise for robotics and multi-language development
- License: See individual skill directories

### Integration Approach

This unified toolkit:
- **Preserves** original skill structure and content from all three sources
- **Merges** security-pentester skill (methodology from robotics-superpowers + payloads from Claude-BugHunter's security-arsenal)
- **Maintains** all original licenses — each skill retains its source repository's license
- **Provides** cross-platform installation scripts for easy deployment
- **Auto-deploys** to 7 AI coding platforms for seamless workflow integration
- **Regularly syncs** with upstream repositories to maintain currency

For contributions to the original repositories:
- **obra/superpowers**: [Submit PR](https://github.com/obra/superpowers) — Core process skills and methodology
- **Claude-BugHunter**: [Submit PR](https://github.com/elementalsouls/Claude-BugHunter) — Security testing skills
- **robotics-superpowers**: [Submit PR](https://github.com/RedEarth-Robotics/robotics-superpowers) — Robotics and language skills

## 📄 License

See individual skill directories for their original licenses. This integration maintains the licenses of the source repositories. Each skill retains the license of its original source repository.

## 🔗 Links

- **GitHub**: https://github.com/RedEarth-Robotics/unified-superpowers
- **Issues**: Report issues via GitHub Issues
- **Documentation**:
  - [SKILL_CATALOG.md](SKILL_CATALOG.md) — Complete skill listing by domain
  - [docs/ENGAGEMENTS.md](docs/ENGAGEMENTS.md) — Authorized engagement records for security skills
  - [INSTALLATION.md](INSTALLATION.md) — Detailed installation instructions
- **Original Sources**:
  - [obra/superpowers](https://github.com/obra/superpowers): Core process skills (15 skills)
  - [Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter): Security testing skills (51 skills)
  - [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers): Robotics & language skills (33 skills)

---

**Built for security researchers, robotics engineers, and developers who demand comprehensive, battle-tested AI assistance across the entire development lifecycle.**
