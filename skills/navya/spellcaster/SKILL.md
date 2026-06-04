---
name: spellcaster
description: Navya's Spellcaster CLI and Chaudron recipe repository. Use when casting NavyaDrives, writing/editing .spell files, working with chaudron inventory/requirements, running spellcaster commands (cast, freeze, validate, apply_changes), editing conf.d configurations, or managing frozen files. Triggers - 'spellcaster', 'chaudron', '.spell', 'cast', 'frozen file', 'spellcaster cast', 'spellcaster validate', 'spellcaster freeze', 'inventory', 'requirements.yaml', '.spellcasterignore', 'setup.conf', 'spell_book_schema', 'apply_changes'.
---

# Spellcaster & Chaudron - Navya Drive Composition System

Spellcaster is Navya's Python CLI tool that "casts" a Chaudron (recipe repository) into a platform-specific NavyaDrive runtime or installer. A Chaudron is a git repository containing `.spell` recipe files, configuration resources, schemas, and package references that define what goes into each vehicle's software stack.

**Spellcaster source**: `/home/alaa.el-jawad/dev/spellcaster`
**Chaudron source**: `/home/alaa.el-jawad/dev/chaudron`
**Package manager**: PDM (Python)
**Install**: `pipx install spellcaster` or `pip install spellcaster`
**Docs**: https://doc.navya.tech/spellcaster/2.0.4

## Core Concepts

- **Chaudron**: A git repo of recipes (`.spell` files) describing which resources (binaries, configs, diagrams) compose a NavyaDrive for each vehicle platform
- **Spell**: A YAML recipe (`.spell` file) that tells Spellcaster what to copy/merge/fetch and where to put it in the destination
- **Cast**: The act of producing a NavyaDrive from a Chaudron for a specific vehicle type, architecture, PC, and use (dev/prod/test)
- **NavyaDrive**: The resulting runtime directory containing all binaries, configs, diagrams, and services for a vehicle
- **Inventory**: YAML file (`.inventory`) describing vehicle types, architectures, revisions, and PCs with their OS/arch/compiler
- **Requirements**: YAML file (`requirements.yaml`) listing Conan package references needed by the cast
- **Frozen files**: Pinned package lists (`*_frozen.txt`) that lock exact versions for reproducible casts
- **Spell Book Schema**: YAML schema (`spell_book_schema.yml`) that validates `.spell` file structure

> **Shared concepts** (Conan reference format, version ranges, Artifactory auth, NavyaDrive layout): See the **navya** umbrella skill.
> **Configuration files** (`.conf` JSON format, grimoire C++ API, scoped overrides): See the **grimoire** skill.
> **C++ build & packaging** (project.yaml, doyle commands): See the **doyle** skill.

## CLI Command Reference

### `spellcaster cast`

Cast a NavyaDrive from a Chaudron for a specific vehicle/PC.

```bash
spellcaster cast <chaudron_path> <type[/arch[/revision]]> <pc_id> [options]
```

| Flag | Description |
|------|-------------|
| `<chaudron_path>` | Path to the Chaudron repository |
| `<vehicle_type>` | Vehicle target: `shuttle/evo3/base`, `tract/boulonnais/base`, etc. |
| `<pc_id>` | PC number (0, 1, 2, 3) as defined in inventory |
| `--use [dev\|prod\|test]` | Usage environment (default: prod) |
| `--default` | Make casted NavyaDrive the system default |
| `--default_config` | Symlink site/vehicle folders to example configs |
| `--destination_path PATH` | Custom output directory |
| `--force` | Skip overwrite warnings |
| `--dryrun` | Preview without writing files |
| `--no_caching` | Disable artifact caching |
| `--installer [deb\|qt]` | Also create an installer package |
| `--upload` | Upload package to Artifactory |
| `--upload-conf` | Upload configuration to S3 |
| `--login USER` | Artifactory login |
| `--pwd PASSWORD` | Artifactory password |
| `--api_key KEY` | Artifactory API key (default: `$ARTIFACTORY_API_KEY`) |
| `--setup_conf_copy_path PATH` | Copy setup.conf to this path |

**Examples:**

