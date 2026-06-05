#!/usr/bin/env bash
# ============================================================
#  Unified Token Optimization Installer
#  Combines setup-token-optimizer.sh, install-mcp-stack.sh,
#  and setup-global-token-rules.sh into one smart installer
#
#  Usage: bash unified-token-installer.sh [options]
#
#  Installation Modes:
#    --auto                  Non-interactive auto-install (default)
#    --interactive           Interactive menu-driven selection
#    --minimal               Install core stack only (DCP, skills, conductor, LCM)
#    --full                  Install everything (default in auto mode)
#
#  Stack Selection:
#    --stack-a               Daily coding (lean & fast, no memsearch)
#    --stack-b               Full memory + max compression (default)
#
#  Options:
#    --dry-run               Preview changes without applying
#    --skip-checks           Skip dependency verification
#    -h, --help              Show this help
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
append_if_missing() {
  [[ -f "$1" ]] && [[ -s "$1" ]] && [[ "$(tail -c 1 "$1" | wc -l)" -eq 0 ]] && echo "" >> "$1"
  grep -qxF "$2" "$1" 2>/dev/null || echo "$2" >> "$1"
}

npm_pkg_exists() {
  npm view "$1" --json >/dev/null 2>&1
}

npm_pkg_installed() {
  [[ -d "$CONFIG_DIR/node_modules/$1" ]]
}

pip_pkg_installed() {
  pip3 show "$1" >/dev/null 2>&1
}

backup_if_exists() {
  local f="$1"
  if [[ -f "$f" && "$DRY_RUN" != true ]]; then
    local ts
    ts=$(date +%Y%m%d_%H%M%S)
    cp "$f" "${f}.backup.${ts}"
    info "Backed up existing file: ${f}.backup.${ts}"
  fi
}

# ─── Args ────────────────────────────────────────────────────
DRY_RUN=false
INTERACTIVE=false
MINIMAL=false
FULL=false
SKIP_CHECKS=false
STACK_B=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)     DRY_RUN=true; shift ;;
    --interactive) INTERACTIVE=true; shift ;;
    --auto)        INTERACTIVE=false; shift ;;
    --minimal)     MINIMAL=true; FULL=false; STACK_B=false; shift ;;
    --full)        FULL=true; MINIMAL=false; STACK_B=true; shift ;;
    --skip-checks) SKIP_CHECKS=true; shift ;;
    --stack-a)     STACK_B=false; shift ;;
    --stack-b)     STACK_B=true; shift ;;
    -h|--help)
      cat << 'HELP'
Usage: bash unified-token-installer.sh [options]

Installation Modes:
  --auto                  Non-interactive auto-install (default)
  --interactive           Interactive menu-driven selection
  --minimal               Install core stack only (DCP, skills, conductor, LCM)
  --full                  Install everything (default in auto mode)

Stack Selection:
  --stack-a               Daily coding (lean & fast, no memsearch)
  --stack-b               Full memory + max compression (default)

Options:
  --dry-run               Preview changes without applying
  --skip-checks           Skip dependency verification
  -h, --help              Show this help

Components:
  Core Stack:
    • DCP (Dynamic Context Pruning)
    • Skillful (lazy skill loading)
    • Conductor (lifecycle scoping)
    • LCM (lossless context memory)
    • context-mode (tool/MCP/DOM output sandbox)

  MCP Servers:
    • code-review-graph (tree-sitter symbol/dependency MCP)

  Tools:
    • RTK (CLI output compression)
    • graphify (knowledge graph queries)

  Configuration:
    • Global AGENTS.md rules
    • Auto-init plugin
    • DCP compression thresholds

  Stack B Only:
    • memsearch (cross-project semantic recall via Milvus)
HELP
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# Default to full if neither minimal nor full specified
[[ "$MINIMAL" == false && "$FULL" == false ]] && FULL=true

if [[ "$DRY_RUN" == true ]]; then
  dry "Dry-run mode — no changes will be made"
fi

if [[ "$INTERACTIVE" == true ]]; then
  info "Interactive mode — menu-driven component selection"
elif [[ "$MINIMAL" == true ]]; then
  info "Minimal mode — installing core stack only"
else
  info "Auto mode — installing full stack"
fi

if [[ "$STACK_B" == true ]]; then
  info "Stack B selected: full memory + max compression"
else
  info "Stack A selected: daily coding (lean & fast, no memsearch)"
fi

