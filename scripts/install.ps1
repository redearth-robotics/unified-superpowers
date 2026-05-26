# Unified Superpowers Toolkit Installation Script
# PowerShell installer for Windows with hybrid interactive/automated modes

param(
    [string]$Directory = ".\unified-superpowers",
    [string]$Url = "git@github.com:RedEarth-Robotics/unified-superpowers.git",
    [switch]$Yes,
    [switch]$SkipDeps,
    [switch]$Verbose
)

# Color functions
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Info {
    Write-ColorOutput Cyan "[INFO] $args"
}

function Write-Success {
    Write-ColorOutput Green "[SUCCESS] $args"
}

function Write-Warning {
    Write-ColorOutput Yellow "[WARNING] $args"
}

function Write-Error {
    Write-ColorOutput Red "[ERROR] $args"
}

function Write-Verbose {
    if ($Verbose) {
        Write-ColorOutput Cyan "[VERBOSE] $args"
    }
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check dependencies
function Test-Dependencies {
    if ($SkipDeps) {
        Write-Warning "Skipping dependency checks"
        return $true
    }

    Write-Info "Checking dependencies..."

    if (-not (Test-Command "git")) {
        Write-Error "git is not installed. Please install git first."
        Write-Info "Download from: https://git-scm.com/"
        return $false
    }

    Write-Success "All dependencies satisfied"
    return $true
}

# Interactive prompts
function Test-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )

    if ($Yes) {
        return $true
    }

    $defaultStr = if ($Default) { "Y/n" } else { "y/N" }
    while ($true) {
        $response = Read-Host "$Prompt [$defaultStr]"
        $response = $response.Trim().ToLower()
        
        if ([string]::IsNullOrEmpty($response)) {
            return $Default
        }
        
        if ($response -in @('y', 'yes')) {
            return $true
        }
        elseif ($response -in @('n', 'no')) {
            return $false
        }
        else {
            Write-Host "Please answer yes or no."
        }
    }
}

function Get-Directory {
    param(
        [string]$Prompt,
        [string]$Default
    )

    if ($Yes) {
        return $Default
    }

    $response = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrEmpty($response)) {
        return $Default
    }
    return $response
}

# Clone or update repository
function Install-Toolkit {
    Write-Info "Starting Unified Superpowers Toolkit installation..."

    # Check if directory exists
    if (Test-Path $Directory) {
        Write-Warning "Directory '$Directory' already exists"
        if (Test-YesNo "Do you want to update the existing installation?" $false) {
            Write-Info "Updating existing installation..."
            Push-Location $Directory
            try {
                git pull origin master
                Write-Success "Installation updated successfully"
                return $true
            }
            catch {
                Write-Error "Failed to update repository: $_"
                return $false
            }
            finally {
                Pop-Location
            }
        }
        else {
            Write-Info "Installation cancelled by user"
            return $false
        }
    }
    else {
        # Clone repository
        Write-Info "Cloning repository from $Url..."
        try {
            git clone $Url $Directory
            Write-Success "Repository cloned successfully"
        }
        catch {
            Write-Error "Failed to clone repository: $_"
            return $false
        }
    }

    # Verify installation
    Push-Location $Directory
    try {
        $skillCount = (Get-ChildItem -Path "skills" -Filter "SKILL.md" -Recurse).Count
        
        if ($skillCount -eq 95) {
            Write-Success "Installation verified: $skillCount skills found"
        }
        else {
            Write-Warning "Expected 95 skills, found $skillCount"
        }
    }
    finally {
        Pop-Location
    }

    # Show summary
    Write-Host ""
    Write-Success "Installation completed successfully!"
    Write-Host ""
    Write-Host "Installation Summary:"
    Write-Host "  Location: $((Resolve-Path $Directory).Path)"
    Write-Host "  Skills: $skillCount"
    Write-Host "  Repository: $Url"
    Write-Host ""
    Write-Host "Next Steps:"
    Write-Host "  1. Configure your AI assistant to use the skills/ directory"
    Write-Host "  2. Skills will auto-discover based on your platform"
    Write-Host "  3. Check README.md for usage examples"
    Write-Host ""

    return $true
}

# Main execution
function Main {
    Write-Host "=" * 42
    Write-Host "Unified Superpowers Toolkit Installer"
    Write-Host "=" * 42
    Write-Host ""

    # Interactive mode prompts
    if (-not $Yes) {
        $Directory = Get-Directory "Installation directory" $Directory
        
        if (Test-YesNo "Check for required dependencies?" $true) {
            if (-not (Test-Dependencies)) {
                exit 1
            }
        }
    }
    else {
        if (-not (Test-Dependencies)) {
            exit 1
        }
    }

    # Perform installation
    $success = Install-Toolkit
    exit (if ($success) { 0 } else { 1 })
}

# Run main function
Main