```bash
# Dev cast for shuttle evo3, PC 1
spellcaster cast /path/to/chaudron shuttle/evo3/base 1 --use dev --default --default_config

# Production cast to custom location
spellcaster cast /path/to/chaudron shuttle/evo3/base 1 --use prod --destination_path /opt/custom

# Dry run to preview
spellcaster cast /path/to/chaudron shuttle/evo3/base 1 --use dev --dryrun

# Cast with installer
spellcaster cast /path/to/chaudron shuttle/evo3/base 1 --use prod --installer deb --upload
```

### `spellcaster cast_software`

Cast a specific software component.

```bash
spellcaster cast_software <chaudron_path> <software> [--profile PROFILE]
```

### `spellcaster freeze`

Generate frozen files pinning exact package versions for reproducible casts.

```bash
spellcaster freeze <chaudron_path> [--vehicle_type TYPE] [--software NAME] [--pc_id ID] [--profile PROFILE] [--use USE]
```

### `spellcaster validate`

Validate the Chaudron (spell files, schemas, references).

```bash
spellcaster validate <chaudron_path> [-b BRANCH] [-l LABEL]
```

### `spellcaster test`

Run post-cast validation on a produced NavyaDrive.

```bash
spellcaster test --path <navya_drive_path>
```

### `spellcaster apply_changes`

Detect local changes in a NavyaDrive and optionally back-propagate them to the Chaudron.

```bash
# Preview changes
spellcaster apply_changes /path/to/navya_drive --dryrun

# Apply changes back to chaudron
spellcaster apply_changes /path/to/navya_drive
```

### `spellcaster lookup`

Dump the inventory for a Chaudron.

```bash
spellcaster lookup <chaudron_path>
```

### `spellcaster format`

Format all `.conf` (JSON) files in the Chaudron with consistent indentation.

```bash
spellcaster format <chaudron_path> [--verbose]
```

### `spellcaster man`

Open the Spellcaster documentation in a web browser.

### Other CLI entry points

| Command | Entry point | Purpose |
|---------|-------------|---------|
| `spellcaster` | `spellcaster.caster:main` | Main CLI |
| `spellcaster-install` | `spellcaster_tools.install:main` | Installer helper (setup env vars, install deps) |
| `symlink-nvd` | `spellcaster_tools.symlink_nvd:main` | Create NavyaDrive/site/vehicle symlinks |

## .spell File Format

A `.spell` file is a YAML list of spell entries. Each entry describes a file/directory to include in the cast. Only **one** `.spell` file per directory is allowed.

### Schema (spell_book_schema.yml)

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `source` | string | Yes | - | Relative path to source file/dir from spell directory. Use `\|` to merge multiple `.conf` files |
| `destination` | string | Yes | - | Path in the destination NavyaDrive tree |
| `pc_target` | dict | No | - | Vehicle-to-PC mapping. Keys: `all`, `shuttle`, `tract`, `shuttle/evo3`, etc. Values: list of PC IDs |
| `software_target` | list | No | - | List of software names this spell targets |
| `use` | string | No | `prod` | Environment: `dev`, `test`, or `prod` |
| `owners` | list | Yes | - | Email addresses of file owners |
| `users` | list | Yes | - | Email addresses of impacted teams |
| `executable` | boolean | No | `false` | Set Unix execute permission on destination |

### Example: Local file copy

```yaml
- source: resource_diag_shuttle.rtd
  destination: resource_diag.rtd
  owners:
    - driving@navya.tech
  users:
    - simulation@navya.tech
  pc_target:
    shuttle/evo3: [1]
  use: dev
  executable: True
```

### Example: Merging .conf files

Multiple `.conf` sources separated by `|` are merged into one output. Last file wins on key conflicts. All merged keys must have the same type.

```yaml
- source: base.conf | specific_pc3.conf
  destination: conf.d/rtmaps.conf
  owners:
    - integration@navya.tech
  users:
    - teams@navya.tech
  pc_target:
    shuttle: [0, 1, 2, 3]
```

### Example: Fetching from Doyle/Conan remote

Use the `<repo_name:doyle>` or `<repo_name:conan>` pattern in source to fetch artifacts from remote repositories:

