---
name: doyle
description: Navya C++ workspace and build manager (Doyle). Use when working with project.yaml, running doyle commands (clone, build, edit, upload), creating C++ projects, managing editable dependencies, or Conan workspace operations. Triggers - 'doyle', 'project.yaml', 'build setup', 'conan workspace', 'C++ project build', 'editable dependencies', 'doyle clone', 'doyle build', 'doyle edit', 'doyle upload'.
---

# Doyle - Navya C++ Workspace Manager

Doyle is Navya's internal tool for managing C++ project workspaces. It wraps Conan (C/C++ package manager) to automate dependency management, CMake generation, and build environment setup.

**Source code**: `/home/alaa.el-jawad/dev/doyle/doyle`
**Version**: 0.39.1
**Entry point**: `doyle/command_line.py` -> `main()`
**Python package**: installed via `python3 -m pip install doyle` (or editable: `pip install -e .`)

## Core Concepts

- **Workspace**: A directory containing a root project + optional editable dependencies + generated build artifacts
- **`project.yaml`**: The single configuration file that defines a C++ project (name, version, dependencies, modules, apps, tests, features)
- **Editable dependency**: A project dependency whose source code is checked out locally for simultaneous development
- **Conan reference**: Package identifier format: `name/version@user/channel` (e.g., `driving_planner/1.0.0@navya/stable`)
 
> **Shared concepts** (Conan reference format, version ranges, Artifactory, NavyaDrive layout): See the **navya** umbrella skill.
> **Configuration files** (`.conf` JSON format, grimoire API): See the **grimoire** skill.
> **Drive composition** (`.spell` files, casting, chaudron): See the **spellcaster** skill.

## Nominal Workflow (Linux)

```bash
# 1. Create workspace and clone project
mkdir my_feature && cd my_feature
doyle clone project_name/version@navya/stable

# 2. Setup build environment (generates CMake, installs Conan deps)
doyle build setup -u -b missing

# 3. Run CMake and build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make

# 4. Load virtual environment before running executables
source activate.sh
# ... run executables ...
deactivate
```

## CLI Command Reference

### `doyle clone <reference>`
Clone and setup a project workspace from a Conan reference.

```
doyle clone <reference> [-W workspace_dir] [-r remote] [-f] [-g]
```

| Flag | Description |
|------|-------------|
| `<reference>` | Conan reference: `name/version@navya/stable` |
| `-W` | Workspace root directory (default: `.`) |
| `-r` | Conan remote (default: `navya-int`) |
| `-f` | Force: don't ask for confirmation to suppress existing sources |
| `-g` | Git checks: warn about uncommitted/unpushed changes |

### `doyle init <project_path>`
Create a workspace from an existing local C++ project directory.

```
doyle init <project_path> [-W workspace_dir] [-c channel]
```

| Flag | Description |
|------|-------------|
| `<project_path>` | Path to the root project directory |
| `-c` | Conan channel (default: `dirty`) |

### `doyle build setup`
Generate the build environment: creates CMakeLists.txt, conanfile.py, runs `conan workspace install`.

```
doyle build setup [-W workspace_dir] [-u] [-b policy] [-o options]
                  [--debug | --both] [--build-name name]
                  [--coverage Gcov|Coco] [--no-install]
                  [--vigilant-mode] [-pr profile] [-pr:b build_profile]
```

| Flag | Description |
|------|-------------|
| `-u` | Check for dependency updates |
| `-b missing` | Build missing dependencies from source |
| `-b` (no arg) | Build all dependencies from source |
| `-o Pkg:opt=val` | Set Conan option |
| `--debug` | Generate debug build env (build_Debug dir) |
| `--both` | Generate both Release and Debug envs |
| `--build-name X` | Custom build dir name: `build_X` |
| `--coverage Gcov` | Enable code coverage |
| `--no-install` | Skip `conan workspace install` |
| `--vigilant-mode` / `-vm` | Stricter compilation flags + sanitizers (gcc 9+ only) |
| `-pr` | Conan host profile |
| `-pr:b` | Conan build profile |

**Must run after**: `doyle clone`, changing edited dependencies, editing `project.yaml`.

### `doyle build check`
Check project options consistency against dependencies (currently validates AVX2 option consistency).

```
doyle build check [-W workspace_dir]
```

### `doyle build clean`
Remove the doyle directory and build artifacts.

```
doyle build clean [-W workspace_dir] [-f]
```

### `doyle edit` subcommands
Manage editable (source-checked-out) dependencies.

