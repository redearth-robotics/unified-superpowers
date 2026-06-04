---
name: navya
description: Navya autonomous vehicle development ecosystem. Umbrella skill that routes to specialized sub-skills (doyle, grimoire, spellcaster) and provides shared infrastructure knowledge. Use for any Navya project work, Conan packaging, Artifactory, GitLab CI, NavyaDrive filesystem, or cross-tool workflows. Triggers - 'navya', 'NavyaDrive', '/opt/navya', 'Conan reference', 'artifactory', 'navya_drive', 'conan profile', 'navya/stable', 'moris/stable', 'Navya project', 'vehicle platform'.
---

# Navya Development Ecosystem

Navya builds autonomous vehicle software. The development ecosystem consists of three primary internal tools plus RTMaps middleware, together covering the full lifecycle from C++ code to deployed vehicle runtime:

```
  Source Code ──► Build & Package ──► Configure ──► Compose & Deploy ──► Execute
                    (Doyle)          (Grimoire)     (Spellcaster)        (RTMaps)
```

| Tool | Role | Domain |
|------|------|--------|
| **Doyle** | C++ workspace & build manager | Wraps Conan/CMake. Manages `project.yaml`, dependencies, builds, uploads |
| **Grimoire** | Configuration library (C++) | URI-based typed access to `.conf` JSON files with scoped overrides |
| **Spellcaster** | Drive composition CLI (Python) | Casts a Chaudron recipe repo into a NavyaDrive runtime or installer |
| **RTMaps** | Real-time data-flow middleware | Component-based runtime for perception, decision, actuation pipelines |

## Skill Routing Table

When the user's request matches a trigger, load the corresponding skill for deep reference. **Always load `navya` alongside the specific skill** for shared context.

| User Intent / Trigger | Load Skill | Why |
|---|---|---|
| `project.yaml`, `doyle clone/build/edit/upload`, C++ build, editable dependencies, Conan workspace | **doyle** | C++ project management |
| `config:/`, `readBooleanConfiguration`, `grimoire::Core`, `.conf` file C++ API, `Scope::AUTO`, configuration_checker | **grimoire** | C++ configuration library API |
| `spellcaster cast/freeze/validate`, `.spell` files, chaudron, inventory, `requirements.yaml`, frozen files, NavyaDrive casting | **spellcaster** | Drive composition and deployment |
| `project.yaml` dependencies referencing `libraries_grimoire` | **doyle** + **grimoire** | Build + config integration |
| Editing `.conf` JSON files inside chaudron's `conf.d/` | **spellcaster** + **grimoire** | Spell recipes use grimoire format |
| `.spell` source with `<repo:doyle>` pattern | **spellcaster** + **doyle** | Spellcaster fetches doyle-built artifacts |
| `MAPSComponent`, `MAPS_OUTPUT`, `InputReader`, `.rtd` diagram, `.pck` package, `rtmaps_runtime` | **rtmaps** | RTMaps component development and runtime |
| RTMaps component with `project.yaml` (type: pck) | **rtmaps** + **doyle** | Build RTMaps packages via Doyle |
| `.pck` deployment in `.spell` files, `.rtd` diagrams in chaudron | **rtmaps** + **spellcaster** | Deploy RTMaps artifacts to NavyaDrive |
| `rtmaps.conf` or grimoire reads in RTMaps component | **rtmaps** + **grimoire** | RTMaps runtime configuration |
| `ec/` branch, EC release, git flow, integration, merge to main, stabilization | **navya-git-flow** | EC workflow and chaudron integration |
| `requirements.yaml` update for EC, frozen files, CI labels (`EC_READY`/`EC_MATURE`) | **navya-git-flow** + **spellcaster** | Package integration and freeze |
| `doyle upload -c ec-*`, EC tag, channel management | **navya-git-flow** + **doyle** | EC package release |
| Cross-tool workflow, release pipeline, "how do these tools fit together" | **navya** (this skill) | Lifecycle overview |
| Conan reference format, Artifactory auth, GitLab CI variables | **navya** (this skill) | Shared infrastructure |

