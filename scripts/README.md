# OpenCode Custom Setup — Delta from Stock

This document summarizes every customization applied to OpenCode compared to a fresh install from GitHub.

---

## 1. Plugin Stack (7 plugins vs. 0 stock)

| Plugin | Source | Purpose |
|--------|--------|---------|
| `@tarquinen/opencode-dcp` | npm | Dynamic Context Pruning — auto-compresses stale conversation history |
| `@zenobius/opencode-skillful` | npm | Skills framework — loads `SKILL.md` files into context |
| `opencode-conductor` | npm | Agent orchestration & task delegation |
| `opencode-lcm` | npm | Lossless Context Memory — archives and recalls old session context |
| `oh-my-openagent@latest` | npm | Multi-agent workflows, model routing, categories |
| `~/.config/opencode/node_modules/superpowers` | local | Auto-registers skills from `~/.config/opencode/skills/` |
| `~/.config/opencode/plugin/auto-init.js` | local | Session bootstrap — loads token-saver mode + runs startup sequence |

**File:** `~/.config/opencode/opencode.jsonc`

---

## 2. MCP Servers (1 configured)

| Server | Type | Command | Status |
|--------|------|---------|--------|
| `code-review-graph` | local | `code-review-graph mcp` | enabled |

`graphify` is a standalone CLI tool (not an MCP server). Use `graphify query` directly.

**File:** `~/.config/opencode/opencode.jsonc`

---

## 3. DCP (Dynamic Context Pruning)

Custom compression thresholds and nudge behavior:

```json
{
  "compress": {
    "maxContextLimit": 80000,
    "minContextLimit": 40000,
    "nudgeFrequency": 4,
    "nudgeForce": "strong",
    "iterationNudgeThreshold": 10
  }
}
```

**File:** `~/.config/opencode/dcp.jsonc`

---

## 4. Oh-My-OpenAgent Configuration

### Agent Model Routing

| Agent | Model | Variant | Notes |
|-------|-------|---------|-------|
| `sisyphus` (planner) | `github-copilot/claude-opus-4.6` | high | Default plan agent |
| `hephaestus` (code) | `github-copilot/gpt-5.4` | medium | |
| `oracle` (Q&A) | `github-copilot/gpt-5.4` | high | |
| `explore` | `github-copilot/gpt-4.1` | — | Cheap parallel searches |
| `librarian` | `github-copilot/gpt-4.1` | — | Doc/code exploration |
| `prometheus` | `github-copilot/claude-opus-4.6` | high | |
| `metis` | `github-copilot/claude-opus-4.6` | high | |
| `momus` | `github-copilot/gpt-5.4` | xhigh | |
| `atlas` | `github-copilot/claude-sonnet-4.6` | — | Fallback to gpt-5.3-codex |
| `sisyphus-junior` | `github-copilot/claude-sonnet-4.6` | — | |

### Category Model Routing

| Category | Model | Variant |
|----------|-------|---------|
| `visual-engineering` | `github-copilot/claude-opus-4.6` | high |
| `ultrabrain` | `github-copilot/gpt-5.4` | xhigh |
| `deep` | `github-copilot/gpt-5.4` | medium |
| `artistry` | `github-copilot/claude-opus-4.6` | high |
| `quick` | `github-copilot/gpt-4.1` | — |
| `unspecified-low` | `github-copilot/claude-sonnet-4.6` | — |
| `unspecified-high` | `github-copilot/claude-opus-4.6` | high |
| `writing` | `github-copilot/claude-sonnet-4.6` | — |

### Skills Config
- `git_master`: `commit_footer: false`, `include_co_authored_by: false`

### Team Mode
- `enabled: true`
- `max_parallel_members: 4`
- `max_members: 8`

**File:** `~/.config/opencode/oh-my-openagent.json`

---

## 5. Custom Skills (13 domain-specific)

Located in `~/.config/opencode/skills/`:

| Skill | Domain |
|-------|--------|
| `cpp-pro` | C/C++ review & optimization |
| `python-expert` | Python debugging & best practices |
| `data-pipeline-architect` | ETL / pipeline design |
| `fusion-filter-robotics-expert` | Kalman / particle filters |
| `gps-ins-localization-expert` | GPS/INS sensor fusion |
| `linux-ubuntu-expert` | Linux sysadmin |
| `matlab-pro` | MATLAB / Simulink |
| `presentation-deck-architect` | Slide decks & visuals |
| `robotics-data-analyzer` | Sensor telemetry analysis |
| `robotics-localization-expert` | SLAM / VO / pose estimation |
| `robotics-odometry-expert` | Visual / ground / underwater odometry |
| `ros-robotics-expert` | ROS1/ROS2 |
| `rtmaps-expert` | RTMaps real-time components |

