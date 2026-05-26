#!/usr/bin/env python3
"""
Unified Superpowers Toolkit Installation Script
Cross-platform Python installer with hybrid interactive/automated modes
"""

import os
import sys
import subprocess
import argparse
import shutil
from pathlib import Path

# ANSI color codes for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

class Installer:
    def __init__(self):
        self.repo_url = "git@github.com:RedEarth-Robotics/unified-superpowers.git"
        self.install_dir = Path("./unified-superpowers")
        self.interactive = True
        self.skip_deps = False
        self.verbose = False

    def log_info(self, message):
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

    def log_success(self, message):
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

    def log_warning(self, message):
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

    def log_error(self, message):
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

    def log_verbose(self, message):
        if self.verbose:
            print(f"{Colors.BLUE}[VERBOSE]{Colors.NC} {message}")

    def command_exists(self, command):
        """Check if a command exists on the system"""
        return shutil.which(command) is not None

    def check_dependencies(self):
        """Check if required dependencies are installed"""
        if self.skip_deps:
            self.log_warning("Skipping dependency checks")
            return True

        self.log_info("Checking dependencies...")

        if not self.command_exists('git'):
            self.log_error("git is not installed. Please install git first.")
            self.log_info("On Ubuntu/Debian: sudo apt-get install git")
            self.log_info("On macOS: brew install git")
            self.log_info("On Windows: Download from https://git-scm.com/")
            return False

        self.log_success("All dependencies satisfied")
        return True

    def prompt_yes_no(self, prompt, default=True):
        """Interactive yes/no prompt"""
        if not self.interactive:
            return default

        default_str = "Y/n" if default else "y/N"
        while True:
            response = input(f"{prompt} [{default_str}]: ").strip().lower()
            if not response:
                return default
            if response in ['y', 'yes']:
                return True
            elif response in ['n', 'no']:
                return False
            print("Please answer yes or no.")

    def prompt_directory(self, prompt, default):
        """Interactive directory prompt"""
        if not self.interactive:
            return str(default)

        response = input(f"{prompt} [{default}]: ").strip()
        return response if response else str(default)

    def clone_repository(self):
        """Clone or update the repository"""
        if self.install_dir.exists():
            self.log_warning(f"Directory '{self.install_dir}' already exists")
            if self.prompt_yes_no("Do you want to update the existing installation?", False):
                self.log_info("Updating existing installation...")
                try:
                    subprocess.run(
                        ['git', 'pull', 'origin', 'master'],
                        cwd=self.install_dir,
                        check=True,
                        capture_output=not self.verbose
                    )
                    self.log_success("Installation updated successfully")
                    return True
                except subprocess.CalledProcessError as e:
                    self.log_error(f"Failed to update repository: {e}")
                    return False
            else:
                self.log_info("Installation cancelled by user")
                return False
        else:
            self.log_info(f"Cloning repository from {self.repo_url}...")
            try:
                subprocess.run(
                    ['git', 'clone', self.repo_url, str(self.install_dir)],
                    check=True,
                    capture_output=not self.verbose
                )
                self.log_success("Repository cloned successfully")
                return True
            except subprocess.CalledProcessError as e:
                self.log_error(f"Failed to clone repository: {e}")
                return False

    def verify_installation(self):
        """Verify the installation by counting skills"""
        self.log_info("Verifying installation...")
        
        skill_count = len(list(self.install_dir.glob("skills/**/SKILL.md")))
        
        if skill_count == 95:
            self.log_success(f"Installation verified: {skill_count} skills found")
            return True
        else:
            self.log_warning(f"Expected 95 skills, found {skill_count}")
            return False

    def print_summary(self):
        """Print installation summary"""
        print()
        self.log_success("Installation completed successfully!")
        print()
        print("Installation Summary:")
        print(f"  Location: {self.install_dir.resolve()}")
        print(f"  Skills: {len(list(self.install_dir.glob('skills/**/SKILL.md')))}")
        print(f"  Repository: {self.repo_url}")
        print()
        print("Next Steps:")
        print("  1. Configure your AI assistant to use the skills/ directory")
        print("  2. Skills will auto-discover based on your platform")
        print("  3. Check README.md for usage examples")
        print()

    def install(self):
        """Main installation process"""
        print("=" * 42)
        print("Unified Superpowers Toolkit Installer")
        print("=" * 42)
        print()

        # Interactive mode prompts
        if self.interactive:
            install_dir_str = self.prompt_directory(
                "Installation directory",
                self.install_dir
            )
            self.install_dir = Path(install_dir_str)

            if self.prompt_yes_no("Check for required dependencies?", True):
                if not self.check_dependencies():
                    return False
        else:
            if not self.check_dependencies():
                return False

        # Clone repository
        if not self.clone_repository():
            return False

        # Verify installation
        self.verify_installation()

        # Print summary
        self.print_summary()
        return True

def main():
    parser = argparse.ArgumentParser(
        description="Install Unified Superpowers Toolkit"
    )
    parser.add_argument(
        '-d', '--directory',
        default='./unified-superpowers',
        help='Installation directory (default: ./unified-superpowers)'
    )
    parser.add_argument(
        '-u', '--url',
        default='git@github.com:RedEarth-Robotics/unified-superpowers.git',
        help='Repository URL'
    )
    parser.add_argument(
        '-y', '--yes',
        action='store_true',
        help='Automated mode (no prompts)'
    )
    parser.add_argument(
        '--skip-deps',
        action='store_true',
        help='Skip dependency checks'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )

    args = parser.parse_args()

    installer = Installer()
    installer.install_dir = Path(args.directory)
    installer.repo_url = args.url
    installer.interactive = not args.yes
    installer.skip_deps = args.skip_deps
    installer.verbose = args.verbose

    success = installer.install()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