#### `doyle edit list`
List all editable dependencies. Edited ones are marked with `*`.

```
doyle edit list [-W workspace_dir] [-d depth]
```

| Flag | Description |
|------|-------------|
| `-d N` | Filter by dependency tree depth (default: all) |

#### `doyle edit add <dependencies...>`
Download dependency sources and set as editable. By default, transitive consumers are also added to prevent ABI conflicts.

```
doyle edit add <dep1> [dep2 ...] [-W workspace_dir] [-r remote] [-f] [-g] [--stand-alone]
```

| Flag | Description |
|------|-------------|
| `--stand-alone` | Only add specified deps (skip transitive consumers, legacy behavior) |
| `-g` | Git checks on folder deletion |
| `-f` | Force: don't ask for confirmation |

#### `doyle edit remove <dependencies...>`
Unset editable mode. By default, transitive sub-dependencies are also removed.

```
doyle edit remove <dep1> [dep2 ...] [-W workspace_dir] [-c] [-f] [-g] [--stand-alone]
```

| Flag | Description |
|------|-------------|
| `-c` / `--clear` | Delete source folders (rm -rf) |
| `-f` / `--force` | Skip confirmation prompts |
| `-g` | Git checks before deletion |
| `--stand-alone` | Only remove specified deps |

#### `doyle edit all`
Add all reachable dependencies as editable.

#### `doyle edit none`
Remove all edited dependencies. Supports `-c`, `-f`, `-g`.

#### `doyle edit update`
Recreate workspace to fix Conan cache issues after branch changes, rebases, or manual `project.yaml` edits.

#### `doyle edit export`
Export edited dependencies list to `editables.yaml` in the root project directory. Used for sharing feature branches.

#### `doyle edit import`
Read `editables.yaml` from root project and import all listed dependencies as editable.

### `doyle upload`
Create and upload a Conan package.

```
doyle upload [-W workspace_dir] [-r remote] [-c channel] [-u] [-o options]
             [--debug] [--create-only] [-pr profile] [-pr:b build_profile]
```

| Flag | Description |
|------|-------------|
| `-c` | Channel (default: `dirty`) |
| `--create-only` | Create package but don't upload |
| `--debug` | Create debug version |

### `doyle create local`
Create a local Conan package from current sources (no git tag needed). Package name: `project_name/version@navya/local`.

```
doyle create local [-W workspace_dir] [--no-tests] [-o options] [-u]
                   [--build-type Release|Debug] [-pr profile] [-pr:b build_profile]
```

### `doyle generate conanfile`
Generate a `conanfile.py` from root project that can be committed alongside `project.yaml`.

### `doyle require from-ref <reference>`
Generate `requires.yaml` from a Conan reference to force specific dependency versions.

```
doyle require from-ref <reference> [-r remote] [--package-id id]
```

### `doyle require from-frozen <frozen_file>`
Generate `requires.yaml` from a frozen file (for exact release rebuild).

### `doyle list consumers <reference>`
List all Artifactory packages that consume a given package.

```
doyle list consumers <reference> [-r repo] [-v]
```

### `doyle man`
Open Doyle's README in a browser.

### `doyle assist` subcommands
Internal tooling support.

| Subcommand | Description |
|---|---|
| `json_schema [-f project\|requires\|editables]` | Print JSON schema |
| `cli_arguments [-f bash\|json\|yaml\|zsh]` | Print CLI argument tree |
| `cli_completion` | Print shell completion script |
| `root_project_ref` | Print root project Conan reference |
| `root_project_dir` | Print root project source directory |
| `root_project_doyle_dir` | Print root project doyle directory |
| `requires_project_doyle_dir` | Print requires project doyle directory |

## `project.yaml` Reference

The project configuration file. Must be at the project root directory.

### Full Template

