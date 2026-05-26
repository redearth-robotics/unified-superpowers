# Installation Guide

This guide covers installing the Unified Superpowers Toolkit using the provided installation scripts.

## Quick Install

### Universal Installer (Recommended)
```bash
# Auto-detects platform and runs appropriate installer
./scripts/install-universal.sh
```

### Platform-Specific Installers

**Linux/macOS:**
```bash
./scripts/install.sh
```

**Windows:**
```powershell
.\scripts\install.ps1
```

**Cross-platform (Python):**
```bash
python3 scripts/install.py
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

### Common Options (All Platforms)
- `-d, --directory DIR` - Installation directory (default: `./unified-superpowers`)
- `-u, --url URL` - Repository URL
- `-y, --yes` - Automated mode (no prompts)
- `--skip-deps` - Skip dependency checks
- `-v, --verbose` - Verbose output
- `-h, --help` - Show help message

### Examples

**Custom installation directory:**
```bash
./scripts/install.sh -d ~/my-skills
```

**Automated installation with custom URL:**
```bash
./scripts/install.sh -y -u https://github.com/RedEarth-Robotics/unified-superpowers.git
```

**Verbose output for debugging:**
```bash
./scripts/install.sh -v
```

## Platform-Specific Details

### Linux/macOS (Bash)
```bash
# Basic installation
./scripts/install.sh

# Automated mode
./scripts/install.sh --yes

# Custom directory
./scripts/install.sh -d /opt/unified-superpowers

# Skip dependency checks
./scripts/install.sh --skip-deps
```

### Windows (PowerShell)
```powershell
# Basic installation
.\scripts\install.ps1

# Automated mode
.\scripts\install.ps1 -Yes

# Custom directory
.\scripts\install.ps1 -Directory "C:\Skills\unified-superpowers"

# Skip dependency checks
.\scripts\install.ps1 -SkipDeps
```

### Cross-Platform (Python)
```bash
# Basic installation
python3 scripts/install.py

# Automated mode
python3 scripts/install.py --yes

# Custom directory
python3 scripts/install.py -d ~/my-skills

# Skip dependency checks
python3 scripts/install.py --skip-deps
```

## Prerequisites

### Required
- **Git** - Version control system
  - Ubuntu/Debian: `sudo apt-get install git`
  - macOS: `brew install git`
  - Windows: Download from [git-scm.com](https://git-scm.com/)

### Optional
- **Python 3** - For Python installer (version 3.6+)
- **PowerShell** - For Windows installer (usually pre-installed)

## Verification

After installation, verify the setup:

```bash
cd unified-superpowers
find skills -name "SKILL.md" | wc -l
# Should output: 95
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
./scripts/install.sh
# The installer will ask: "Do you want to update the existing installation?"
```

## Troubleshooting

### Git Not Found
**Error:** `git is not installed`

**Solution:** Install git using your system's package manager or download from [git-scm.com](https://git-scm.com/)

### Permission Denied
**Error:** `Permission denied: ./scripts/install.sh`

**Solution:** Make the script executable:
```bash
chmod +x scripts/install.sh
```

### PowerShell Execution Policy
**Error:** `cannot be loaded because running scripts is disabled`

**Solution:** Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Directory Already Exists
**Error:** `Directory already exists`

**Solution:** The installer will offer to update the existing installation. Choose 'yes' to update or manually remove the directory first.

## Advanced Usage

### Custom Repository
Install from a fork or different repository:
```bash
./scripts/install.sh -u git@github.com:your-username/unified-superpowers.git
```

### System-Wide Installation
Install to a system directory (requires sudo):
```bash
sudo ./scripts/install.sh -d /opt/unified-superpowers
```

### CI/CD Integration
For automated environments, use the automated mode:
```bash
./scripts/install.sh -y -d ./skills --skip-deps
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
