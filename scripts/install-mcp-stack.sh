#!/usr/bin/env bash
# ============================================================
#  MCP Stack Installer — Unified Token Optimization Setup
#  Interactive menu for installing DCP, MCP servers, tools, and config
#
#  Usage: bash install-mcp-stack.sh [options]
#
#  Options:
#    --dry-run                Preview changes without applying
#    --minimal                Install only core stack
#    --full                   Install everything (default)
#    --skip-checks            Skip dependency verification
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

require() { command -v "$1" &>/dev/null || { err "Required: '$1' not found."; exit 1; }; }

# Check if running in dry-run mode
DRY_RUN=false
MINIMAL=false
FULL=false
SKIP_CHECKS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)     DRY_RUN=true; shift ;;
    --minimal)     MINIMAL=true; shift ;;
    --full)        FULL=true; shift ;;
    --skip-checks) SKIP_CHECKS=true; shift ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# Default to full if neither minimal nor full specified
[[ "$MINIMAL" == false && "$FULL" == false ]] && FULL=true

check_dependencies() {
  step "Checking Dependencies"
  
  if [[ "$SKIP_CHECKS" == true ]]; then
    warn "Skipping dependency checks (--skip-checks)"
    return 0
  fi
  
  require node
  require npm
  require python3
  
  # Check node version (need 18+)
  NODE_VERSION=$(node --version | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [[ "$NODE_MAJOR" -lt 18 ]]; then
    err "Node.js 18+ required, found $NODE_VERSION"
    exit 1
  fi
  ok "Node.js $NODE_VERSION"
  
  # Check npm version
  NPM_VERSION=$(npm --version)
  ok "npm $NPM_VERSION"
  
  ok "All dependencies satisfied"
}

# Core stack components
CORE_COMPONENTS=(
  "dcp|Dynamic Context Pruning|ON"
  "skills|Skills Framework (lazy loading)|ON"
  "conductor|Conductor (lifecycle scoping)|ON"
  "lcm|LCM (lossless context memory)|ON"
)

MCP_SERVERS=(
  "code-review-graph|code-review-graph (tree-sitter MCP)|ON"
)

TOOLS=(
  "rtk|RTK (CLI output compression)|ON"
  "graphify|graphify (knowledge graph queries)|ON"
)

CONFIGS=(
  "agents|Global AGENTS.md rules|ON"
  "autoinit|Auto-init plugin|ON"
  "dcp-config|DCP compression thresholds|ON"
)

# Combined ordered array for number-based access
ALL_COMPONENTS=(
  "${CORE_COMPONENTS[@]}"
  "${MCP_SERVERS[@]}"
  "${TOOLS[@]}"
  "${CONFIGS[@]}"
)

# Get component key by 1-based index
get_component_key_by_index() {
  local idx="$1"
  local i=1
  for item in "${ALL_COMPONENTS[@]}"; do
    if [[ "$i" -eq "$idx" ]]; then
      echo "$item" | cut -d'|' -f1
      return 0
    fi
    ((i++))
  done
  return 1
}

# Get component description by 1-based index
get_component_desc_by_index() {
  local idx="$1"
  local i=1
  for item in "${ALL_COMPONENTS[@]}"; do
    if [[ "$i" -eq "$idx" ]]; then
      echo "$item" | cut -d'|' -f2
      return 0
    fi
    ((i++))
  done
  return 1
}

show_menu() {
  echo -e "\n${BOLD}=== MCP Stack Installer ===${RESET}"
  echo "Select components to install:"
  echo ""
  
  echo -e "${BOLD}[1] Core Stack${RESET}"
  local i=1
  for item in "${CORE_COMPONENTS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  
  echo ""
  echo -e "${BOLD}[2] MCP Servers${RESET}"
  for item in "${MCP_SERVERS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  
  echo ""
  echo -e "${BOLD}[3] Tools & Utilities${RESET}"
  for item in "${TOOLS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  
  echo ""
  echo -e "${BOLD}[4] Configuration${RESET}"
  for item in "${CONFIGS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  
  echo ""
  echo "Enter numbers to toggle (comma-separated), or:"
  echo "  'all'  — select everything"
  echo "  'none' — select nothing"
  echo "  'done' — proceed with installation"
  echo "  'q'    — quit"
}

install_dcp() {
  step "Installing Dynamic Context Pruning (DCP)"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install @tarquinen/opencode-dcp"
    return 0
  fi
  info "Installing @tarquinen/opencode-dcp..."
  npm install -g @tarquinen/opencode-dcp
  ok "DCP installed"
}

install_skills_framework() {
  step "Installing Skills Framework"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install @zenobius/opencode-skillful"
    return 0
  fi
  info "Installing @zenobius/opencode-skillful..."
  npm install -g @zenobius/opencode-skillful
  ok "Skills framework installed"
}

install_conductor() {
  step "Installing Conductor"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install opencode-conductor"
    return 0
  fi
  info "Installing opencode-conductor..."
  npm install -g opencode-conductor
  ok "Conductor installed"
}

install_lcm() {
  step "Installing LCM (Lossless Context Memory)"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install opencode-lcm"
    return 0
  fi
  info "Installing opencode-lcm..."
  npm install -g opencode-lcm
  ok "LCM installed"
}

install_code_review_graph() {
  step "Installing code-review-graph MCP"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install code-review-graph MCP server"
    return 0
  fi
  info "Installing code-review-graph..."
  npm install -g code-review-graph
  ok "code-review-graph installed"
}

install_rtk() {
  step "Installing RTK (CLI output compression)"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install RTK"
    return 0
  fi
  info "Installing RTK..."
  npm install -g rtk
  ok "RTK installed"
}

install_graphify() {
  step "Installing graphify"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install graphify CLI"
    return 0
  fi
  info "Installing graphify..."
  npm install -g graphify
  ok "graphify installed"
}

install_agents_rules() {
  step "Installing Global AGENTS.md"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would create ~/.config/opencode/AGENTS.md"
    return 0
  fi
  
  local config_dir="${HOME}/.config/opencode"
  mkdir -p "$config_dir"
  
  cat > "$config_dir/AGENTS.md" << 'EOF'
# Global Rules

## MCP First
- Use `code-review-graph` tools before grep/file reads

## File Reading
- AST summaries over full file reads

## Edit Format
- Unified diffs only, no full rewrites

## DCP Awareness
- Let DCP auto-prune; don't fight it

## Delegation
- Use agents for cheap parallel work
EOF
  ok "Global AGENTS.md created at $config_dir/AGENTS.md"
}

install_autoinit() {
  step "Installing Auto-init Plugin"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would create ~/.config/opencode/plugin/auto-init.js"
    return 0
  fi
  
  local plugin_dir="${HOME}/.config/opencode/plugin"
  mkdir -p "$plugin_dir"
  
  cat > "$plugin_dir/auto-init.js" << 'EOF'
// Auto-init: session bootstrap
module.exports = {
  onSessionCreated: (ctx) => {
    console.log("[auto-init] Session started — loading context...");
    // Add any startup logic here
  },
  onSessionIdle: (ctx) => {
    // Auto-store file edits
  }
};
EOF
  ok "Auto-init plugin created"
}

install_dcp_config() {
  step "Configuring DCP Thresholds"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would create ~/.config/opencode/dcp.jsonc"
    return 0
  fi
  
  local config_dir="${HOME}/.config/opencode"
  mkdir -p "$config_dir"
  
  cat > "$config_dir/dcp.jsonc" << 'EOF'
{
  "compress": {
    "maxContextLimit": 80000,
    "minContextLimit": 40000,
    "nudgeFrequency": 4,
    "nudgeForce": "strong",
    "iterationNudgeThreshold": 10
  }
}
EOF
  ok "DCP config created"
}

main() {
  step "MCP Stack Installer"
  
  check_dependencies
  
  # If minimal mode, skip menu and install core only
  if [[ "$MINIMAL" == true ]]; then
    info "Minimal mode — installing core stack only"
    install_dcp
    install_skills_framework
    install_conductor
    install_lcm
    ok "Core stack installation complete"
    exit 0
  fi
  
  # Interactive menu for full mode
  declare -A SELECTED
  
  # Initialize all to "ON"
  for item in "${CORE_COMPONENTS[@]}" "${MCP_SERVERS[@]}" "${TOOLS[@]}" "${CONFIGS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    SELECTED[$key]="ON"
  done
  
  while true; do
    show_menu
    
    read -rp "Selection: " choice
    
    case "$choice" in
      q|quit)
        info "Exiting without changes"
        exit 0
        ;;
      all)
        for key in "${!SELECTED[@]}"; do
          SELECTED[$key]="ON"
        done
        ok "All components selected"
        ;;
      none)
        for key in "${!SELECTED[@]}"; do
          SELECTED[$key]="OFF"
        done
        ok "All components deselected"
        ;;
      done)
        break
        ;;
      *)
        # Toggle specific items by number
        IFS=',' read -ra nums <<< "$choice"
        for num in "${nums[@]}"; do
          num=$(echo "$num" | tr -d ' ')
          # Validate number
          if ! [[ "$num" =~ ^[0-9]+$ ]]; then
            warn "Invalid input: '$num' — use numbers, 'all', 'none', 'done', or 'q'"
            continue
          fi
          
          local key
          key=$(get_component_key_by_index "$num" 2>/dev/null) || {
            warn "Invalid number: $num (valid range: 1-${#ALL_COMPONENTS[@]})"
            continue
          }
          
          local desc
          desc=$(get_component_desc_by_index "$num" 2>/dev/null) || desc="Unknown"
          
          # Toggle state
          if [[ "${SELECTED[$key]}" == "ON" ]]; then
            SELECTED[$key]="OFF"
            info "[$num] $desc → OFF"
          else
            SELECTED[$key]="ON"
            ok "[$num] $desc → ON"
          fi
        done
        ;;
    esac
  done
  
  # Install selected components
  step "Installing Selected Components"
  
  [[ "${SELECTED[dcp]}" == "ON" ]] && install_dcp
  [[ "${SELECTED[skills]}" == "ON" ]] && install_skills_framework
  [[ "${SELECTED[conductor]}" == "ON" ]] && install_conductor
  [[ "${SELECTED[lcm]}" == "ON" ]] && install_lcm
  [[ "${SELECTED[code-review-graph]}" == "ON" ]] && install_code_review_graph
  [[ "${SELECTED[rtk]}" == "ON" ]] && install_rtk
  [[ "${SELECTED[graphify]}" == "ON" ]] && install_graphify
  [[ "${SELECTED[agents]}" == "ON" ]] && install_agents_rules
  [[ "${SELECTED[autoinit]}" == "ON" ]] && install_autoinit
  [[ "${SELECTED[dcp-config]}" == "ON" ]] && install_dcp_config
  
  step "Installation Complete"
  ok "MCP stack installed successfully"
}

main "$@"