```yaml
header:
  schema_version: 1.0.0
general:
  name: project_name              # Required. snake_case. Convention: team_project (e.g., driving_planner)
  version: 1.0.0                  # Optional. Default: last git tag
  description: Short description  # Required
  url: git@gitlab.navya.tech:team/project.git  # Required
  cppstd: 17                      # Optional. Allowed: 11, 14, 17, 20, 23. Default: 11
  binary_naming: "2021"           # Optional. "legacy" or "2021". Default: "legacy"
  enable_avx2: True               # Optional. Default: None (not set)
library:
  directory: custom_dir           # Optional. Default: general.name
  shared: False                   # Optional. Default: False
  symbol_visibility: private      # Optional. "public"/"private". Default: "public" if shared, else "private"
  dependencies:
    externals:
      - ref: Boost/[^1.79.0]@moris/stable
        components:
          - system
          - date_time
      - ref: Eigen/[^3.2.4]@moris/stable
    internals:
      - ref: libraries_spline/[^1.0]@navya/stable
        options:
          - name: shared
            value: True
  cmakes:
    - name: CMAKE_AUTOMOC
      value: True
  defines:
    - name: MY_DEFINE
    - name: MY_VALUE_DEFINE
      value: 42
  features:
    - name: msgs
      protobuf_version: "[^3.21.4]"
      flatbuffers_version: "[^2.0.0]"   # Optional
      protobuf_shared: False             # Optional
    - name: rpc
      network_version: "[^0.5]"
      network_channel: stable
      rpc_version: "[^1.0]"
      rpc_channel: stable
    - name: qt
      version: "[^5.15.2]"
      components:
        - Core
        - Gui
    - name: qt_translate
      version: "[^5.15.2]"
      translations_module: translations
      languages: [en_US, fr_FR]
    - name: cuda
      version: "[^11.4.0]"
    - name: ros_msgs
      version: "[^1.0.0]"
    - name: pybind11_binding
      version: "[^2.3.0]"
      python_version: "3.8"   # Optional. Default: "3.6"
  modules:
    - name: core
      activated: True           # Optional. Default: True
      features:
        - name: protobuf        # deprecated - use msgs instead
          version: "[^3.21.4]"
      dependencies:
        externals: []
        internals: []
      defines: []
      cmakes: []
    - name: nurbs
applications:
  features:
    - name: qt
      version: "[^5.15.2]"
      components: [Core, Gui]
  list:
    - name: reader
      type: app                 # Required. Allowed: app, pck, nrt, nim
      activated: True           # Optional. Default: True
      dependencies:
        externals:
          - ref: Boost/[^1.79.0]@moris/stable
            components:
              - program_options
    - name: diagnostic_display
      type: pck
      dependencies:
        externals:
          - ref: RTMAPS/[^4.6.2]@moris/stable
tests:
  packaged: False               # Recommended: False. Default: True
  features:
    - name: boost_test
      version: "[^1.79.0]"
      shared: False             # Optional
    - name: qt_test
      version: "[^5.15.2]"
  list:
    - name: my_test
      activated: True
      defines:
        - name: WITH_BENCH
        - name: ITER_NUMBER
          value: 100
```

### Conan Reference Format

> See the **navya** skill for the full Conan reference format (`name/version@user/channel`), version range conventions, and remote definitions.

Key points for doyle:
- External deps: `Package/[^M.m.p]@moris/stable`
- Internal deps: `package_name/[^M.m]@navya/stable`
- Channels: `stable` (released), `dirty` (WIP/dev), `local` (local build)

## Standard Project Tree

```
project_name/
  app/
    app1/
      main.cpp
  doc/
    architectural/
      index.rst
    technical/
      index.rst
    index.rst
  modules/
    project_name/        # or library.directory value
      core/
        compute.cpp
        compute.h
      nurbs/
        ...
  msgs/
    project_name/
      msgs/
        result.proto
  qml/
    ProjectName/
      qmldir
      widget.qml
      ProjectNameQml.qrc
  resources/
    project_name/
      icon.png
    tests/
      path.xml
  tests/
    test1/
      TEST.cpp
  project.yaml
```

## Workspace Structure (after doyle build setup)

```
workspace_root/
  project_name/              # Root project sources (cloned)
    project.yaml
    modules/ app/ tests/ ...
  edited_dep_1/              # Editable dependency sources (if any)
  edited_dep_2/
  doyle/                     # Generated by doyle (DO NOT EDIT)
    project_name/
      conanfile.py
      CMakeLists.txt
      Find*.cmake
      app/ modules/ tests/ doc/
    edited_dep_1/
      ...
    workspace_requires/
      conanfile.py
  build/                     # Build directory
    activate.sh
    deactivate.sh
    workspace_requires/
      conan.lock
  build_Debug/               # If --debug or --both
  build_coverage/            # If --coverage
  build_X/                   # If --build-name X
  workspace.yaml             # Generated workspace config (DO NOT EDIT)
  layout.conf                # Generated layout (DO NOT EDIT)
  CMakeLists.txt             # Generated root CMake (DO NOT EDIT)
  requires.yaml              # Optional: force dependency versions
```