```yaml
# Doyle (meta-conan) pattern - fetches from Conan via frozen file resolution
- source: <rd-conan-int:doyle>project_name/project_name_component.pck
  destination: lib/internal/pck/COMPONENT.pck
  owners:
    - team@navya.tech
  users:
    - other@navya.tech
  pc_target:
    all: [1, 2]

# Conan pattern - fetches directly from Conan repo
- source: <my_repo:conan>project/user/channel/version/bin/executable
  destination: project/bin/executable
  owners:
    - team@navya.tech
  users:
    - other@navya.tech
  pc_target:
    all: [1]

# Generic remote pattern
- source: <repo_name>project_name/version/file_path
  destination: path/in/destination
  owners:
    - team@navya.tech
  users:
    - other@navya.tech
  pc_target:
    all: [1]
```

### `pc_target` patterns

- `all: [1, 2]` - All vehicle types, PCs 1 and 2
- `shuttle: [0, 1, 2, 3]` - All shuttle architectures, PCs 0-3
- `shuttle/evo3: [2, 3]` - Shuttle evo3 only, PCs 2 and 3
- `shuttle/evo3/base: [1]` - Shuttle evo3 base revision, PC 1

## Inventory File Format (`.inventory`)

Located at the Chaudron root. Defines vehicle platforms, architectures, and PCs.

```yaml
inventory:
  - type: shuttle
    arch: evo3
    revision: base
    profiles:
      - ubuntu_18_04
      - ubuntu_22_04_armv8.jinja
    pcs:
      - id: 0
        profile: ubuntu_18_04
        os: linux
        arch: x64
        compiler: gcc7
        distro: ubuntu18
      - id: 1
        profile: ubuntu_18_04
        os: linux
        arch: x64
        compiler: gcc7
        distro: ubuntu18
      - id: 2
        profile: ubuntu_24_04
        os: linux
        arch: x64
        compiler: gcc13
        distro: ubuntu24
      - id: 3
        profile: ubuntu_22_04_armv8.jinja
        os: linux
        arch: armv8
        compiler: gcc11
        distro: ubuntu22
  - type: tract
    arch: boulonnais
    revision: base
    profiles:
      - ubuntu_18_04
    pcs:
      - id: 0
        os: linux
        arch: x64
        compiler: gcc7
        distro: ubuntu18
      # ... more PCs
```

### Inventory schema fields

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| `type` | string | `shuttle`, `tract` | Vehicle category |
| `arch` | string | `evo3`, `boulonnais` | Vehicle architecture |
| `revision` | string | `base`, `variant1`-`variant3` | Hardware revision (optional) |
| `profiles` | list | Conan profile names | Build profiles |
| `pcs[].id` | integer | 0+ | PC identifier |
| `pcs[].os` | string | `linux` | Operating system |
| `pcs[].arch` | string | `x64`, `armv8` | CPU architecture |
| `pcs[].compiler` | string | `gcc7`, `gcc11`, `gcc13` | Compiler |
| `pcs[].distro` | string | `ubuntu18`, `ubuntu22`, `ubuntu24` | Linux distribution |
| `pcs[].profile` | string | profile name | Conan profile for this PC |

## Requirements File Format (`requirements.yaml`)

Lists Conan packages needed for the cast. Validated against `requirements_schema.yaml`.

```yaml
requirements:
  - profiles:
      - ubuntu_18_04
    packages:
      - ref: driving_planner/[^1.0]@navya/stable
        activated: true
        pc_target:
          all: [1]
      - ref: Boost/[^1.79.0]@moris/stable
        activated: true
    options:
      - "driving_planner:shared=True"
```

### Package reference format

> See the **navya** skill for the full Conan reference format (`name/version@user/channel`), version range conventions, and user/channel values.

## Chaudron Repository Structure