## Shared Infrastructure

### Conan Package Manager

All Navya C++ projects use Conan (v1.x) for dependency management.

**Reference format:**

```
name/version@user/channel
```

| Component | Values | Examples |
|---|---|---|
| `name` | `snake_case` project name | `driving_planner`, `libraries_grimoire` |
| `version` | Exact or caret range | `1.0.0`, `[^1.2]`, `[^2.9]` |
| `user` | `navya` (internal), `moris` (external/SDE) | |
| `channel` | `stable` (released), `dirty` (WIP), `local` (local build) | |

**Version ranges** — always use caret ranges for dependencies, never pin exact versions:

```yaml
# CORRECT
- ref: Boost/[^1.79.0]@moris/stable       # >=1.79.0 <2.0.0
- ref: libraries_spline/[^1.2]@navya/stable  # >=1.2.0 <2.0.0

# WRONG - pinned
- ref: Boost/1.79.0@moris/stable
```

**Conan remotes:**

| Remote | URL | Content |
|---|---|---|
| `navya-int` | Artifactory-hosted | Internal Navya packages |
| `rd-conan-int` | Artifactory-hosted | R&D internal packages (used in `.spell` doyle patterns) |

**Conan profiles** define target platform (OS/arch/compiler). Common profiles:

| Profile | OS | Arch | Compiler |
|---|---|---|---|
| `ubuntu_18_04` | Linux | x64 | gcc7 |
| `ubuntu_22_04` | Linux | x64 | gcc11 |
| `ubuntu_24_04` | Linux | x64 | gcc13 |
| `ubuntu_22_04_armv8.jinja` | Linux | armv8 | gcc11 |

### Artifactory & Authentication

Central artifact repository for Conan packages, Python packages, and installers.

| Variable | Used by | Purpose |
|---|---|---|
| `ARTIFACTORY_API_KEY` | Spellcaster | Fetch/upload packages and installers |
| `ARTIFACTORY_ID_TOKEN` | Doyle | Conan package upload authentication |
| `LDAP_USERNAME` | Spellcaster | Artifactory login (fallback: system username) |
| `GITLAB_ACCESS_TOKEN` | Spellcaster | GitLab HTTPS Conan config install |

**Artifactory URL**: `https://artifactory.navya.tech`
**PyPI proxy**: `https://artifactory.navya.tech/artifactory/api/pypi/rd-python-proxy/simple`

### GitLab CI/CD

All Navya repos use GitLab CI. Common patterns:

- **Chaudron CI** (`.gitlab-ci.yml`): Sets `SPELLCASTER_VERSION`, includes `integration-automation/ci` templates, runs validators then cast/test stages
- **C++ project CI**: Typically uses doyle for build/test, uploads packages to Artifactory
- **Spellcaster CI**: PDM-based test/build, Docker image publishing

**Documentation server**: `https://doc.navya.tech`
**GitLab**: `https://gitlab.navya.tech`

### NavyaDrive File System Layout

The standard runtime filesystem used by all Navya vehicles. Grimoire reads/writes configs here; Spellcaster produces this layout during a cast.

```
/opt/navya/                         # Default root (env: NAVYA_ROOT_INSTALL_PATH)
  navya_drive/                      # Product type dir (env: NAVYA_PRODUCT_TYPE)
    etc/
      conf.d/                       # GLOBAL scope configs (.conf JSON, read-only defaults)
        setup.conf                  # Generated by Spellcaster (cast metadata)
        runtime.conf                # Runtime configuration
        rtmaps.conf                 # RTMaps configuration
        driving.conf                # Driving parameters
        sensors.conf                # Sensor configuration
        ...
    bin/                            # Runtime scripts and executables
      launch_navya_drive.sh         # Main runtime launcher
      start_circus.sh               # Service manager
    lib/                            # Libraries and packages
      internal/pck/                 # Internal RTMaps packages (.pck)
      external/pck/                 # External RTMaps packages (.pck)
      internal/shared/              # Shared libraries
  site/
    conf.d/                         # SITE scope overrides (site-specific tuning)
  vehicle/
    conf.d/                         # VEHICLE scope overrides (per-vehicle tuning)
  features/
    features.conf                   # Feature enable/disable registry
    <feature_name>/
      conf.d/                       # FEATURE scope overrides
```