Loaded automatically by the `superpowers` plugin.

---

## 6. RTK Plugin — Bash Command Compression

Intercepts `bash` / `shell` tool executions and rewrites them via `rtk rewrite` to minimize token output.

**File:** `~/.config/opencode/plugins/rtk.ts`

Requires `rtk` binary in PATH.

---

## 7. Auto-Init Plugin — Session Bootstrap

On every `session.created` event:
1. Recalls OpenMemory context for current directory
2. Confirms `code-review-graph` is indexed (builds if not)
3. Injects `token-saver` skill instructions into context

On `session.idle`:
- Auto-stores file edits to OpenMemory

**File:** `~/.config/opencode/plugin/auto-init.js`

---

## 8. Global Rules (AGENTS.md)

- **MCP-first search:** Use `code-review-graph` tools before grep/file reads
- **File reading:** AST summaries over full file reads
- **Edit format:** Unified diffs only, no full rewrites
- **DCP awareness:** Let `@tarquinen/opencode-dcp` auto-prune; don't fight it
- **Delegation:** Use `explore`/`librarian` agents for cheap parallel work

**File:** `~/.config/opencode/AGENTS.md`

---

## 9. Removed / Not Used

| What | Reason |
|------|--------|
| `openmemory` MCP | **Disabled** (`"enabled": false`) in `opencode.jsonc` — replaced by file-based `NOTES.md` |
| Top-level `"dcp"` key | **Removed** — causes schema validation errors; plugin handles DCP internally |
| Nested `"mcp.servers"` wrapper | **Removed** — schema is flat `mcp.<name>` directly; each entry needs `"type"` and `"enabled"` |

---

## Quick Reference: Config Files

| File | Purpose |
|------|---------|
| `~/.config/opencode/opencode.jsonc` | Main config — plugins, MCP servers, instructions |
| `~/.config/opencode/oh-my-openagent.json` | Agent model routing, categories, team mode |
| `~/.config/opencode/dcp.jsonc` | DCP compression thresholds |
| `~/.config/opencode/AGENTS.md` | Global rules & tool preferences |
| `~/.config/opencode/plugins/rtk.ts` | RTK bash rewrite plugin |
| `~/.config/opencode/plugin/auto-init.js` | Session startup bootstrap |
| `~/.config/opencode/skills/*/SKILL.md` | Domain-specific skill definitions |

---

## Unified Installers

### Unified Token Installer (`unified-token-installer.sh`)

**NEW:** Single unified installer that combines all token optimization functionality.

**Usage:**
```bash
# Auto mode (default) - non-interactive full installation
bash unified-token-installer.sh

# Interactive mode - menu-driven component selection
bash unified-token-installer.sh --interactive

# Minimal mode - core stack only
bash unified-token-installer.sh --minimal

# Stack selection
bash unified-token-installer.sh --stack-a  # Daily coding (lean & fast)
bash unified-token-installer.sh --stack-b  # Full memory + compression (default)

# Dry-run preview
bash unified-token-installer.sh --dry-run
```

**Components:**
- **Core Stack:** DCP, Skills Framework, Conductor, LCM, context-mode
- **MCP Servers:** code-review-graph
- **Tools:** RTK, graphify
- **Configuration:** AGENTS.md, Auto-init, DCP thresholds
- **Stack B Only:** memsearch (cross-project semantic recall)

**Legacy Wrappers:**
- `setup-token-optimizer.sh` → delegates to unified installer
- `install-mcp-stack.sh` → delegates to unified installer
- `setup-global-token-rules.sh` → delegates to unified installer

### Script Manager (`scripts-manager.sh`)

Interactive menu for managing all unified-superpowers scripts.

**Usage:**
```bash
bash scripts-manager.sh            # Launch interactive menu
bash scripts-manager.sh --dry-run  # Preview mode
```

**Categories:**
1. **Installation** — install-universal.sh, unified-token-installer.sh
2. **Utilities** — backup-restore-ai-configs.sh, run-benchmark.sh
3. **Setup** — maintain-stack.sh
4. **MCP Stack** — launch unified-token-installer.sh
5. **Custom Script** — browse and run any script
6. **Help** — documentation and script info