```
chaudron/
  .inventory                    # Vehicle/PC definitions
  .spellcasterignore            # Files ignored by spellcaster
  .gitlab-ci.yml                # CI pipeline (sets SPELLCASTER_VERSION)
  version.raw.txt               # Project version (e.g., v10.6.0)
  requirements.yaml             # Conan package manifest
  requirements_schema.yaml      # Schema for requirements
  spell_book_schema.yml         # Schema for .spell files
  inventory_schema.yml          # Schema for .inventory
  rules_schema.yaml             # Rules schema
  bin/                          # Runtime scripts (launch_navya_drive.sh, etc.)
  conf.d/                       # Configuration resources with .spell markers
    runtime/                    # Runtime configs (.conf JSON files)
      .spell
    rtmaps/                     # RTMaps configs
      .spell
    sensors/                    # Sensor configs
      .spell
  lib/                          # Packaged binary resources
    internal/                   # Internal Navya packages
      pck/                      # RTMaps packages (.pck)
        .spell
      shared/                   # Shared libraries
        .spell
    external/                   # Third-party packages
      pck/
        .spell
  tools/                        # Utility scripts and helpers
  frozen_files/                 # Pinned package versions (*_frozen.txt)
  validator/                    # CI validation scripts
    validators.yaml             # Validator registry
    check_all_files_referenced_in_spells.py
    check_spellcaster_version.py
    check_packages_coherence.py
    check_grimoire.py
    # ... more validators
  doc/                          # Documentation
  .gitlab/                      # CI documentation and MR templates
    README.md                   # Pipeline docs
```

## Spellcaster Source Structure

```
spellcaster/
  src/spellcaster/
    caster.py                   # CLI: parse_args, main, command handlers
    spell_caster.py             # Core SpellCaster class, casting orchestration
    spell.py                    # Spell model, parsing, repo patterns
    configuration.py            # Configuration class, YAML config loading
    spellcaster.yaml            # Default config (cast_timeout, check_update)
    target.py                   # Target model (vehicle/PC resolution)
    inventory.py                # Inventory loading and schema
    requirement.py              # Requirements/Conan reference handling
    validator.py                # Post-cast validators
    spell_validator.py          # Spell schema validation (Cerberus)
    frozen_file_validator.py    # Frozen file validation
    diff_caster.py              # Diff between two setups
    repo_client.py              # Abstract repo client interface
    basic_repo_client.py        # Generic artifact fetcher
    conan_repo_client.py        # Conan package fetcher
    doyle_repo_client.py        # Doyle/meta-conan fetcher
    grimoire_files_manager.py   # Grimoire .conf merge support
    lookup_table.py             # Change detection for apply_changes
    s3_repo.py                  # S3 upload for configs
    fetch_strategy.py           # Caching/no-caching fetch strategies
    spell_match.py              # Spell-to-target matching
    coordinates.py              # Coordinate matching
    utils.py                    # YAML/JSON IO, helpers
    jinja_env.py                # Jinja template helpers
    resources/
      setup.conf.template       # Template for generated setup.conf
      conanfile.py.in            # Conan recipe templates
  src/spellcaster_tools/
    install.py                  # spellcaster-install CLI
    symlink_nvd.py              # symlink-nvd CLI
    environment_variables.py    # Env var setup helpers
  tests/
    unit/                       # Unit tests
    integration/                # Integration tests with chaudron fixtures
      data/chaudron/            # Test chaudron fixture
  docs/usage/
    overview.rst                # Usage overview
    spell.rst                   # Spell file documentation
    inventory.rst               # Inventory documentation
    installer.rst               # Installer documentation
    doyle.rst                   # Doyle integration docs
    config.rst                  # Configuration docs
  docker/                       # CI Dockerfiles
```

## Generated setup.conf

When Spellcaster casts a NavyaDrive, it generates a `setup.conf` in Grimoire JSON format containing metadata:

```json
{
    "tag": { "value": "<git_tag>", "type": "string", "overridable": false },
    "commit": { "value": "<commit_hash>", "type": "string", "overridable": false },
    "version": { "value": "<chaudron_version>", "type": "string", "overridable": false },
    "spellcaster_version": { "value": "<spellcaster_version>", "type": "string", "overridable": false },
    "environment": { "value": "<use>", "type": "enum", "overridable": false },
    "pc": { "value": "pc<id>", "type": "enum", "overridable": false },
    "packages": { "value": ["<pkg1>", "<pkg2>"], "type": "list", "overridable": false }
}
```

## Spellcaster Configuration

Located at `<package_dir>/spellcaster/spellcaster.yaml`:

