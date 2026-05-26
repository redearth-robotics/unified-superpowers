# Unified Superpowers Toolkit

A comprehensive, locally-maintained skill integration combining **security testing** (Claude-BugHunter) and **robotics engineering** (robotics-superpowers) capabilities.

## Origin

This toolkit merges two skill repositories:
- **Claude-BugHunter** (48 skills): Bug bounty methodology, vulnerability hunting, security reporting
- **robotics-superpowers** (47 skills): Robotics localization, sensor fusion, ROS, embedded systems

## Structure

```
skills/
├── core/              # General-purpose process skills (14 skills)
│   ├── brainstorming
│   ├── systematic-debugging
│   ├── test-driven-development
│   ├── token-optimizer
│   ├── using-superpowers
│   └── ...
├── security/          # Security testing & bug bounty (52 skills)
│   ├── bug-bounty
│   ├── hunt-xss
│   ├── hunt-sqli
│   ├── security-pentester
│   └── ...
├── robotics/          # Robotics & embedded systems (18 skills)
│   ├── ros-robotics-expert
│   ├── gps-ins-localization-expert
│   ├── fusion-filter-robotics-expert
│   └── ...
└── languages/         # Programming language expertise (11 skills)
    ├── cpp-expert
    ├── python-expert
    ├── rust-expert
    └── ...
```

## Skill Count

| Domain | Count |
|--------|-------|
| Core Process | 14 |
| Security | 52 |
| Robotics | 18 |
| Languages | 11 |
| **Total** | **95** |

## Usage

Skills auto-trigger based on user queries. Each skill contains:
- Trigger phrases (what user says to activate it)
- Detailed methodology and instructions
- Code examples and tool references
- Decision frameworks and quality checklists

## Merged Skills

The `security/security-pentester` skill is a merged version combining:
- **robotics-superpowers**: General pentesting methodology, ethical boundaries, output format
- **Claude-BugHunter**: Specific vulnerability payloads, bypass tables, wordlists

## Maintenance

This is a local integration. Updates from upstream repositories must be manually synchronized.

## License

See individual skill directories for their original licenses.
