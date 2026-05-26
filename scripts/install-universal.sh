#!/bin/bash
# Universal Installation Script
# Auto-detects platform and runs appropriate installer

set -e

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM="linux";;
        Darwin*)    PLATFORM="macos";;
        CYGWIN*)    PLATFORM="windows";;
        MINGW*)     PLATFORM="windows";;
        MSYS*)      PLATFORM="windows";;
        *)          PLATFORM="unknown";;
    esac
    echo "$PLATFORM"
}

# Check if Python is available
check_python() {
    if command -v python3 &> /dev/null; then
        echo "python3"
    elif command -v python &> /dev/null; then
        echo "python"
    else
        echo ""
    fi
}

# Main execution
main() {
    PLATFORM=$(detect_platform)
    PYTHON=$(check_python)

    echo "Detected platform: $PLATFORM"

    # Try Python script first (most universal)
    if [ -n "$PYTHON" ]; then
        echo "Using Python installer..."
        exec "$PYTHON" "$(dirname "$0")/install.py" "$@"
    fi

    # Fall back to platform-specific scripts
    case "$PLATFORM" in
        linux|macos)
            if [ -f "$(dirname "$0")/install.sh" ]; then
                echo "Using Bash installer..."
                exec "$(dirname "$0")/install.sh" "$@"
            else
                echo "Error: No suitable installer found for this platform"
                exit 1
            fi
            ;;
        windows)
            if command -v powershell &> /dev/null; then
                echo "Using PowerShell installer..."
                powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/install.ps1" "$@"
            else
                echo "Error: PowerShell not found"
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown platform: $PLATFORM"
            exit 1
            ;;
    esac
}

main "$@"
