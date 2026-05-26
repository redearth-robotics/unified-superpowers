# Unified Superpowers Toolkit

🚀 **95 AI skills** for security testing, robotics engineering, and software development — all in one comprehensive toolkit.

## 🎯 What This Is

A unified skill collection that combines:
- **Security Testing** — Bug bounty methodology, vulnerability hunting, penetration testing (from [obra/superpowers](https://github.com/obra/superpowers))
- **Robotics Engineering** — ROS, sensor fusion, localization, embedded systems (from [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers))
- **Software Development** — Debugging, testing, code review, project planning

## 📊 Quick Stats

| Domain | Skills | Use For |
|--------|--------|---------|
| 🔒 Security | 52 | Bug bounty, pentesting, vulnerability research |
| 🤖 Robotics | 18 | ROS, GPS/INS, SLAM, embedded systems |
| 💻 Languages | 11 | Python, C++, Rust, JavaScript, MATLAB |
| ⚙️ Core Process | 14 | Debugging, testing, planning, code review |
| **Total** | **95** | **Complete development lifecycle** |

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
│   ├── core/              # Process skills (14)
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
│   └── languages/         # Language expertise (11)
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
# Should output: 95
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

For a complete listing of all 95 skills organized by domain, see [SKILL_CATALOG.md](SKILL_CATALOG.md).

## 🔄 Updates & Maintenance

This is a local integration. To update from upstream repositories:

```bash
# Update from obra/superpowers
cd /path/to/superpowers
git pull

# Update from robotics-superpowers
cd /path/to/robotics-superpowers
git pull

# Manually sync changes to unified-superpowers
# Review and merge relevant skill updates
```

## 🤝 Contributing

This toolkit is a local integration combining skills from two major repositories:

### Source Repositories

**Security Skills (52 skills)**
- Source: [obra/superpowers](https://github.com/obra/superpowers)
- Author: [obra](https://github.com/obra)
- Skills: Bug bounty methodology, vulnerability hunting, penetration testing, OSINT, red team operations
- License: See individual skill directories

**Robotics Skills (18 skills)**
- Source: [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers)
- Author: [RedEarth-Robotics](https://github.com/RedEarth-Robotics)
- Skills: ROS, GPS/INS fusion, localization, embedded systems, sensor fusion
- License: See individual skill directories

**Core Process Skills (14 skills)**
- Source: robotics-superpowers
- Skills: Debugging, testing, planning, code review, git workflows

**Language Skills (11 skills)**
- Source: Both repositories
- Skills: Python, C++, Rust, JavaScript, MATLAB, Go, Java

### Integration Notes

This unified toolkit:
- Merges security-pentester skill from both sources (methodology + payloads)
- Maintains original skill structure and content
- Preserves all original licenses
- Provides cross-platform installation scripts
- Auto-deploys to 7 AI coding platforms

For contributions to the original repositories:
- **obra/superpowers**: [Submit PR](https://github.com/obra/superpowers)
- **robotics-superpowers**: [Submit PR](https://github.com/RedEarth-Robotics/robotics-superpowers)

## 📄 License

See individual skill directories for their original licenses. This integration maintains the licenses of the source repositories.

## 🔗 Links

- **GitHub**: https://github.com/RedEarth-Robotics/unified-superpowers
- **Issues**: Report issues via GitHub Issues
- **Original Sources**:
  - [obra/superpowers](https://github.com/obra/superpowers): Security testing skills (52 skills)
  - [robotics-superpowers](https://github.com/RedEarth-Robotics/robotics-superpowers): Robotics engineering skills (18 skills)

---

**Built for security researchers, robotics engineers, and developers who want comprehensive AI assistance across the entire development lifecycle.**
