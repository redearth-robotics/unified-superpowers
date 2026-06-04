# Modular Menu System Design

## 2026-06-04

## Overview

Consolidate the scattered scripts from `agentic_installers_tools` into two unified installers with interactive menus for the `unified-superpowers` project.

---

## 1. MCP Stack Installer (`install-mcp-stack.sh`)

### Purpose
Consolidated installer for the complete MCP/token optimization stack, replacing `setup-token-optimizer.sh`.

### Menu Categories

**1. Core Stack**
- Dynamic Context Pruning (DCP)
- Skills Framework (lazy loading)
- Conductor (lifecycle scoping)
- LCM (lossless context memory)

**2. MCP Servers**
- code-review-graph (tree-sitter symbol/dependency MCP)

**3. Tools & Utilities**
- RTK (CLI output compression)
- graphify (knowledge graph queries)

**4. Configuration**
- Global AGENTS.md rules
- Auto-init plugin
- DCP compression thresholds

### CLI Flags
- `--dry-run` — preview without applying
- `--minimal` — core stack only
- `--full` — everything
- `--skip-checks` — skip dependency verification

### Safety Features
- Dependency checking (node, npm, python versions)
- Rollback on failure
- Idempotent (safe to re-run)
- Backup existing configs before overwrite

---

## 2. Scripts Manager (`scripts-manager.sh`)

### Purpose
Interactive menu system for managing all unified-superpowers scripts.

### Menu Structure

**Main Menu:**
1. Installation (Linux/Mac/Windows/Python)
2. Utilities & Tools (backup, restore, benchmark)
3. Setup & Configuration (token rules, stack maintenance)
4. MCP Stack (launch install-mcp-stack.sh)
5. Run Custom Script
6. Help & Documentation

### Key Features
- Auto-detects available scripts in `scripts/`
- Validates script integrity before execution
- Remembers last used options (state file)
- `--dry-run` support where applicable
- Context-sensitive help

---

## Implementation Plan

1. Create `install-mcp-stack.sh` — consolidated MCP installer
2. Create `scripts-manager.sh` — unified script menu
3. Update `scripts/README.md` — document new installers
4. Update `NOTES.md` — record changes
5. Make both scripts executable
6. Verify both scripts work correctly

## Open Questions

None — design approved by user.
