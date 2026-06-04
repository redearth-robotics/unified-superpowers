#!/usr/bin/env bash
# ============================================================
#  Unified Superpowers Script Manager
#  Interactive menu for managing all project scripts
#
#  Usage: bash scripts-manager.sh [options]
#
#  Options:
#    --dry-run                Preview actions without executing
#    -h, --help               Show this help
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "${GREEN}✔ $*${RESET}"; }
info() { echo -e "${CYAN}→ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $*${RESET}"; }
err()  { echo -e "${RED}✖ $*${RESET}" >&2; }
step() { echo -e "\n${BOLD}${BLUE}══ $* ${RESET}"; }
dry()  { echo -e "${YELLOW}[DRY-RUN]${RESET} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# State file for remembering options
STATE_FILE="${HOME}/.config/unified-superpowers/scripts-manager.state"
mkdir -p "$(dirname "$STATE_FILE")"

discover_scripts() {
  local category="$1"
  local scripts=()
  
  case "$category" in
    installation)
      for script in install.sh install.ps1 install.py install-universal.sh; do
        [[ -f "$SCRIPT_DIR/$script" ]] && scripts+=("$script")
      done
      ;;
    utilities)
      for script in backup-restore-ai-configs.sh run-benchmark.sh; do
        [[ -f "$SCRIPT_DIR/$script" ]] && scripts+=("$script")
      done
      ;;
    setup)
      for script in maintain-stack.sh setup-global-token-rules.sh setup-token-optimizer.sh; do
        [[ -f "$SCRIPT_DIR/$script" ]] && scripts+=("$script")
      done
      ;;
    mcp)
      [[ -f "$SCRIPT_DIR/install-mcp-stack.sh" ]] && scripts+=("install-mcp-stack.sh")
      ;;
  esac
  
  echo "${scripts[@]}"
}

validate_script() {
  local script="$1"
  local path="$SCRIPT_DIR/$script"
  
  if [[ ! -f "$path" ]]; then
    err "Script not found: $script"
    return 1
  fi
  
  if [[ ! -x "$path" && "$script" == *.sh ]]; then
    warn "Script not executable: $script"
    read -rp "Make executable? [y/N] " answer
    [[ "$answer" == "y" || "$answer" == "Y" ]] && chmod +x "$path"
  fi
  
  return 0
}

show_main_menu() {
  echo -e "\n${BOLD}=== Unified Superpowers Script Manager ===${RESET}\n"
  echo "1. Installation           — Install unified-superpowers"
  echo "2. Utilities & Tools      — Backup, restore, benchmark"
  echo "3. Setup & Configuration  — Token rules, stack maintenance"
  echo "4. MCP Stack             — Install MCP/token optimization stack"
  echo "5. Run Custom Script      — Browse and execute any script"
  echo "6. Help & Documentation   — Show README and script info"
  echo "q. Quit"
  echo ""
}