**Scope cascade** (Grimoire reads in this priority): VEHICLE > SITE > FEATURE > GLOBAL

| Env Variable | Purpose | Default |
|---|---|---|
| `NAVYA_ROOT_INSTALL_PATH` | Override root path | `/opt/navya` |
| `NAVYA_PRODUCT_TYPE` | Override product type directory | `navya_drive` |

### Naming Conventions

| What | Convention | Examples |
|---|---|---|
| C++ project names | `snake_case`: `team_component` | `driving_planner`, `sensors_lidar_fusion_karui`, `libraries_grimoire` |
| Team prefixes | Department-based | `driving_`, `sensors_`, `localisation_`, `mission_`, `hmi_`, `diagnostic_`, `libraries_`, `simulation_` |
| Conan packages | Same as project name | `driving_planner/[^1.0]@navya/stable` |
| RTMaps packages (.pck) | `CATEGORY_name.pck` in destination | `DRIVING_control_trajectory_tracker.pck`, `PERCEPTION_localisation_imu.pck` |
| Grimoire config files | `category.conf` | `driving.conf`, `sensors.conf`, `runtime.conf` |
| Grimoire URIs | `config:/basename/section/option` | `config:/driving/limits/maxSpeed` |

### Vehicle Platforms

Current inventory (from Chaudron):

| Type | Architecture | Revision | PCs |
|---|---|---|---|
| `shuttle` | `evo3` | `base` | PC0 (x64/gcc7), PC1 (x64/gcc7), PC2 (x64/gcc13), PC3 (armv8/gcc11) |
| `tract` | `boulonnais` | `base` | PC0, PC1, PC2 (all x64/gcc7) |

PC roles (typical):
- **PC0**: Infrastructure/gateway
- **PC1**: Decision/driving/mission
- **PC2**: Perception/sensors/localization
- **PC3**: GPU/ML inference (shuttle only, armv8)

## Cross-Tool Workflows

### 1. New C++ Project → Package → Deploy

```
Developer writes C++ code
    │
    ▼
┌─────────────────────────────────────┐
│  DOYLE: Build & Package             │
│  1. doyle clone / doyle init        │
│  2. Edit project.yaml               │
│  3. doyle build setup -u -b missing │
│  4. cmake && make                    │
│  5. doyle upload -c stable          │
└──────────────┬──────────────────────┘
               │ Conan package uploaded to Artifactory
               ▼
┌─────────────────────────────────────┐
│  CHAUDRON: Add to recipes           │
│  1. Add ref to requirements.yaml    │
│  2. Create/edit .spell file         │
│  3. spellcaster validate            │
│  4. Commit & push to chaudron       │
└──────────────┬──────────────────────┘
               │ CI pipeline runs
               ▼
┌─────────────────────────────────────┐
│  SPELLCASTER: Cast NavyaDrive       │
│  1. spellcaster freeze (pin vers.)  │
│  2. spellcaster cast (produce NVD)  │
│  3. spellcaster test (validate)     │
│  4. Optionally: --installer deb     │
└─────────────────────────────────────┘
```

### 2. Add Configuration to a C++ Project

