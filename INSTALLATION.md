# Installation Guide

This guide covers installing the Unified Superpowers Toolkit using the universal installation script.

## Quick Install

### Universal Installer
```bash
# Cross-platform installer that works on Linux, macOS, and Windows (via Git Bash/WSL)
./scripts/install-universal.sh
```

## Installation Modes

### Interactive Mode (Default)
The installer will prompt you for configuration choices:
- Installation directory
- Dependency checking
- Update existing installations

### Automated Mode
Use the `-y` or `--yes` flag to skip all prompts:
```bash
./scripts/install.sh --yes
```

## Command-Line Options

- `-d, --directory DIR` - Installation directory (default: `./unified-superpowers`)
- `-u, --url URL` - Repository URL
- `-y, --yes` - Automated mode (no prompts)
- `--skip-deps` - Skip dependency checks
- `--no-platforms` - Skip platform-specific installation
- `-v, --verbose` - Verbose output
- `-h, --help` - Show help message

### Examples

**Custom installation directory:**
```bash
./scripts/install-universal.sh -d ~/my-skills
```

**Automated installation with custom URL:**
```bash
./scripts/install-universal.sh -y -u https://github.com/RedEarth-Robotics/unified-superpowers.git
```

**Verbose output for debugging:**
```bash
./scripts/install-universal.sh -v
```

## Platform-Specific Installation

By default, the installer automatically copies skills to platform-specific directories:

### Linux/macOS
- `~/.claude/skills/` - Claude Code skills
- `~/.opencode/skills/` - OpenCode skills
- `~/.devin/skills/` - Devin CLI skills
- `~/.codeium/skills/` - Codeium skills
- `~/.codex/skills/` - Codex skills
- `~/.copilot/skills/` - GitHub Copilot skills
- `~/.cursor/skills/` - Cursor skills

### Windows
- `%USERPROFILE%\.claude\skills\` - Claude Code skills
- `%USERPROFILE%\.opencode\skills\` - OpenCode skills
- `%USERPROFILE%\.devin\skills\` - Devin CLI skills
- `%USERPROFILE%\.codeium\skills\` - Codeium skills
- `%USERPROFILE%\.codex\skills\` - Codex skills
- `%USERPROFILE%\.copilot\skills\` - GitHub Copilot skills
- `%USERPROFILE%\.cursor\skills\` - Cursor skills

### Disabling Platform Installation

To skip platform-specific installation:
```bash
./scripts/install-universal.sh --no-platforms
```

### Platform Installation Behavior
- Platform directories are created if they don't exist
- Skills are copied to `skills/` subdirectory in each platform directory
- On update, existing skills are replaced (full refresh)
- Installation continues even if some platform directories fail
- Errors are logged but don't stop the main installation

## Prerequisites

### Required
- **Git** - Version control system
  - Ubuntu/Debian: `sudo apt-get install git`
  - macOS: `brew install git`
  - Windows: Download from [git-scm.com](https://git-scm.com/)
- **Bash** - Shell environment (pre-installed on Linux/macOS, available via Git Bash on Windows)

## Verification

After installation, verify the setup:

```bash
cd unified-superpowers
find skills -name "SKILL.md" | wc -l
# Should output: 111
```

## Post-Installation Configuration

### Devin CLI
Skills auto-discover from the project root. No additional configuration needed.

### Claude Code
Ensure the `skills/` directory is in your project root. Skills auto-load via Claude Code's skill system.

### Other Platforms
Consult your platform's documentation for skill integration. Most platforms support auto-discovery from `skills/` directories.

## Updating Existing Installation

If you already have the toolkit installed, run the installer again. It will detect the existing installation and offer to update it:

```bash
./scripts/install-universal.sh
# The installer will ask: "Do you want to update the existing installation?"
```

## Troubleshooting

### Git Not Found
**Error:** `git is not installed`

**Solution:** Install git using your system's package manager or download from [git-scm.com](https://git-scm.com/)

### Permission Denied
**Error:** `Permission denied: ./scripts/install-universal.sh`

**Solution:** Make the script executable:
```bash
chmod +x scripts/install-universal.sh
```

### Directory Already Exists
**Error:** `Directory already exists`

**Solution:** The installer will offer to update the existing installation. Choose 'yes' to update or manually remove the directory first.

## Advanced Usage

### Custom Repository
Install from a fork or different repository:
```bash
./scripts/install-universal.sh -u git@github.com:your-username/unified-superpowers.git
```

### System-Wide Installation
Install to a system directory (requires sudo):
```bash
sudo ./scripts/install-universal.sh -d /opt/unified-superpowers
```

### CI/CD Integration
For automated environments, use the automated mode:
```bash
./scripts/install-universal.sh -y -d ./skills --skip-deps
```

## Uninstallation

To remove the toolkit:
```bash
# Remove the installation directory
rm -rf unified-superpowers

# Or if installed to a custom location
rm -rf /path/to/installation
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/RedEarth-Robotics/unified-superpowers/issues
- Check the main README.md for usage examples
- Review individual skill documentation in `skills/*/SKILL.md`
