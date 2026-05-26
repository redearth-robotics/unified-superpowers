#!/bin/bash

# Unified Superpowers Toolkit Installation Script
# Supports Linux/macOS with hybrid interactive/automated modes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
REPO_URL="git@github.com:RedEarth-Robotics/unified-superpowers.git"
INSTALL_DIR="./unified-superpowers"
INTERACTIVE=true
SKIP_DEPENDENCIES=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -u|--url)
            REPO_URL="$2"
            shift 2
            ;;
        -y|--yes)
            INTERACTIVE=false
            shift
            ;;
        --skip-deps)
            SKIP_DEPENDENCIES=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --directory DIR    Installation directory (default: ./unified-superpowers)"
            echo "  -u, --url URL          Repository URL (default: git@github.com:RedEarth-Robotics/unified-superpowers.git)"
            echo "  -y, --yes              Automated mode (no prompts)"
            echo "  --skip-deps           Skip dependency checks"
            echo "  -v, --verbose          Verbose output"
            echo "  -h, --help             Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verbose logging
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    if [ "$SKIP_DEPENDENCIES" = true ]; then
        log_warning "Skipping dependency checks"
        return 0
    fi

    log_info "Checking dependencies..."

    if ! command_exists git; then
        log_error "git is not installed. Please install git first."
        log_info "On Ubuntu/Debian: sudo apt-get install git"
        log_info "On macOS: brew install git"
        exit 1
    fi

    log_success "All dependencies satisfied"
}

# Interactive prompts
prompt_yes_no() {
    local prompt="$1"
    local default="$2"
    
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi

    while true; do
        read -p "$prompt [$default] " response
        response=${response:-$default}
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

prompt_directory() {
    local prompt="$1"
    local default="$2"
    
    if [ "$INTERACTIVE" = false ]; then
        echo "$default"
        return
    fi

    read -p "$prompt [$default] " response
    echo "${response:-$default}"
}

# Main installation
install_toolkit() {
    log_info "Starting Unified Superpowers Toolkit installation..."
    
    # Check if directory already exists
    if [ -d "$INSTALL_DIR" ]; then
        log_warning "Directory '$INSTALL_DIR' already exists"
        if prompt_yes_no "Do you want to update the existing installation?" "n"; then
            log_info "Updating existing installation..."
            cd "$INSTALL_DIR"
            git pull origin master
            log_success "Installation updated successfully"
        else
            log_info "Installation cancelled by user"
            exit 0
        fi
    else
        # Clone repository
        log_info "Cloning repository from $REPO_URL..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        
        if [ $? -ne 0 ]; then
            log_error "Failed to clone repository"
            exit 1
        fi
        
        log_success "Repository cloned successfully"
    fi

    # Verify installation
    cd "$INSTALL_DIR"
    SKILL_COUNT=$(find skills -name "SKILL.md" 2>/dev/null | wc -l)
    
    if [ "$SKILL_COUNT" -eq 95 ]; then
        log_success "Installation verified: $SKILL_COUNT skills found"
    else
        log_warning "Expected 95 skills, found $SKILL_COUNT"
    fi

    # Show summary
    echo ""
    log_success "Installation completed successfully!"
    echo ""
    echo "Installation Summary:"
    echo "  Location: $(pwd)"
    echo "  Skills: $SKILL_COUNT"
    echo "  Repository: $REPO_URL"
    echo ""
    echo "Next Steps:"
    echo "  1. Configure your AI assistant to use the skills/ directory"
    echo "  2. Skills will auto-discover based on your platform"
    echo "  3. Check README.md for usage examples"
    echo ""
}

# Main execution
main() {
    echo "=========================================="
    echo "Unified Superpowers Toolkit Installer"
    echo "=========================================="
    echo ""

    # Interactive mode prompts
    if [ "$INTERACTIVE" = true ]; then
        INSTALL_DIR=$(prompt_directory "Installation directory" "$INSTALL_DIR")
        
        if prompt_yes_no "Check for required dependencies?" "y"; then
            check_dependencies
        fi
    else
        check_dependencies
    fi

    # Perform installation
    install_toolkit
}

# Run main function
main