```bash
# 1. In your C++ project's project.yaml, add grimoire dependency (DOYLE)
#    library.dependencies.internals:
#      - ref: libraries_grimoire/[^2.9]@navya/stable

# 2. Rebuild
doyle build setup -u -b missing

# 3. In your C++ code, use grimoire API (GRIMOIRE)
#    grimoire::Core config;
#    double speed = config.readDoubleConfiguration("config:/driving/limits/maxSpeed", 5.0);

# 4. Create/edit the .conf file in chaudron (SPELLCASTER/GRIMOIRE format)
#    chaudron/conf.d/driving/driving.conf  (follows grimoire JSON format)

# 5. Create/edit the .spell in chaudron to include the .conf (SPELLCASTER)
#    chaudron/conf.d/driving/.spell

# 6. Validate
spellcaster validate ~/dev/chaudron
```

### 3. Debug a Configuration Issue

| Symptom | Likely tool | Action |
|---|---|---|
| Wrong config value at runtime | **Grimoire** | Check scope cascade: `config.getOverrideLocation(uri)`. Vehicle override may shadow global |
| Config file missing after cast | **Spellcaster** | Check `.spell` file has correct `pc_target` and `use` for your target |
| Package missing from cast | **Spellcaster** | Check `requirements.yaml` has package with `activated: true` and correct `pc_target` |
| Build fails: grimoire header not found | **Doyle** | Add `libraries_grimoire/[^2.9]@navya/stable` to `project.yaml` internals |
| `.conf` format error | **Grimoire** | Validate JSON structure: each leaf needs `value`, `type`. Run `spellcaster format` |
| Cast fetches wrong package version | **Spellcaster** | Check frozen files. Regenerate with `spellcaster freeze` |

### 4. Release Workflow

```bash
# 1. Freeze package versions for reproducibility
spellcaster freeze ~/dev/chaudron --vehicle_type shuttle --pc_id 1 --use prod

# 2. Cast production NavyaDrive with installer
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use prod --installer deb --upload

# 3. Upload configuration to S3
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use prod --upload-conf

# 4. Version is tracked via chaudron's version.raw.txt and git tags
```

### 5. Local Development Loop

```bash
# Cast a dev environment
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use dev --default --default_config

# Make changes to configs/diagrams in the NavyaDrive
# ... edit files under /opt/navya/navya_drive/ ...

# See what changed
spellcaster apply_changes /opt/navya/navya_drive --dryrun

# Back-propagate changes to chaudron source
spellcaster apply_changes /opt/navya/navya_drive

# Validate chaudron is still consistent
spellcaster validate ~/dev/chaudron
```

## Quick Command Reference

### Doyle (C++ Build)

```bash
doyle clone project/version@navya/stable    # Clone project
doyle build setup -u -b missing             # Setup build env
doyle edit add dependency_name              # Edit a dependency
doyle upload -c stable                      # Upload package
doyle create local --no-tests               # Local test package
```

### Spellcaster (Composition)

```bash
spellcaster cast <chaudron> shuttle/evo3/base 1 --use dev --default   # Cast
spellcaster validate <chaudron>                                        # Validate
spellcaster freeze <chaudron> --vehicle_type shuttle --pc_id 1         # Freeze
spellcaster apply_changes /opt/navya/navya_drive --dryrun              # Check changes
spellcaster format <chaudron>                                          # Format .conf files
```

### Grimoire (Configuration, C++)

```cpp
grimoire::Core config;
double val = config.readDoubleConfiguration("config:/driving/limits/maxSpeed", 5.0);
config.writeDoubleConfiguration(uri, 10.0, Scope::VEHICLE);
config.commit();
```

## Local Development Paths

| Repository | Path |
|---|---|
| Doyle | `/home/alaa.el-jawad/dev/doyle/doyle` |
| Spellcaster | `/home/alaa.el-jawad/dev/spellcaster` |
| Chaudron | `/home/alaa.el-jawad/dev/chaudron` |
| Grimoire | `git@gitlab.navya.tech:5x/grimoire.git` |