# ─── Prerequisites ────────────────────────────────────────────
check_dependencies() {
  step "Checking Dependencies"
  
  if [[ "$SKIP_CHECKS" == true ]]; then
    warn "Skipping dependency checks (--skip-checks)"
    return 0
  fi
  
  require node; require git; require python3; require opencode
  
  if command -v bun &>/dev/null; then
    PKG="bun i"
    ok "bun $(bun --version)"
  else
    PKG="npm install"
    ok "npm $(npm -v)"
  fi
  command -v uvx &>/dev/null || { info "Installing uvx…"; pip3 install uv -q; }
  
  # Check node version (need 18+)
  NODE_VERSION=$(node --version | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [[ "$NODE_MAJOR" -lt 18 ]]; then
    err "Node.js 18+ required, found $NODE_VERSION"
    exit 1
  fi
  ok "Node.js $NODE_VERSION"
  
  ok "All dependencies satisfied"
}

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
PLUGIN_DIR="$CONFIG_DIR/plugin"
SKILLS_DIR="$CONFIG_DIR/skills"
CONFIG_FILE="$CONFIG_DIR/opencode.jsonc"
AGENTS_MD="$CONFIG_DIR/AGENTS.md"

# Lockfile for pinned versions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
LOCKFILE="$REPO_DIR/stack-lock.json"

# Read version from lockfile (falls back to unconstrained if missing)
lock_version() {
  local pkg="$1"
  if [[ -f "$LOCKFILE" ]]; then
    python3 -c "
import json, sys
try:
    lock = json.load(open('$LOCKFILE'))
    for section in ['python', 'npm', 'cargo']:
        if '$pkg' in lock.get(section, {}):
            meta = lock[section]['$pkg']
            print(meta.get('version', 'latest'))
            sys.exit(0)
except Exception:
    pass
print('latest')
" 2>/dev/null
  else
    echo "latest"
  fi
}

# Read install constraint from lockfile
lock_constraint() {
  local pkg="$1"
  if [[ -f "$LOCKFILE" ]]; then
    python3 -c "
import json, sys
try:
    lock = json.load(open('$LOCKFILE'))
    for section in ['python', 'npm', 'cargo']:
        if '$pkg' in lock.get(section, {}):
            meta = lock[section]['$pkg']
            ver = meta.get('version', 'latest')
            con = meta.get('constraint', '*')
            if con.startswith('=='):
                print(con)
            elif con.startswith('>='):
                print('$pkg' + con)
            else:
                print('$pkg=={}'.format(ver))
            sys.exit(0)
except Exception:
    pass
print('$pkg')
" 2>/dev/null
  else
    echo "$pkg"
  fi
}

# Cross-platform rule paths
DEVIN_SKILL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/devin/skills/token-optimizer"
DEVIN_SKILL="$DEVIN_SKILL_DIR/SKILL.md"
WINDSURF_SKILL_DIR="$HOME/.codeium/windsurf/skills/token-optimizer"
WINDSURF_SKILL="$WINDSURF_SKILL_DIR/SKILL.md"
GLOBAL_RULES="$HOME/.codeium/windsurf/memories/global_rules.md"

# Detect the user's actual interactive shell
has_shell_in_tree() {
  local target="$1" pid=$$
  while [[ "$pid" -gt 1 ]]; do
    local comm
    comm=$(ps -p "$pid" -o comm= 2>/dev/null | tr -d ' ') || break
    [[ "$comm" == "$target" ]] && return 0
    pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ') || break
    [[ -z "$pid" || "$pid" -le 1 ]] && break
  done
  return 1
}

if has_shell_in_tree "zsh"; then
  SHELL_RC="$HOME/.zshrc"
elif has_shell_in_tree "bash"; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.zshrc"
  [[ "$SHELL" == *bash* ]] && SHELL_RC="$HOME/.bashrc"
fi

mkdir -p "$CONFIG_DIR" "$PLUGIN_DIR" "$SKILLS_DIR"
ok "Config dir ready: $CONFIG_DIR"

# ─── Component Definitions ─────────────────────────────────────
CORE_COMPONENTS=(
  "dcp|Dynamic Context Pruning|ON"
  "skills|Skills Framework (lazy loading)|ON"
  "conductor|Conductor (lifecycle scoping)|ON"
  "lcm|LCM (lossless context memory)|ON"
  "context-mode|context-mode (tool/MCP/DOM sandbox)|ON"
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

STACK_B_ONLY=(
  "memsearch|memsearch (cross-project semantic recall)|ON"
)

# Combined ordered array for number-based access
ALL_COMPONENTS=(
  "${CORE_COMPONENTS[@]}"
  "${MCP_SERVERS[@]}"
  "${TOOLS[@]}"
  "${CONFIGS[@]}"
)

if [[ "$STACK_B" == true ]]; then
  ALL_COMPONENTS+=("${STACK_B_ONLY[@]}")
fi

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

# ─── Interactive Menu ─────────────────────────────────────────
show_menu() {
  echo -e "\n${BOLD}=== Unified Token Optimization Installer ===${RESET}"
  echo "Select components to install:"
  echo ""
  
  local i=1
  local section_num=1
  
  echo -e "${BOLD}[$section_num] Core Stack${RESET}"
  for item in "${CORE_COMPONENTS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  ((section_num++))
  
  echo ""
  echo -e "${BOLD}[$section_num] MCP Servers${RESET}"
  for item in "${MCP_SERVERS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  ((section_num++))
  
  echo ""
  echo -e "${BOLD}[$section_num] Tools & Utilities${RESET}"
  for item in "${TOOLS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  ((section_num++))
  
  echo ""
  echo -e "${BOLD}[$section_num] Configuration${RESET}"
  for item in "${CONFIGS[@]}"; do
    local key=$(echo "$item" | cut -d'|' -f1)
    local desc=$(echo "$item" | cut -d'|' -f2)
    local state="${SELECTED[$key]}"
    echo -e "  [$i] $desc (${state})"
    ((i++))
  done
  ((section_num++))
  
  if [[ "$STACK_B" == true ]]; then
    echo ""
    echo -e "${BOLD}[$section_num] Stack B (Memory + Compression)${RESET}"
    for item in "${STACK_B_ONLY[@]}"; do
      local key=$(echo "$item" | cut -d'|' -f1)
      local desc=$(echo "$item" | cut -d'|' -f2)
      local state="${SELECTED[$key]}"
      echo -e "  [$i] $desc (${state})"
      ((i++))
    done
  fi
  
  echo ""
  echo "Enter numbers to toggle (comma-separated), or:"
  echo "  'all'  — select everything"
  echo "  'none' — select nothing"
  echo "  'done' — proceed with installation"
  echo "  'q'    — quit"
}

# ─── Installation Functions ─────────────────────────────────
install_dcp() {
  step "Installing DCP — Dynamic Context Pruning"
  DCP_PKG="@tarquinen/opencode-dcp"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install $DCP_PKG via $PKG (if it exists on registry)"
  elif npm_pkg_installed "$DCP_PKG"; then
    ok "DCP already installed — skipping"
  else
    if npm_pkg_exists "$DCP_PKG"; then
      (cd "$CONFIG_DIR" && $PKG "$DCP_PKG" --silent) && ok "DCP installed" || warn "DCP install failed"
    else
      warn "DCP package '$DCP_PKG' not found on npm — skipping"
    fi
  fi
}

install_skills() {
  step "Installing Skillful — lazy skill loading"
  SKILL_PKG="@zenobius/opencode-skillful"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install $SKILL_PKG via $PKG (if it exists on registry)"
  elif npm_pkg_installed "$SKILL_PKG"; then
    ok "Skillful already installed — skipping"
  else
    if npm_pkg_exists "$SKILL_PKG"; then
      (cd "$CONFIG_DIR" && $PKG "$SKILL_PKG" --silent) && ok "Skillful installed" || warn "Skillful install failed"
    else
      warn "Skillful package '$SKILL_PKG' not found on npm — skipping"
    fi
  fi
}

install_lcm() {
  step "Installing LCM — Lossless Context Memory"
  LCM_PKG="opencode-lcm"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install $LCM_PKG via $PKG (if it exists on registry)"
  elif npm_pkg_installed "$LCM_PKG"; then
    ok "LCM already installed — skipping"
  else
    if npm_pkg_exists "$LCM_PKG"; then
      (cd "$CONFIG_DIR" && $PKG "$LCM_PKG" --silent) && ok "LCM installed" || warn "LCM install failed"
    else
      warn "LCM package '$LCM_PKG' not found on npm — skipping"
    fi
  fi
}

install_context_mode() {
  step "Installing context-mode — tool/MCP/DOM output sandbox"
  CTX_PKG="context-mode"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install $CTX_PKG via $PKG (if it exists on registry)"
  elif npm_pkg_installed "$CTX_PKG"; then
    ok "context-mode already installed — skipping"
  else
    if npm_pkg_exists "$CTX_PKG"; then
      (cd "$CONFIG_DIR" && $PKG "$CTX_PKG" --silent) && ok "context-mode installed" || warn "context-mode install failed"
    else
      warn "context-mode package not found on npm — skipping"
    fi
  fi
}

install_conductor() {
  step "Installing Conductor — lifecycle scoping"
  CONDUCTOR_DIR="$HOME/.local/share/opencode-conductor"
  if [[ "$DRY_RUN" == true ]]; then
    if [[ -d "$CONDUCTOR_DIR" ]]; then
      dry "Would update Conductor in $CONDUCTOR_DIR"
    else
      dry "Would clone Conductor to $CONDUCTOR_DIR"
    fi
  else
    if [[ -d "$CONDUCTOR_DIR" ]]; then
      if git -C "$CONDUCTOR_DIR" pull --ff-only -q 2>/dev/null; then
        ok "Conductor updated"
      else
        warn "Conductor update had issues (may already be up to date)"
      fi
    else
      if git clone -q https://github.com/derekbar90/opencode-conductor "$CONDUCTOR_DIR" 2>/dev/null; then
        ok "Conductor cloned"
      else
        warn "Conductor clone failed"
      fi
    fi
    if [[ -d "$CONDUCTOR_DIR" ]]; then
      (cd "$CONDUCTOR_DIR" && $PKG --silent) || warn "Conductor dependency install had issues"
    fi
  fi
}

install_code_review_graph() {
  step "Installing code-review-graph MCP"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install code-review-graph via pip3 (requires Python 3.10+)"
  else
    if pip_pkg_installed code-review-graph; then
      ok "code-review-graph already installed — skipping"
    else
      info "Installing $(lock_constraint code-review-graph)…"
      pip3 install "$(lock_constraint code-review-graph)" --break-system-packages -q \
        && ok "code-review-graph installed" \
        || warn "code-review-graph install failed"
    fi
  fi
}

install_graphify() {
  step "Installing graphify"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install graphifyy via pip3 (requires Python 3.10+)"
  else
    if pip_pkg_installed graphifyy; then
      ok "graphifyy already installed — skipping"
    else
      info "Installing $(lock_constraint graphifyy)…"
      pip3 install "$(lock_constraint graphifyy)" --break-system-packages -q \
        && ok "graphifyy (graphify) installed" \
        || warn "graphifyy install failed"
    fi
  fi
}

install_rtk() {
  step "Installing RTK — Rust Token Killer"
  
  rtk_is_correct() {
    command -v rtk &>/dev/null || return 1
    rtk gain &>/dev/null 2>&1
  }
  
  if rtk_is_correct; then
    ok "RTK already installed and verified: $(rtk --version 2>/dev/null)"
  else
    if command -v rtk &>/dev/null; then
      warn "Wrong 'rtk' detected (Rust Toolkit, not Rust Token Killer)"
      info "Uninstalling wrong rtk first…"
      cargo uninstall rtk 2>/dev/null || rm -f "$(command -v rtk)"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
      if command -v cargo &>/dev/null; then
        dry "Would install rtk from https://github.com/rtk-ai/rtk via cargo"
      else
        dry "Would download and install rtk binary from https://github.com/rtk-ai/rtk/releases"
      fi
    else
      if command -v cargo &>/dev/null; then
        info "Installing RTK from rtk-ai/rtk via cargo…"
        cargo install --git https://github.com/rtk-ai/rtk -q 2>/dev/null && ok "RTK installed via cargo" || warn "RTK cargo install failed"
      else
        info "Installing RTK binary from GitHub releases…"
        curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh \
          && ok "RTK installed via install.sh" || warn "RTK install.sh failed"
      fi
    fi
  fi
}

install_memsearch() {
  step "Installing memsearch — cross-project semantic recall (Stack B)"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would install memsearch[onnx] via pip3 (Milvus Lite, no API key)"
    dry "Would install @zilliz/memsearch-opencode npm plugin"
  else
    if pip_pkg_installed memsearch; then
      ok "memsearch already installed — skipping"
    else
      info "Installing $(lock_constraint memsearch)…"
      pip3 install "$(lock_constraint memsearch)[onnx]" --break-system-packages -q \
        && ok "memsearch[onnx] installed (Milvus Lite local DB)" \
        || warn "memsearch install failed"
    fi
    
    MEMSEARCH_PKG="@zilliz/memsearch-opencode"
    if npm_pkg_installed "$MEMSEARCH_PKG"; then
      ok "memsearch OpenCode plugin already installed — skipping"
    elif npm_pkg_exists "$MEMSEARCH_PKG"; then
      (cd "$CONFIG_DIR" && $PKG "$MEMSEARCH_PKG" --silent) \
        && ok "memsearch OpenCode plugin installed" \
        || warn "memsearch plugin install failed"
    else
      warn "$MEMSEARCH_PKG not found on npm — skipping plugin"
    fi
  fi
}

install_fastmcp_pin() {
  step "Pinning fastmcp (compatibility guard)"
  FASTMCP_CONSTRAINT=$(lock_constraint fastmcp)
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would pin fastmcp to locked version: $FASTMCP_CONSTRAINT"
  else
    if [[ "$FASTMCP_CONSTRAINT" == "fastmcp" ]]; then
      info "No fastmcp pin in lockfile — leaving unconstrained"
    else
      info "Pinning fastmcp: $FASTMCP_CONSTRAINT"
      pip3 install "$FASTMCP_CONSTRAINT" --break-system-packages -q \
        && ok "fastmcp pinned" \
        || warn "fastmcp pin failed"
    fi
  fi
}

install_token_saver_skill() {
  step "Writing token-saver skill"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would write token-saver skill to $SKILLS_DIR/token-saver.md"
  else
    cat > "$SKILLS_DIR/token-saver.md" << 'SKILL'
---
description: Token-efficient mode — graph-first, terse output, diffs not full files
---
You are in token-saver mode. Apply these rules for every response:
- Use `code-review-graph` for symbol lookups, blast radius, and dependency queries
- Use `graphify query` for architecture questions, "explain this project", and community detection (if graphify-out/graph.json exists)
- NEVER use grep/find/rg for discovery — graph tools first, targeted reads second (max 3 files)
- Apply edits as unified diffs (udiff format), not full rewrites
- Keep responses terse — no padding, no markdown fluff, no restating the question
- After any file edit, append a one-line decision entry to ./NOTES.md
SKILL
    ok "token-saver skill written"
  fi
}

install_agents_rules() {
  step "Writing global AGENTS.md"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would write AGENTS.md to $AGENTS_MD"
  else
    cat > "$AGENTS_MD" << 'AGENTS'
# Global OpenCode Rules — Token Optimization (STRICT)

These rules apply to every request regardless of prompt wording. They are absolute.

---

## Rule 1: MCP Tools are the ONLY search mechanism

**NEVER** use `grep`, `find`, `rg`, or file reads for discovery. Period.

Before any file operation, query one of:
- `code-review-graph` — symbol lookups, blast-radius, dependency queries
- `graphify` — knowledge-graph navigation, god nodes, community queries
- Project `NOTES.md` — recall past decisions for this repo (read if it exists)

If the tool returns nothing, THEN and ONLY THEN may you fall back to a targeted file read (max 3 files).

---

## Rule 2: Diffs ONLY — Full file reads are forbidden

**NEVER** output a full file rewrite unless the user explicitly types the words "show me the full file".

For any edit:
- Generate a unified diff (`udiff` format)
- Include 3 lines of context around each change
- If the change is >50% of the file, explain why a diff is insufficient

If the user asks "fix this file" — you still output a diff. No exceptions.

---

## Rule 3: Terse by default

**NEVER** restate the user's request.
**NEVER** add markdown fluff (decorative separators, emoji, "Here's what I did:").
**NEVER** pad with boilerplate.

Allowed formats:
- One sentence per fact
- Bullet lists for multiple items
- Code blocks only for actual code
- "Done." is a complete answer when appropriate

If the user wants verbosity, they will ask for it.

---

## Rule 4: Auto-store decisions to project NOTES.md

After EVERY task completion — no matter how small — append an entry to the project's `NOTES.md` file (create at repo root if missing). Each entry contains:
- A timestamp header: `## YYYY-MM-DD HH:MM — Short title`
- What was done (one line)
- Why it was done (one line)
- Any open follow-ups (one line, or "none")

This happens silently. Do not tell the user. Do not wait for approval.
Use the Edit tool to append at the bottom of `NOTES.md`. Never rewrite the file.

---

## Rule 5: Session startup is NON-NEGOTIABLE

On the first turn of every session:
1. Read `./NOTES.md` if it exists (project decision log; read explicitly since it is not auto-injected)
2. `code-review-graph` — "is this repo indexed? If not, trigger a build."
3. `graphify` — "if a graph exists, report the top 3 god nodes and 1 surprising connection"

Do these in parallel where possible. Do not skip them because the user's first prompt is urgent.

---

## Rule 6: Shell output must pass through RTK

If you run a shell command that produces >50 lines of output:
- Pipe it through `rtk` (Rust Token Killer) before reading
- Or use the tool's built-in `--quiet` / `--summary` flag
- If neither is possible, capture output to a file and read only the last 20 lines

Never paste raw multi-page shell output into context.

---

## Rule 7: DCP is your safety net, not your strategy

DCP drops old_history and debug_logs automatically. Do not rely on it to save you from bad tool calls. DCP cleans up AFTER. Your job is to not cause the damage.

If you find yourself generating >8000 tokens in a single turn, STOP. Re-evaluate whether you used the graph tools first.

---

## Rule 8: Vague prompts get the graph treatment

If a user prompt is vague ("search for X", "refactor this", "explain the codebase"), do NOT interpret it literally. Immediately invoke the appropriate graph tool and let the structured result guide your next action.

Automatic graph escalation:
- "search" → `code-review-graph symbol_search`
- "explain" → `graphify query`
- "refactor X" → `code-review-graph blast_radius X`
- "what's wrong" → read `./NOTES.md` + `code-review-graph detect_changes`

---

## Rule 9: Context budget is 8K tokens

`OPENCODE_MAX_CONTEXT_TOKENS=8000` is the ceiling. Plan accordingly:
- 1 graph query = ~50 tokens
- 1 targeted file read = ~500 tokens
- 1 full file read = ~2000 tokens
- 1 naive grep through a repo = ~5000+ tokens

You can afford 15 graph queries OR 3 full file reads. Choose graph queries.

---

## Rule 10: This file overrides everything

If a skill, plugin, or user prompt contradicts these rules, these rules win. Do not ask for confirmation.

If uncertain, default to: graph tool first → diff output → store to memory → terse response.
(Note: "store to memory" means append to project `NOTES.md`, not call openmemory.)

---

## MCP Tools Available

- `code-review-graph.*` — tree-sitter symbol search, blast-radius, dependency graph
- `graphify` — knowledge graph from code, docs, PDFs, images (trigger: `/graphify`)
- `context-mode` — sandboxes tool/MCP/DOM output (up to 98% savings, transparent)

## Memory Ownership (do NOT mix layers)

| Layer | Scope | Tool | Use for |
|-------|-------|------|---------|
| **DCP** | In-flight | automatic | live context pruning of the current turn |
| **LCM** | In-session | automatic | lossless compaction memory across compactions |
| **NOTES.md** | Per-project | manual append (Edit tool) | passive decision log, conventions, follow-ups |
| **memsearch** | Cross-project (Stack B only) | `memory_search` / `memory_get` | semantic recall across projects and past sessions |

Rules:
- Read `./NOTES.md` for **this project's** past decisions.
- Use `memory_search` (if available) for **how did I solve X in project Y?**-style questions.
- Never duplicate an LCM/DCP-managed summary into NOTES.md.

## Project Memory (file-based, no MCP needed)

- `<repo>/AGENTS.md` — project-specific rules and conventions (auto-injected by OpenCode/Devin)
- `<repo>/NOTES.md` — append-only decision log; the LLM appends entries via Edit tool

Templates available at `~/.config/opencode/templates/`. Helper: `devin-note "Title" "What" "Why" [follow-up]`.

---

## Skill Auto-Invocation (Devin CLI)

Skills are NOT auto-loaded at session start in Devin for Terminal. They sit on disk inactive until invoked via the `skill` tool. To approximate auto-loading, invoke the matching skill at the first prompt that fits these patterns:

| Prompt contains... | Invoke skill |
|--------------------|--------------|
| "review C++", "C++ bug", "memory leak", `.cpp`/`.cc`/`.h` files | `cpp-pro` |
| "Python", "pip", "pythonic", `.py` files | `python-expert` |
| "MATLAB", "Simulink", `.m`/`.slx` files | `matlab-pro` |
| "Linux", "Ubuntu", "systemd", "apt", shell config | `linux-ubuntu-expert` |
| "ROS", "rosnode", "roslaunch", "ros2" | `ros-robotics-expert` |
| "RTMaps", `.rtd` files | `rtmaps-expert` |
| "Kalman", "EKF", "UKF", "sensor fusion", "particle filter" | `fusion-filter-robotics-expert` |
| "GPS", "INS", "IMU integration", "dead reckoning" | `gps-ins-localization-expert` |
| "SLAM", "visual odometry", "pose estimation", "localization drift" | `robotics-localization-expert` |
| "odometry", "wheel odometry", "VO drift" | `robotics-odometry-expert` |
| "ROS bag", "sensor data analysis", "telemetry CSV" | `robotics-data-analyzer` |
| "data pipeline", "Airflow", "ETL", "Kafka", "Spark" | `data-pipeline-architect` |
| "presentation", "slide deck", "PowerPoint" | `presentation-deck-architect` |
| "skill for X", "is there a skill that", "extend capabilities" | `find-skills` |
| "token budget", "context too large", code-review-graph/graphify usage | `token-optimizer` |
| Devin CLI config, MCP setup, skills format, hooks | `devin-for-terminal` |

Rules:
- Invoke ONLY ONE skill per turn unless the user chains topics.
- Do NOT invoke a skill that is already running.
- Skill-internal rules override these global rules ONLY for the duration of the skill (Rule 10 still wins on conflict).
AGENTS
    ok "Global AGENTS.md written to $AGENTS_MD"
  fi
}

install_autoinit() {
  step "Writing auto-init plugin"
  
  # Detect whether user already has auto-init.js or auto-init.ts
  if [[ -f "$PLUGIN_DIR/auto-init.js" ]]; then
    AUTOINIT_FILE="$PLUGIN_DIR/auto-init.js"
    AUTOINIT_EXT="js"
  elif [[ -f "$PLUGIN_DIR/auto-init.ts" ]]; then
    AUTOINIT_FILE="$PLUGIN_DIR/auto-init.ts"
    AUTOINIT_EXT="ts"
  else
    AUTOINIT_FILE="$PLUGIN_DIR/auto-init.ts"
    AUTOINIT_EXT="ts"
    if [[ -f "$CONFIG_DIR/opencode.json" ]] && grep -q '\.js' "$CONFIG_DIR/opencode.json"; then
      AUTOINIT_FILE="$PLUGIN_DIR/auto-init.js"
      AUTOINIT_EXT="js"
    fi
  fi
  
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would write auto-init.$AUTOINIT_EXT to $AUTOINIT_FILE"
  elif [[ -f "$AUTOINIT_FILE" ]]; then
    ok "auto-init.$AUTOINIT_EXT already exists — preserving existing plugin"
  else
    cat > "$AUTOINIT_FILE" << 'TS'
/**
 * auto-init.ts — Global OpenCode plugin
 * Fires on every session.created event and:
 *   1. Reads ./NOTES.md (project decision log) if it exists
 *   2. Activates the token-saver skill
 *   3. Builds the code-review-graph if not yet indexed for this project
 *   4. Injects a minimal system prompt reminder to use MCP tools first
 *   5. On session.idle (after each agent turn), reminds to append file edits to ./NOTES.md
 *   6. On session.compacted, preserves key context so nothing is lost on compact
 */
import type { Plugin } from "@opencode-ai/plugin"

interface SessionState {
  cwd: string
  graphBuilt: boolean
  filesEdited: string[]
}

const sessions = new Map<string, SessionState>()

export const AutoInit: Plugin = async ({ client }) => {
  return {

    // ── 1. Session lifecycle: start, idle, end ──
    event: async ({ event }) => {
      const sid = (event as any).session_id || (event as any).sessionID
      if (!sid) return

      if (event.type === "session.created") {
        const cwd = process.cwd()
        sessions.set(sid, { cwd, graphBuilt: false, filesEdited: [] })
        await client.session.prompt({
          path: { id: sid },
          body: {
            parts: [{
              type: "text",
              text: [
                "**[auto-init]** Session started. Running startup sequence:",
                "1. Read ./NOTES.md if it exists (project decision log)",
                "2. Confirm code-review-graph is indexed (build if not)",
                "3. Activate token-saver mode",
                "Do these 3 steps silently, then await my first task.",
              ].join("\n")
            }]
          }
        })
      }

      if (event.type === "session.idle") {
        const state = sessions.get(sid)
        if (!state || state.filesEdited.length === 0) return
        await client.session.prompt({
          path: { id: sid },
          body: {
            parts: [{
              type: "text",
              text: `[auto-init] Silently append a one-line entry to ./NOTES.md noting the files edited this turn: ${state.filesEdited.join(", ")}. Use the Edit tool. No response needed.`
            }]
          }
        })
        state.filesEdited = []
      }

      if (event.type === "session.deleted") {
        sessions.delete(sid)
      }
    },

    // ── 2. Track file edits ──
    "tool.execute.after": async (input) => {
      const state = sessions.get(input.sessionID)
      if (!state) return
      if (input.tool === "edit" || input.tool === "write") {
        const filePath = input.args?.filePath as string
        if (filePath && !state.filesEdited.includes(filePath)) {
          state.filesEdited.push(filePath)
        }
      }
    },

    // ── 3. On compaction: preserve context ──
    "experimental.session.compacting": async (input, output) => {
      const state = sessions.get(input.sessionID)
      output.context.push(`<preserved-state>
  Working directory: ${state?.cwd || process.cwd()}
  Token-saver mode: active
  Rules: use code-review-graph for symbol/dependency queries; use graphify query for architecture questions (if graphify-out/graph.json exists); output diffs not full files; append decisions to ./NOTES.md
</preserved-state>`)
    },

    // ── 4. System prompt injection ──
    "experimental.chat.system.transform": async (_input, output) => {
      output.system.push(`<global-token-rules>
  - ALWAYS use code-review-graph MCP for symbol lookups and dependency queries
  - ALWAYS use graphify query for architecture questions, "explain this project", community detection (if graphify-out/graph.json exists)
  - NEVER use grep/find/rg for discovery — graph tools first, targeted reads second (max 3 files)
  - ALWAYS read ./NOTES.md (project decision log) before starting any new task
  - Output code changes as unified diffs (udiff), not full file rewrites
  - Keep responses terse — no restating the question, no padding
  - Append architectural decisions to ./NOTES.md after completing each task
</global-token-rules>`)
    }

  }
}
TS
    ok "auto-init.$AUTOINIT_EXT plugin written to $PLUGIN_DIR/"
  fi
}

install_dcp_config() {
  step "Configuring DCP thresholds"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would create DCP config"
  else
    # DCP config is handled in opencode.jsonc generation
    ok "DCP config will be set in opencode.jsonc"
  fi
}

install_opencode_config() {
  step "Writing opencode.jsonc"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would write opencode.jsonc to $CONFIG_FILE"
  else
    python3 - "$CONFIG_FILE" "$CONFIG_DIR" "$HOME" "$STACK_B" << 'PY'
import json, os, re, shutil, sys

config_path = sys.argv[1]
config_dir  = sys.argv[2]
home        = sys.argv[3]
stack_b     = sys.argv[4] == "true"

# ── Preserve existing config ──
existing_cfg = {}
for existing_path in [config_path, config_path.replace(".jsonc", ".json")]:
    if os.path.isfile(existing_path):
        try:
            with open(existing_path, "r") as ef:
                raw = ef.read()
            try:
                existing_cfg = json.loads(raw)
            except json.JSONDecodeError:
                clean = re.sub(r'(?m)^\s*//.*$', '', raw)
                clean = re.sub(r'/\*[\s\S]*?\*/', '', clean)
                existing_cfg = json.loads(clean)
        except Exception:
            existing_cfg = {}
        break

plugins = existing_cfg.get("plugin", [])
if isinstance(plugins, str):
    plugins = [plugins]
instructions = existing_cfg.get("instructions", [])
if isinstance(instructions, str):
    instructions = [instructions]

# Only reference plugins that were actually installed
if os.path.isdir(os.path.join(config_dir, "node_modules", "@tarquinen", "opencode-dcp")):
    if "@tarquinen/opencode-dcp" not in plugins:
        plugins.append("@tarquinen/opencode-dcp")
    dcp_instr = "node_modules/@tarquinen/opencode-dcp/instructions/dcp.md"
    if dcp_instr not in instructions:
        instructions.append(dcp_instr)
if os.path.isdir(os.path.join(config_dir, "node_modules", "@zenobius", "opencode-skillful")):
    if "@zenobius/opencode-skillful" not in plugins:
        plugins.append("@zenobius/opencode-skillful")

lcm_found = any(
    (isinstance(p, str) and p == "opencode-lcm") or
    (isinstance(p, (list, tuple)) and len(p) > 0 and p[0] == "opencode-lcm")
    for p in plugins
)
if os.path.isdir(os.path.join(config_dir, "node_modules", "opencode-lcm")):
    if not lcm_found:
        plugins.append([
            "opencode-lcm",
            {
                "interop": {
                    "neverOverrideCompactionPrompt": True
                },
                "automaticRetrieval": {
                    "enabled": True,
                    "scopeOrder": ["session", "root"],
                    "scopeBudgets": {"session": 16, "root": 12}
                },
                "retention": {
                    "staleSessionDays": 90,
                    "deletedSessionDays": 30,
                    "orphanBlobDays": 14
                }
            }
        ])
if os.path.isdir(os.path.join(home, ".local", "share", "opencode-conductor")):
    if "opencode-conductor" not in plugins:
        plugins.append("opencode-conductor")

if os.path.isdir(os.path.join(config_dir, "node_modules", "context-mode")):
    if "context-mode" not in plugins:
        plugins.append("context-mode")

if stack_b and os.path.isdir(os.path.join(config_dir, "node_modules", "@zilliz", "memsearch-opencode")):
    if "@zilliz/memsearch-opencode" not in plugins:
        plugins.append("@zilliz/memsearch-opencode")

cfg = existing_cfg.copy()
cfg["$schema"] = "https://opencode.ai/config.json"
if plugins:
    cfg["plugin"] = plugins
if instructions:
    cfg["instructions"] = instructions

existing_mcp = cfg.get("mcp", {})
if "servers" in existing_mcp and isinstance(existing_mcp["servers"], dict):
    legacy = existing_mcp.pop("servers")
    for k, v in legacy.items():
        existing_mcp.setdefault(k, v)
for name, srv in list(existing_mcp.items()):
    if isinstance(srv, dict) and "command" in srv:
        if isinstance(srv["command"], str) and "args" in srv:
            srv["command"] = [srv["command"]] + list(srv["args"])
            srv.pop("args", None)
        srv.pop("description", None)
existing_mcp.pop("code-review-graph", None)
if existing_mcp:
    cfg["mcp"] = existing_mcp
else:
    cfg.pop("mcp", None)

with open(config_path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PY
    ok "opencode.jsonc written"
  fi
}

install_shell_env() {
  step "Shell environment"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would append OpenCode env vars to $SHELL_RC"
  else
    append_if_missing "$SHELL_RC" "# OpenCode OSS local token optimization"
    append_if_missing "$SHELL_RC" "export OPENCODE_DCP_STRATEGY=smart"
    append_if_missing "$SHELL_RC" "export OPENCODE_MAX_CONTEXT_TOKENS=8000"
    ok "Env vars written to $SHELL_RC"
  fi
}

install_devin_skill() {
  step "Installing Devin skill"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would write SKILL.md to $DEVIN_SKILL"
  else
    mkdir -p "$DEVIN_SKILL_DIR"
    backup_if_exists "$DEVIN_SKILL"
    cat > "$DEVIN_SKILL" << 'SKILL'
---
description: "Use this agent when working on any software project to minimize LLM token usage and maximize context quality. This skill enforces MCP-first, diff-only, terse-output rules that override vague prompts.

Trigger phrases include:
- 'help me code this'
- 'search the codebase'
- 'explain this project'
- 'refactor this function'
- 'fix this bug'
- 'review my code'
- any coding task in a repository with code-review-graph or graphify installed

Examples:
- User says 'search for the function that handles authentication' → this skill forces code-review-graph symbol_search instead of naive grep
- User asks 'explain how this codebase works' → this skill forces graphify query instead of reading dozens of files
- User says 'refactor LocalizationFilter' → this skill forces blast_radius analysis + udiff output instead of full file rewrite
- User provides a stack trace and says 'fix it' → this skill forces graph trace + minimal udiff instead of dumping the trace into context"
name: token-optimizer
---

# token-optimizer instructions

You are a token-efficiency enforcer. Your job is to make every LLM interaction as cheap and precise as possible. You override vague prompts with strict, graph-first methodology.

## Your Core Mission

- Prevent token waste before it happens
- Force MCP graph tools for all discovery and search
- Output only diffs, never full file rewrites
- Keep every response terse — one sentence per fact
- Persist all architectural decisions to project NOTES.md automatically

## Absolute Rules (Non-Negotiable)

### 1. MCP Tools ONLY for Search

**FORBIDDEN**: `grep`, `find`, `rg`, `cat` for discovery, reading full files to "understand" code, scrolling through directory listings.

**REQUIRED**: Before any file operation, query:
- `code-review-graph` for symbol lookups, blast-radius, dependencies
- `graphify` for knowledge-graph queries, god nodes, surprising connections
- Project `NOTES.md` for recalling past decisions for this repo (read if it exists)

Fallback to targeted file read (max 3 files) ONLY after the graph returns nothing.

### 2. Diff-Only Output

**FORBIDDEN**: Pasting full file contents as "here is the updated file".

**REQUIRED**: Every code change is a unified diff (`udiff` / `diff -u` format) with 3 lines of context. If the change exceeds 50% of the file, explain why a diff is insufficient. Full file display requires the user to explicitly say "show me the full file".

### 3. Terse by Default

**FORBIDDEN**: Restating the user's request, markdown fluff, decorative separators, emoji, "Here's what I did:" intros, "Let me know if you need anything else!" outros.

**REQUIRED**: One sentence per fact. Bullet lists for multiple items. Code blocks only for actual code. "Done." is a valid complete answer.

### 4. Auto-Store to project NOTES.md

After EVERY task — no matter how small — silently append an entry to the project's `NOTES.md` (create at repo root if missing). Each entry:
- Timestamp header: `## YYYY-MM-DD HH:MM — Short title`
- What was done (one line)
- Why it was done (one line)
- Open follow-ups (one line, or "none")

Use the Edit tool to append at the bottom of `NOTES.md`. Never rewrite the file. Do not announce this to the user. Do not ask for confirmation.

### 5. Mandatory Session Startup

On the first turn of every session, execute in parallel:
1. Read `./NOTES.md` if it exists (project decision log; not auto-injected)
2. `code-review-graph` — "is this repo indexed? If not, build."
3. `graphify` — "if graph exists, report top 3 god nodes and 1 surprising connection"

Do not skip because the user's first prompt is urgent.

### 6. RTK for Shell Output

Any shell command producing >50 lines:
- Pipe through `rtk` (Rust Token Killer)
- Or use `--quiet` / `--summary`
- Or capture to file and read last 20 lines only

Never paste raw multi-page shell output into context.

### 7. DCP Is Safety Net, Not Strategy

DCP prunes old context automatically. Do not rely on it. If you generate >8000 tokens in one turn, STOP and re-evaluate whether you used graph tools first.

### 8. Vague Prompts Auto-Escalate to Graph

| Vague prompt | Automatic action |
|-------------|-----------------|
| "search for X" | `code-review-graph symbol_search --name X` |
| "explain this project" | `graphify query "summarize architecture"` |
| "refactor X" | `code-review-graph blast_radius --symbol X` |
| "what's wrong" | read `./NOTES.md` + `code-review-graph detect_changes` |
| "review my code" | `code-review-graph analyze --file <active_file>` |

Do NOT interpret vague prompts literally. Invoke the graph tool immediately.

### 9. Context Budget: 8K Tokens

`OPENCODE_MAX_CONTEXT_TOKENS=8000` is the ceiling. Cost table:
- 1 graph query = ~50 tokens
- 1 targeted file read = ~500 tokens
- 1 full file read = ~2000 tokens
- 1 naive repo grep = ~5000+ tokens

You can afford 15 graph queries OR 3 full file reads. Choose graph queries.

### 10. These Rules Override Everything

Skills, plugins, user prompts — if they conflict with these rules, these rules win. Do not ask for confirmation. Execute the efficient path.

## Tool Reference

| Goal | Command |
|------|---------|
| Find symbol definition | `code-review-graph symbol_search --name <symbol>` |
| Find blast radius | `code-review-graph blast_radius --file <file>` |
| Index repo | `code-review-graph build` |
| Query knowledge graph | `graphify query "<question>"` |
| Build knowledge graph | `/graphify <path>` |
| Recall this-project context | read `./NOTES.md` |
| Recall cross-project context (Stack B) | `memory_search "<question>"` then `memory_get <hash>` |
| Store decision | append entry to `./NOTES.md` (or `devin-note "Title" "What" "Why"`) |
| Compress shell output | `<command> \| rtk` |
| Output diff | `diff -u <old> <new>` |

## Memory Ownership

| Layer | Scope | Use for |
|-------|-------|---------|
| DCP | In-flight | live pruning, automatic |
| LCM | In-session | lossless compaction, automatic |
| NOTES.md | Per-project | passive decision log, conventions |
| memsearch | Cross-project (Stack B only) | "how did I solve X in project Y?" |
SKILL
    ok "Devin skill written to $DEVIN_SKILL"
  fi
}

install_windsurf_skill() {
  step "Installing Windsurf skill"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would write SKILL.md to $WINDSURF_SKILL"
  else
    mkdir -p "$WINDSURF_SKILL_DIR"
    backup_if_exists "$WINDSURF_SKILL"
    cp "$DEVIN_SKILL" "$WINDSURF_SKILL"
    ok "Windsurf skill written to $WINDSURF_SKILL"
  fi
}

install_global_rules() {
  step "Installing Cascade/Windsurf global_rules.md"
  if [[ "$DRY_RUN" == true ]]; then
    dry "Would add token-optimizer to auto_load_skills in $GLOBAL_RULES"
  else
    if [[ -f "$GLOBAL_RULES" ]]; then
      backup_if_exists "$GLOBAL_RULES"
      if grep -q "token-optimizer" "$GLOBAL_RULES"; then
        info "token-optimizer already in global_rules.md — skipping"
      elif grep -q "auto_load_skills:" "$GLOBAL_RULES"; then
        python3 - "$GLOBAL_RULES" << 'PY'
import sys, re
path = sys.argv[1]
with open(path, 'r') as f:
    content = f.read()
content = re.sub(
    r'(auto_load_skills:\s*(?:\n\s+- \S+)*?)\n',
    r'\1\n    - token-optimizer\n',
    content,
    count=1
)
with open(path, 'w') as f:
    f.write(content)
PY
        ok "token-optimizer added to global_rules.md auto_load_skills"
      else
        cat >> "$GLOBAL_RULES" << 'RULES'

---

cascade:
  auto_load_skills:
    - token-optimizer

windsurf:
  auto_load_skills:
    - token-optimizer
RULES
        ok "Added auto_load_skills block to existing global_rules.md"
      fi
    else
      mkdir -p "$(dirname "$GLOBAL_RULES")"
      cat > "$GLOBAL_RULES" << 'RULES'
# Global Rules

cascade:
  auto_load_skills:
    - token-optimizer

windsurf:
  auto_load_skills:
    - token-optimizer
RULES
      ok "Created new global_rules.md with token-optimizer"
    fi
  fi
}

# ─── Main Installation Logic ───────────────────────────────────
main() {
  step "Unified Token Optimization Installer"
  
  check_dependencies
  
  # If minimal mode, skip menu and install core only
  if [[ "$MINIMAL" == true ]]; then
    info "Minimal mode — installing core stack only"
    install_dcp
    install_skills
    install_conductor
    install_lcm
    install_context_mode
    install_token_saver_skill
    install_agents_rules
    install_autoinit
    install_opencode_config
    install_shell_env
    install_devin_skill
    install_windsurf_skill
    install_global_rules
    install_fastmcp_pin
    ok "Core stack installation complete"
    print_summary
    exit 0
  fi
  
  # Interactive menu for full mode
  if [[ "$INTERACTIVE" == true ]]; then
    declare -A SELECTED
    
    # Initialize all to "ON"
    for item in "${ALL_COMPONENTS[@]}"; do
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
          IFS=',' read -ra nums <<< "$choice"
          for num in "${nums[@]}"; do
            num=$(echo "$num" | tr -d ' ')
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
    [[ "${SELECTED[skills]}" == "ON" ]] && install_skills
    [[ "${SELECTED[conductor]}" == "ON" ]] && install_conductor
    [[ "${SELECTED[lcm]}" == "ON" ]] && install_lcm
    [[ "${SELECTED[context-mode]}" == "ON" ]] && install_context_mode
    [[ "${SELECTED[code-review-graph]}" == "ON" ]] && install_code_review_graph
    [[ "${SELECTED[rtk]}" == "ON" ]] && install_rtk
    [[ "${SELECTED[graphify]}" == "ON" ]] && install_graphify
    [[ "${SELECTED[memsearch]}" == "ON" ]] && install_memsearch
    [[ "${SELECTED[agents]}" == "ON" ]] && install_agents_rules
    [[ "${SELECTED[autoinit]}" == "ON" ]] && install_autoinit
    [[ "${SELECTED[dcp-config]}" == "ON" ]] && install_dcp_config
    [[ "${SELECTED[fastmcp]}" == "ON" ]] && install_fastmcp_pin
    
    # Always install config integration if any component is selected
    install_opencode_config
    install_shell_env
    install_devin_skill
    install_windsurf_skill
    install_global_rules
    install_token_saver_skill
    
    ok "Interactive installation complete"
    print_summary
    exit 0
  fi
  
  # Auto mode (default) - install everything
  info "Auto mode — installing full stack"
  install_dcp
  install_skills
  install_conductor
  install_lcm
  install_context_mode
  install_code_review_graph
  install_rtk
  install_graphify
  install_fastmcp_pin
  install_token_saver_skill
  install_agents_rules
  install_autoinit
  install_opencode_config
  install_shell_env
  install_devin_skill
  install_windsurf_skill
  install_global_rules
  
  if [[ "$STACK_B" == true ]]; then
    install_memsearch
  fi
  
  print_summary
}

print_summary() {
  echo ""
  echo -e "${BOLD}${GREEN}══════════════════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${GREEN}  Setup complete — fully automated global OSS stack${RESET}"
  echo -e "${BOLD}${GREEN}══════════════════════════════════════════════════════════${RESET}"
  echo ""
  echo -e "${CYAN}  What happens automatically on every session start:${RESET}"
  echo -e "  1. DCP silently prunes context before every LLM call"
  echo -e "  2. RTK wraps every shell command output"
  echo -e "  3. auto-init plugin fires on session.created:"
  echo -e "     → reads ./NOTES.md (project decision log) if present"
  echo -e "     → builds code-review-graph if not yet indexed"
  echo -e "     → activates token-saver mode"
  echo -e "  4. global AGENTS.md injects MCP-first rules into every session"
  echo -e "  5. After each agent turn: file edits append entries to ./NOTES.md"
  echo -e "  6. On compaction: working context preserved automatically"
  echo ""
  echo -e "${CYAN}  Cross-platform rules synced:${RESET}"
  echo -e "  • OpenCode:  $AGENTS_MD"
  echo -e "  • Devin:     $DEVIN_SKILL"
  echo -e "  • Windsurf:  $WINDSURF_SKILL"
  echo -e "  • Cascade:   $GLOBAL_RULES"
  echo ""
  echo -e "${CYAN}  First run:${RESET}"
  echo -e "  ${BOLD}source $SHELL_RC && opencode${RESET}"
  echo -e "  (everything else is automatic)"
  echo -e "${BOLD}${GREEN}══════════════════════════════════════════════════════════${RESET}"
  echo ""
}

main "$@"