show_submenu() {
  local category="$1"
  local title="$2"
  local scripts
  scripts=($(discover_scripts "$category"))
  
  echo -e "\n${BOLD}=== $title ===${RESET}\n"
  
  if [[ ${#scripts[@]} -eq 0 ]]; then
    warn "No scripts found in this category"
    return 1
  fi
  
  local i=1
  for script in "${scripts[@]}"; do
    echo "  [$i] $script"
    ((i++))
  done
  
  echo ""
  echo "  [b] Back to main menu"
  echo ""
}

show_script_help() {
  local script="$1"
  local path="$SCRIPT_DIR/$script"
  
  echo -e "\n${BOLD}=== $script ===${RESET}\n"
  
  if [[ ! -f "$path" ]]; then
    err "Script not found"
    return 1
  fi
  
  # Show first 20 lines (usually contains help header)
  head -20 "$path" | sed 's/^# //' | sed '/^#!/d'
  echo ""
  
  # Check for --help support
  if grep -q '\-\-help' "$path"; then
    info "Run '$script --help' for full usage information"
  fi
}

run_script() {
  local script="$1"
  shift
  local args="$@"
  local path="$SCRIPT_DIR/$script"
  
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would execute: $path $args"
    return 0
  fi
  
  if ! validate_script "$script"; then
    return 1
  fi
  
  step "Running $script"
  
  if [[ "$script" == *.py ]]; then
    python3 "$path" $args
  elif [[ "$script" == *.ps1 ]]; then
    pwsh "$path" $args
  else
    bash "$path" $args
  fi
}

main() {
  while true; do
    show_main_menu
    read -rp "Selection: " choice
    
    case "$choice" in
      1)
        # Installation submenu
        while true; do
          show_submenu "installation" "Installation"
          read -rp "Select script [1-N, b=back]: " subchoice
          
          [[ "$subchoice" == "b" ]] && break
          
          scripts=($(discover_scripts "installation"))
          if [[ "$subchoice" =~ ^[0-9]+$ && "$subchoice" -ge 1 && "$subchoice" -le ${#scripts[@]} ]]; then
            run_script "${scripts[$((subchoice-1))]}"
          else
            err "Invalid selection"
          fi
        done
        ;;
      
      2)
        # Utilities submenu
        while true; do
          show_submenu "utilities" "Utilities & Tools"
          read -rp "Select script [1-N, b=back]: " subchoice
          
          [[ "$subchoice" == "b" ]] && break
          
          scripts=($(discover_scripts "utilities"))
          if [[ "$subchoice" =~ ^[0-9]+$ && "$subchoice" -ge 1 && "$subchoice" -le ${#scripts[@]} ]]; then
            run_script "${scripts[$((subchoice-1))]}"
          else
            err "Invalid selection"
          fi
        done
        ;;
      
      3)
        # Setup submenu
        while true; do
          show_submenu "setup" "Setup & Configuration"
          read -rp "Select script [1-N, b=back]: " subchoice
          
          [[ "$subchoice" == "b" ]] && break
          
          scripts=($(discover_scripts "setup"))
          if [[ "$subchoice" =~ ^[0-9]+$ && "$subchoice" -ge 1 && "$subchoice" -le ${#scripts[@]} ]]; then
            run_script "${scripts[$((subchoice-1))]}"
          else
            err "Invalid selection"
          fi
        done
        ;;
      
      4)
        # MCP Stack
        if [[ -f "$SCRIPT_DIR/install-mcp-stack.sh" ]]; then
          run_script "install-mcp-stack.sh"
        else
          err "install-mcp-stack.sh not found. Install MCP stack first."
        fi
        ;;
      
      5)
        # Run custom script
        echo -e "\n${BOLD}Available scripts:${RESET}"
        ls -1 "$SCRIPT_DIR" | grep -E '\.(sh|py|ps1)$' | nl
        echo ""
        read -rp "Enter script name (or number): " script_name
        
        # If numeric, map to filename
        if [[ "$script_name" =~ ^[0-9]+$ ]]; then
          script_name=$(ls -1 "$SCRIPT_DIR" | grep -E '\.(sh|py|ps1)$' | sed -n "${script_name}p")
        fi
        
        read -rp "Arguments (optional): " args
        run_script "$script_name" $args
        ;;
      
      6)
        # Help & Documentation
        echo -e "\n${BOLD}=== Help & Documentation ===${RESET}\n"
        echo "1. View scripts README"
        echo "2. List all scripts with descriptions"
        echo "3. View specific script help"
        echo "b. Back"
        echo ""
        read -rp "Selection: " help_choice
        
        case "$help_choice" in
          1)
            if [[ -f "$SCRIPT_DIR/README.md" ]]; then
              cat "$SCRIPT_DIR/README.md"
            else
              warn "README.md not found"
            fi
            ;;
          2)
            for script in $(ls -1 "$SCRIPT_DIR" | grep -E '\.(sh|py|ps1)$'); do
              printf "%-40s " "$script"
              # Extract description from header comment
              head -5 "$SCRIPT_DIR/$script" | grep -oP '(?<=#  ).*' | head -1
            done
            ;;
          3)
            read -rp "Script name: " script_name
            show_script_help "$script_name"
            ;;
        esac
        ;;
      
      q|quit|exit)
        info "Goodbye!"
        exit 0
        ;;
      
      *)
        err "Invalid selection: $choice"
        ;;
    esac
  done
}

main "$@"