```yaml
behaviors:
  cast_timeout:
    value_in_minutes: 20    # Timeout for cast operations
  check_update:
    enabled: false          # Auto-check for spellcaster updates
```

To locate: `python3 -m pip show spellcaster` then append `/spellcaster/spellcaster.yaml`.

## Environment Variables

> See the **navya** skill for shared Navya environment variables and Artifactory authentication (`ARTIFACTORY_API_KEY`, `LDAP_USERNAME`, `GITLAB_ACCESS_TOKEN`, `NAVYA_ROOT_INSTALL_PATH`, `NAVYA_PRODUCT_TYPE`).

Spellcaster-specific variables:

| Variable | Purpose | Default |
|----------|---------|---------|
| `SPELL_CASTER_CACHE` | Local cache directory for fetched artifacts | (none) |
| `TARGET_OS` | Target OS for installer uploads | (none) |
| `TARGET_ARCH` | Target architecture for installer uploads | (none) |

## Chaudron CI Pipeline

Defined in `.gitlab-ci.yml`, includes external CI templates from `integration-automation/ci`.

### Key CI variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `SPELLCASTER_VERSION` | Pinned Spellcaster version used in CI | `2.4.0` |
| `PLATFORMS` | Vehicle platforms to cast | `shuttle/evo3, tract` |
| `KITT_VERSION` | Test framework version | `6.7.1` |
| `MORIARTY_VERSION` | Test tool version | `0.24.7` |

### CI stages

1. **Validate** - Runs validators (see `validator/validators.yaml`) checking spell files, package coherence, grimoire configs, spellcaster version
2. **Generate** - Rebuilds Conan packages from `requirements.yaml` if needed
3. **Build/Cast** - Produces NavyaDrive artifacts for each platform/PC
4. **Test** - Runs NRT (Non-Regression Tests) against casted artifacts
5. **Report** - Generates pipeline reports

### Key validators (in `validator/`)

| Validator | What it checks |
|-----------|---------------|
| `check_all_files_referenced_in_spells.py` | All spell sources exist; imports `SpellCaster` |
| `check_spellcaster_version.py` | Local spellcaster version matches expected; imports `get_spellcaster_version` |
| `check_packages_coherence.py` | Frozen file package consistency; imports `ConanReference` |
| `check_all_packages_referenced.py` | All packages in requirements are used |
| `check_grimoire.py` | Grimoire `.conf` file format correctness |
| `check_grimoire_keys.py` | Grimoire configuration key validity |
| `check_no_local_path.py` | No hardcoded local paths in spell sources |
| `check_canonization.py` | RTMaps diagram canonization |
| `check_json_format.py` | JSON `.conf` file formatting |

## Common Workflows

### Cast a dev NavyaDrive locally

```bash
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use dev --default --default_config
```

### Cast production with installer

```bash
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use prod --installer deb --upload
```

### Validate chaudron before committing

```bash
spellcaster validate ~/dev/chaudron
```

### Check what changed in a NavyaDrive

```bash
spellcaster apply_changes /opt/navya/navya_drive --dryrun
```

### Back-propagate changes to chaudron

```bash
spellcaster apply_changes /opt/navya/navya_drive
```

### Freeze package versions

```bash
spellcaster freeze ~/dev/chaudron --vehicle_type shuttle --pc_id 1 --use prod
```

### Format all .conf files

```bash
spellcaster format ~/dev/chaudron --verbose
```

### Set NavyaDrive as default

```bash
symlink-nvd /opt/navya/navya_drive
symlink-nvd --type site /opt/navya/site
symlink-nvd --type vehicle /opt/navya/vehicle
```

## Developing Spellcaster

```bash
cd ~/dev/spellcaster
pipx install pdm       # If not installed
pdm install            # Install dependencies
pdm test               # Run tests
pdm run spellcaster --version  # Verify
```

### Key patterns