## Environment Variables

### Doyle Runtime

| Variable | Description | Values | Default |
|---|---|---|---|
| `CONAN_RUN_TESTS` | Run tests when rebuilding deps | `0`/`1` | `1` |
| `DOYLE_DISABLE_PARALLEL_TESTS` | Disable parallel test execution | `0`/`1` | `0` |
| `NAVYA_DOC_SRV_URL` | Documentation server URL | URL | `https://doc.navya.tech` |
| `ARTIFACTORY_ID_TOKEN` | Artifactory auth token (see **navya** skill) | string | (none) |

### Build Time

| Variable | Description | Values | Default |
|---|---|---|---|
| `DOYLE_DOXYGEN_QUIET` | Suppress Doxygen stdout | `YES`/`NO` | `NO` |
| `DOYLE_DOXYGEN_WARNINGS` | Show Doxygen warnings | `YES`/`NO` | `YES` |

## CMake Options (set via cmake -D)

| Option | Description |
|---|---|
| `SDE_WARNING_ALL` | `-Wpedantic` (default ON on Linux) |
| `SDE_WARNING_NORMAL` | `-Wall -Wextra -Wshadow` |
| `SDE_FAIL_ON_WARNING` | `-Werror` |
| `SDE_NO_WINDOWS_H` | `NOMINMAX` on Windows |
| `SDE_FORCE_COLORED_OUTPUT` | Force colored output (useful with ninja) |
| `PROJECT_NAME_MODULE_X` | Activate/deactivate module X |
| `PROJECT_NAME_APP_X` | Activate/deactivate app X |
| `PROJECT_NAME_TEST_X` | Activate/deactivate test X |
| `PROJECT_NAME_BUILD_SHARED_LIBS` | Build as shared library |
| `PROJECT_NAME_CPP_STD` | C++ standard |
| `PROJECT_NAME_BINARY_NAMING` | `legacy` or `2021` |
| `PROJECT_NAME_SYMBOL_VISIBILITY` | `public` or `private` |

## Auto-Generated C++ Headers

Doyle auto-generates two headers per project:

### `project_name/project_name_dll_import_export.h`
- `PROJECT_NAME_LOCAL` - Hidden visibility macro
- `PROJECT_NAME_API` - Public visibility macro

### `project_name/project_name_infos.h`
- `PROJECT_NAME_VERSION` - Version define
- `PROJECT_NAME_NAME` - Name define
- `PROJECT_NAME_GIT_DESCRIPTION` - Git description define
- `project_name_resources_path()` - Path to `resources/` directory
- `project_name_tests_resources_path()` - Path to test resources
- `project_name_messages_path()` - Path to `msgs/` directory

**Never commit `*_dll_import_export.h`** - it's generated in the build directory.

## Naming Conventions

- **Project names**: `snake_case`, format: `team_project_name`
  - Examples: `driving_trajectory_planner`, `libraries_maps_io`, `mission_fleet_manager`
- **Tests packaged**: Always set `tests.packaged: False`
- **Application types**: `app` (executable), `pck` (RTMaps package), `nrt` (NRT), `nim` (NIM)

## Error Codes

| Code | Name | Meaning |
|---|---|---|
| 0 | SUCCESS | |
| 1 | UNKNOWN_DEPENDENCY | Dependency not found in tree |
| 2 | ALREADY_EDITED_DEPENDENCY | Trying to add already-edited dep |
| 4 | CONFIG_FILE_DOESNT_EXIST | Missing workspace.yaml, project.yaml, or conanfile |
| 5 | BAD_CONFIG_FILE | Invalid project.yaml |
| 6 | BAD_PACKAGE_REFERENCE | Invalid Conan reference format |
| 9 | BAD_FROZEN_FILE | Invalid frozen file |
| 10 | RECIPE_DOWNLOAD_FAILED | Conan recipe download failed |
| 11 | INVALID_PROFILE | Profile incompatible (e.g., vigilant mode needs gcc 9+) |
| 12 | INCOMPATIBLE_OPTIONS | Options mismatch (e.g., AVX2 inconsistency) |

## `requires.yaml` Format

Force specific dependency versions:

```yaml
requires:
  - reference: project1/1.2.3@navya/stable
    override: True
  - reference: Boost/1.79.0@moris/stable
    override: True
```

After creating/modifying, run `doyle build setup`.

## `editables.yaml` Format

Share edited dependencies across developers:

```yaml
editables:
  - package_name: dep_name/1.0.0@navya/stable
    branch: feature/my_feature
```

