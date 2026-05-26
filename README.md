# Unified Superpowers Toolkit

🚀 **95 AI skills** for security testing, robotics engineering, and software development — all in one comprehensive toolkit.

## 🎯 What This Is

A unified skill collection that combines:
- **Security Testing** — Bug bounty methodology, vulnerability hunting, penetration testing
- **Robotics Engineering** — ROS, sensor fusion, localization, embedded systems
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

### Prerequisites
- Git
- Your AI assistant environment (Devin, Claude Code, etc.)

### Installation Steps

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

## 📚 Skill Catalog

### Core Process Skills (14)
- `brainstorming` — Design and specification creation
- `systematic-debugging` — Structured bug investigation
- `test-driven-development` — TDD methodology
- `token-optimizer` — Token-efficient AI interactions
- `verification-before-completion` — Quality gate before claiming completion
- `writing-plans` — Implementation plan creation
- `writing-skills` — Skill development best practices
- `subagent-driven-development` — Parallel task execution
- `executing-plans` — Plan execution with checkpoints
- `finishing-a-development-branch` — Branch completion workflow
- `requesting-code-review` — Code review requests
- `receiving-code-review` — Handling review feedback
- `using-git-worktrees` — Git worktree management
- `using-superpowers` — Skill system usage

### Security Skills (52)
- `bug-bounty` — Complete bug bounty workflow
- `security-pentester` — General pentesting (merged skill)
- `hunt-xss` — Cross-site scripting
- `hunt-sqli` — SQL injection
- `hunt-ssrf` — Server-side request forgery
- `hunt-csrf` — Cross-site request forgery
- `hunt-idor` — Insecure direct object references
- `hunt-rce` — Remote code execution
- `hunt-xxe` — XML external entity injection
- `hunt-ssti` — Server-side template injection
- `hunt-file-upload` — File upload vulnerabilities
- `hunt-oauth` — OAuth/OIDC security
- `hunt-graphql` — GraphQL security
- `hunt-http-smuggling` — HTTP request smuggling
- `hunt-cache-poison` — Web cache poisoning
- `hunt-business-logic` — Business logic flaws
- `hunt-race-condition` — Race condition exploitation
- `hunt-mfa-bypass` — Multi-factor authentication bypass
- `hunt-saml` — SAML security
- `hunt-cloud-misconfig` — Cloud security misconfigurations
- `hunt-api-misconfig` — API security issues
- `hunt-aspnet` — ASP.NET specific vulnerabilities
- `hunt-llm-ai` — LLM/AI security testing
- `offensive-osint` — Open-source intelligence
- `osint-methodology` — OSINT research methods
- `redteam-mindset` — Red team thinking patterns
- `redteam-report-template` — Red team reporting
- `evidence-hygiene` — Evidence collection best practices
- `report-writing` — Security report writing
- `triage-validation` — Finding validation
- `bb-methodology` — Bug bounty methodology
- `bb-local-toolkit` — Local bug bounty tools
- `bugcrowd-reporting` — Bugcrowd platform reporting
- `security-arsenal` — Security payload collection
- `cloud-iam-deep` — Cloud IAM security
- `enterprise-vpn-attack` — Enterprise VPN security
- `m365-entra-attack` — Microsoft 365 security
- `okta-attack` — Okta security testing
- `vmware-vcenter-attack` — VMware vCenter security
- `supply-chain-attack-recon` — Supply chain security
- `web2-recon` — Web application reconnaissance
- `web3-audit` — Web3/smart contract auditing
- `meme-coin-audit` — Cryptocurrency security
- `apk-redteam-pipeline` — Android security testing
- `mid-engagement-ir-detection` — Incident response
- `hunt-subdomain` — Subdomain enumeration
- `hunt-ntlm-info` — NTLM information disclosure
- `hunt-sharepoint` — SharePoint security
- `hunt-dispatch` — Vulnerability dispatch
- `hunt-misc` — Miscellaneous vulnerabilities
- `hunt-ato` — Account takeover techniques
- `hunt-auth-bypass` — Authentication bypass

### Robotics Skills (18)
- `ros-robotics-expert` — ROS development and debugging
- `gps-ins-localization-expert` — GPS/INS sensor fusion
- `fusion-filter-robotics-expert` — Kalman/EKF filters
- `robotics-localization-expert` — SLAM, visual odometry
- `robotics-odometry-expert` — Wheel encoders, IMU integration
- `robotics-data-analyzer` — Sensor data analysis
- `robotics-control-engineer` — Control systems
- `robotics-communication` — Robot communication protocols
- `robotics-manipulator` — Robotic arms and manipulation
- `robotics-path-planning` — Motion planning
- `robotics-simulation-expert` — Simulation and testing
- `robotics-vision-expert` — Computer vision for robotics
- `robotics-field-engineer` — Field deployment
- `robotics-security-auditor` — Robotics security
- `robotics-superpowers` — Robotics skill coordination
- `embedded-networking` — Embedded network protocols
- `network-engineer` — Network configuration
- `wireless-network-expert` — Wireless communication

### Language Skills (11)
- `python-expert` — Python debugging and optimization
- `cpp-expert` — C++ review and best practices
- `cpp-misra-auditor` — C++ MISRA compliance
- `rust-expert` — Rust safety and performance
- `javascript-expert` — JavaScript debugging
- `java-expert` — Java development
- `go-expert` — Go programming
- `matlab-expert` — MATLAB and Simulink
- `web-expert` — Web development
- `hunt-api-misconfig` — API security (language-agnostic)
- `hunt-aspnet` — ASP.NET security

## 🔄 Updates & Maintenance

This is a local integration. To update from upstream repositories:

```bash
# Update from Claude-BugHunter
cd /path/to/Claude-BugHunter
git pull

# Update from robotics-superpowers
cd /path/to/robotics-superpowers
git pull

# Manually sync changes to unified-superpowers
# Review and merge relevant skill updates
```

## 🤝 Contributing

This toolkit is a local integration. For contributions to the original skill repositories:
- **Claude-BugHunter**: [Original Repository](https://github.com/obra/duperpowers)
- **robotics-superpowers**: [Original Repository](https://github.com/RedEarth-Robotics/robotics-superpowers)

## 📄 License

See individual skill directories for their original licenses. This integration maintains the licenses of the source repositories.

## 🔗 Links

- **GitHub**: https://github.com/RedEarth-Robotics/unified-superpowers
- **Issues**: Report issues via GitHub Issues
- **Original Sources**:
  - Claude-BugHunter: Security testing skills
  - robotics-superpowers: Robotics engineering skills

---

**Built for security researchers, robotics engineers, and developers who want comprehensive AI assistance across the entire development lifecycle.**