- **CLI**: argparse-based in `caster.py` (lines 485-773). Commands return int exit codes; `main_args()` calls `sys.exit(args.func(args))`
- **Spell parsing**: `spell.py` loads `.spell` YAML and parses source patterns (`<repo:type>` for remote, plain paths for local)
- **Repo clients**: `repo_client.py` defines the interface. Implementations: `basic_repo_client.py`, `conan_repo_client.py`, `doyle_repo_client.py`
- **Schema validation**: Cerberus validators in `spell_validator.py` against `spell_book_schema.yml`
- **Config IO**: `utils.py` uses `ruamel.yaml` for YAML, `json` module for `.conf` files
- **Templating**: Jinja2 for `setup.conf.template` and Doyle conanfile templates

### Adding a new repo type

1. Create `src/spellcaster/new_repo_client.py` implementing the repo client interface
2. Register the new pattern type in `spell.py` (`parse_pattern`)
3. Wire it in `caster.py` where repo clients are constructed

## Working with Chaudron

### Adding a new spell

1. Create or edit the `.spell` file in the appropriate `conf.d/` or `lib/` directory
2. Follow the `spell_book_schema.yml` schema
3. Ensure referenced source files exist
4. Set correct `pc_target` matching inventory entries
5. Set `owners` and `users` email addresses
6. Run `spellcaster validate ~/dev/chaudron` to verify

### Adding a new package dependency

1. Add the Conan reference to `requirements.yaml` under the matching profile
2. Set `activated: true` and appropriate `pc_target`
3. Add spell entries in `.spell` files for the package's artifacts
4. Run validation: `spellcaster validate ~/dev/chaudron`

### Modifying grimoire configuration

> See the **grimoire** skill for the `.conf` JSON format (value/type/overridable/validation) and C++ API.

1. Edit `.conf` JSON files under `conf.d/`
2. Follow grimoire JSON format (value, type, overridable, validation)
3. Run `spellcaster format ~/dev/chaudron` to ensure consistent formatting
4. If merging configs, use `source: a.conf | b.conf` syntax in `.spell`

### .spellcasterignore

Works like `.gitignore` - lists files/directories Spellcaster should skip during validation. Located at chaudron root.

## NavyaDrive File System Layout

> See the **navya** skill for the complete NavyaDrive filesystem layout.

Spellcaster produces this layout during a cast. Key points for spell authors:

- `navya_drive/etc/conf.d/` — GLOBAL scope configs (`.conf` JSON files). Spellcaster generates `setup.conf` here.
- `navya_drive/bin/` — Runtime scripts and executables
- `navya_drive/lib/internal/pck/` — Internal RTMaps packages
- `navya_drive/lib/external/pck/` — External RTMaps packages
- `site/conf.d/`, `vehicle/conf.d/`, `features/<name>/conf.d/` — Scope override directories (cast with `--default_config` creates example symlinks)

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `spell validation failed` | Run `spellcaster validate <chaudron>` and fix reported errors |
| `source file not found in spell` | Check relative path from `.spell` directory to source |
| `pc_target references unknown vehicle/PC` | Verify `.inventory` has matching type/arch/revision and PC id |
| `cast timeout` | Increase `cast_timeout` in `spellcaster.yaml` or check network for remote fetches |
| `ARTIFACTORY_API_KEY not set` | Export the env var or run `spellcaster-install` which prompts for it |
| `cache not set` | Set `SPELL_CASTER_CACHE` env var to a local directory |
| `version mismatch in CI` | Update `SPELLCASTER_VERSION` in chaudron `.gitlab-ci.yml` |
| `grimoire merge type conflict` | All merged `.conf` keys must have identical `type` field |
| `frozen file validation error` | Regenerate with `spellcaster freeze` for the target platform |
| `format errors in .conf` | Run `spellcaster format <chaudron>` to auto-fix JSON formatting |

## Related Skills

- **navya**: Ecosystem overview, shared infrastructure, NavyaDrive layout, cross-tool workflows
- **doyle**: C++ workspace manager (builds the Conan packages that spellcaster fetches via `<repo:doyle>` patterns)
- **grimoire**: Configuration library (`.conf` JSON format used in chaudron's `conf.d/` resources)
- **rtmaps**: RTMaps middleware (`.pck` packages deployed by spells, `.rtd` diagrams as chaudron resources, `rtmaps.conf` configuration)
- **navya-git-flow**: EC workflow and chaudron integration (`spellcaster freeze`, `requirements.yaml` updates, CI labels)