Generated by `doyle edit export`, consumed by `doyle edit import`.

## Key Internal Files (for doyle development)

| File | Purpose |
|---|---|
| `doyle/command_line.py` | CLI entry point, all argparse definitions and command handlers |
| `doyle/workspace.py` | `DoyleWorkspace` and `DoyleWorkingTree` - workspace generation, conan install |
| `doyle/project_file.py` | `ProjectFile` - parses and validates `project.yaml` |
| `doyle/project_schema.py` | Cerberus validation schema for `project.yaml` |
| `doyle/project_components.py` | `Application`, `Module`, `Test` data classes |
| `doyle/project_features.py` | Feature extraction (protobuf, qt, cuda, msgs, rpc, etc.) |
| `doyle/dependency_manager.py` | Manages dependency tree from lockfile |
| `doyle/conan_utils.py` | Conan CLI wrappers (install, create, upload, download) |
| `doyle/conan_package.py` | `ConanPackage` - wraps Conan references |
| `doyle/lockfile.py` | Parses `conan.lock` files |
| `doyle/requires_project.py` | `RequiresProject` - manages `requires.yaml` |
| `doyle/editables_file.py` | `EditablesFile` - manages `editables.yaml` |
| `doyle/git_tools.py` | Git utilities (version extraction, status checks) |
| `doyle/templates/` | Jinja2 templates for CMakeLists, conanfile, helpers |
| `doyle/tests/` | Test suite |
| `doyle/version_factory.py` | Version resolution logic |
| `doyle/exceptions.py` | `DoyleException` and `ExitCode` enum |

## Common Patterns for Agents

### When user wants to build a project
```bash
doyle clone <reference>
doyle build setup -u -b missing
cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make
```

### When user wants to edit a dependency
```bash
doyle edit list                    # see available deps
doyle edit add <dep_name>          # add as editable
doyle build setup -u -b missing    # rebuild workspace
# make changes in <dep_name>/ directory
cd build && cmake .. && make       # rebuild
```

### When build fails with missing deps
```bash
doyle build setup -u -b missing    # -b missing rebuilds missing binaries
# or rebuild everything:
doyle build setup -u -b            # -b without arg = rebuild all
```

### When Conan cache is corrupted after branch switch
```bash
doyle edit update                  # recreates workspace cleanly
```

### Skip tests when rebuilding deps
```bash
CONAN_RUN_TESTS=0 doyle build setup -b missing
```

### Create a local test package
```bash
doyle create local --no-tests
# Package is available as: project_name/version@navya/local
```

### Modifying project.yaml
After any change to `project.yaml`, always run:
```bash
doyle build setup
```

### Checking project options consistency
```bash
doyle build check
```

## Troubleshooting

| Problem | Solution |
|---|---|
| `workspace.yaml doesn't exist` | Run `doyle clone` or `doyle init` first |
| `conanfile.py doesn't exist` | Run `doyle build setup` |
| `No lockfile in any build directory` | Run `doyle build setup` |
| Conan cache issues after branch change | Run `doyle edit update` |
| Missing dependency binaries | Use `-b missing` flag with `doyle build setup` |
| All tests fail on dep rebuild | Use `CONAN_RUN_TESTS=0` |
| Vigilant mode fails | Requires gcc 9+. Check profile with `conan profile show default` |
| AVX2 option mismatch | Ensure `enable_avx2` is consistent across project and dependencies |
| ABI conflicts with edited deps | Don't use `--stand-alone`; let doyle manage transitive editables |

## Developing Doyle Itself

```bash
cd /home/alaa.el-jawad/dev/doyle/doyle
python3 -m pip install --user -e .     # Install as editable
python3 -m pytest doyle/tests/         # Run tests
python3 -m doyle --version             # Verify installation
```

Style: flake8, max line length 80, Python 3.6+ compatible.
Dependencies: Cerberus, colorama, conan (<2.0), Jinja2, ruamel.yaml, semver, sphinx.


## Related Skills

- **navya**: Ecosystem overview, shared infrastructure, cross-tool workflows
- **grimoire**: C++ configuration library API (for reading/writing `.conf` files in code)
- **spellcaster**: Drive composition from chaudron recipes (consuming doyle-built packages)
- **rtmaps**: RTMaps middleware (RTMaps components are built as `type: pck` applications via Doyle)
- **navya-git-flow**: EC workflow and chaudron integration (EC tags, `doyle upload -c ec-*`, channel management)
