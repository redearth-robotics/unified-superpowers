#!/bin/bash
# Universal Installation Script
# Auto-detects platform and runs appropriate installer

set -e

# Parse arguments
SKIP_DEPS=false
NO_PLATFORMS=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --no-platforms)
            NO_PLATFORMS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            # Pass other arguments to the installer
            break
            ;;
    esac
done

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
        ARGS=""
        [ "$SKIP_DEPS" = true ] && ARGS="$ARGS --skip-deps"
        [ "$NO_PLATFORMS" = true ] && ARGS="$ARGS --no-platforms"
        [ "$VERBOSE" = true ] && ARGS="$ARGS --verbose"
        exec "$PYTHON" "$(dirname "$0")/install.py" $ARGS "$@"
    fi

    # Fall back to platform-specific scripts
    case "$PLATFORM" in
        linux|macos)
            if [ -f "$(dirname "$0")/install.sh" ]; then
                echo "Using Bash installer..."
                ARGS=""
                [ "$SKIP_DEPS" = true ] && ARGS="$ARGS --skip-deps"
                [ "$NO_PLATFORMS" = true ] && ARGS="$ARGS --no-platforms"
                [ "$VERBOSE" = true ] && ARGS="$ARGS --verbose"
                exec "$(dirname "$0")/install.sh" $ARGS "$@"
            else
                echo "Error: No suitable installer found for this platform"
                exit 1
            fi
            ;;
        windows)
            if command -v powershell &> /dev/null; then
                echo "Using PowerShell installer..."
                ARGS=""
                [ "$SKIP_DEPS" = true ] && ARGS="$ARGS -SkipDeps"
                [ "$NO_PLATFORMS" = true ] && ARGS="$ARGS -NoPlatforms"
                [ "$VERBOSE" = true ] && ARGS="$ARGS -Verbose"
                powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/install.ps1" $ARGS "$@"
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
