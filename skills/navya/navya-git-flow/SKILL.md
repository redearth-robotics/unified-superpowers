---
name: navya-git-flow
description: Navya git workflow for C++ projects and Chaudron integration. Covers EC (Evolution Candidate) branch creation, version tagging, Conan channel management, chaudron requirements.yaml updates, frozen files, CI labels (EC/EC_READY/EC_MATURE/FIX/HOTFIX), MR checklists, and local integration testing. Use when creating EC branches, releasing packages, integrating into chaudron, or managing the merge/stabilization process. Triggers - 'ec/', 'ec branch', 'git flow', 'integration', 'release', 'requirements.yaml update', 'frozen', 'EC_READY', 'EC_MATURE', 'stabilization', 'merge to main', 'chaudron MR', 'channel stable'.
---

# Navya Git Flow - EC Integration Workflow

This skill covers the end-to-end developer workflow for creating features in C++ projects and integrating them into Chaudron (the central integration repository) for vehicle deployment.

**Reference documentation**: https://doc.navya.tech/git-flow/2.0.6/index.html
**Chaudron**: `~/dev/chaudron` (GitLab: `integration/chaudron`)

> **Build & packaging**: See the **doyle** skill for `project.yaml`, build commands, `doyle upload`.
> **Drive composition**: See the **spellcaster** skill for casting, `.spell` files, `spellcaster freeze`.
> **Configuration**: See the **grimoire** skill for `.conf` file format and C++ API.
> **Ecosystem overview**: See the **navya** umbrella skill for shared infrastructure and cross-tool workflows.

## The Big Picture

```
Developer C++ Project                          Chaudron (Integration Repo)
========================                       ===========================

1. Create ec/feature branch          ────►  4. Create ec/feature branch
2. Develop & commit                         5. Update requirements.yaml
3. Tag & upload to Artifactory              6. Freeze dependencies
   (CI auto or doyle upload)                7. Open MR (EC label)
                                            8. CI: validate → generate → cast → test
                                            9. Stabilize → EC_MATURE label
                                           10. Merge to main → release tag
```

## Branch Naming Conventions

Both C++ projects and Chaudron use identical branch naming.

### Branch Types

| Branch | Purpose | Channel | Tag Format |
|--------|---------|---------|------------|
| `main` | Stable releases | `stable` | `vX.Y.Z` |
| `ec/*` | Evolution Candidates (features) | `ec-<name>` | `ecX.Y.Z-ec-<name>` |
| `maintenance/vA.B.C` | Bugfixes for a specific release | `m-<version>` | `vX.Y.Z-m-A.B.C` |
| `fix/<bug-id>` | Quick fix on main (no pre-release) | `stable` | _(none)_ |

### EC Naming Examples

The EC name is derived from the branch name after `ec/`:

| Branch | Channel | Tag Example |
|--------|---------|-------------|
| `ec/ramp-management` | `ec-ramp-management` | `ec1.3.0-ec-ramp-management` |
| `ec/dynamic-behavior` | `ec-dynamic-behavior` | `ec2.1.0-ec-dynamic-behavior` |
| `ec/loc/exwayz-ftw` | `ec-exwayz` | `ec0.10.4-ec-exwayz` |

**Convention**: Use the same `ec/<name>` branch name in both your C++ project and in Chaudron for traceability. The Conan channel usually matches the EC name.

### Product-Specific Maintenance

For vehicle-specific maintenance branches:

```
maintenance/asterix/vA.B.C   → tag: vX.Y.Z-m-A.B.C-asterix
maintenance/fleet-mgr/vA.B.C → tag: vX.Y.Z-m-A.B.C-fleet-mgr
```

## Channel Rules

Channels control which version of a package is consumed. They are enforced in Conan references and requirements.yaml.

| Branch Context | Allowed Dependency Channels |
|----------------|-----------------------------|
| `main` | `stable` only |
| `ec/*` | `stable` + `ec-<name>` |
| `maintenance/*` | `stable` + `m-<version>` |

**Key rule**: Before merging an EC to `main`, all `ec-<name>` channels in project dependencies must be turned to `stable`.

## Semantic Versioning

All C++ packages follow semver: `MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible new functionality
- **PATCH**: Backwards-compatible bug fixes

**Dependency consumption** uses caret ranges:

```yaml
# Consume all compatible versions within one major
- ref: libraries_spline/[^1.2]@navya/stable   # >=1.2.0, <2.0.0

# Consume across multiple majors (only when API breaks don't affect you)
- ref: some_lib/[>=2.0,<5]@navya/stable
```

## EC Workflow: C++ Project Side

### Step 1: Create EC Branch

```bash
# From the latest main
git checkout main
git pull origin main
git checkout -b ec/my-feature
```

### Step 2: Develop and Commit

Work on your feature. Keep changelog entries in the `[Unreleased]` section.

### Step 3: Create EC Release (Tag + Upload)

When you want to test your changes in Chaudron, create an EC release:

```bash
# 1. Set version in project.yaml (must include -ec- for Doyle EC detection)
#    general:
#      version: 1.3.0    # the semver part
#    Note: Doyle detects EC from the version containing "-ec-" OR from ec* tags

# 2. Create EC tag following the convention
git tag ec1.3.0-ec-my-feature
git push origin ec/my-feature --tags
```

**What happens next**: The project's GitLab CI pipeline detects the EC tag and:
1. Builds the package using Doyle
2. Uploads to Artifactory with channel `ec-my-feature`
3. Package becomes available as: `my_project/1.3.0@navya/ec-my-feature`

**Manual upload** (if CI is not set up or for quick testing):

```bash
# Upload with explicit EC channel
doyle upload -c ec-my-feature

# Or create a local-only package for testing
doyle create local --no-tests
# Available as: my_project/1.3.0@navya/local
```

### Step 4: Subsequent EC Releases

As you iterate, create new tags with bumped versions:

```bash
git tag ec1.3.1-ec-my-feature   # patch bump
git push origin ec1.3.1-ec-my-feature

git tag ec1.4.0-ec-my-feature   # minor bump (new functionality)
git push origin ec1.4.0-ec-my-feature
```

**Semver rules still apply** — bump major/minor/patch appropriately.

### EC Rebase (When main changes)

When another EC or fix merges to `main`, rebase your EC branch:

```bash
git checkout ec/my-feature
git rebase main
git push -f origin ec/my-feature
```

**Warning**: If you had tags on the old branch, delete them and recreate on the rebased branch to avoid dead references:

```bash
# Delete old tags
git push origin :ec1.3.0-ec-my-feature
git tag -d ec1.3.0-ec-my-feature

# Recreate on rebased branch
git tag ec1.3.0-ec-my-feature
git push origin ec1.3.0-ec-my-feature
```

## EC Workflow: Chaudron Side

### Step 5: Create EC Branch in Chaudron

```bash
cd ~/dev/chaudron
git checkout main
git pull origin main
git checkout -b ec/my-feature
```

### Step 6: Update requirements.yaml

Add or update your package reference to point to the EC channel:

```yaml
# In requirements.yaml, find the correct profile section and update:
requirements:
  - profiles:
      - ubuntu_18_04
    packages:
      # Change from stable to EC channel:
      - ref: my_project/1.3.0@navya/ec-my-feature
        activated: true
        pc_target:
          shuttle: [1, 2]
```

**Ref format**: `package_name/version@navya/ec-<name>`

**Real examples from chaudron**:

```yaml
- ref: libraries_ipc/1.8.5@navya/ec-header-stamps-and-geography
- ref: localisation_fusion_tools/0.10.4@navya/ec-exwayz
- ref: localisation_gnss_filter/7.9.2@navya/ec-protobuf-output
```

**Important**: If you changed multiple projects, update all their refs in requirements.yaml.

### Step 7: Freeze Dependencies

Frozen files pin exact package versions for reproducible casts. They are required before merge.

```bash
# Freeze for a specific target
spellcaster freeze ~/dev/chaudron --vehicle_type shuttle --pc_id 1 --use dev

# Freeze for production
spellcaster freeze ~/dev/chaudron --vehicle_type shuttle --pc_id 1 --use prod
```

This generates/updates files in `frozen_files/`:

```
frozen_files/
  shuttle_evo3_base_pc0_dev_frozen.txt
  shuttle_evo3_base_pc0_prod_frozen.txt
  shuttle_evo3_base_pc0_test_frozen.txt
  ...
```

Each frozen file contains one Conan reference per line:

```
Boost/1.79.0@moris/stable
libraries_ipc/1.8.5@navya/ec-header-stamps-and-geography
my_project/1.3.0@navya/ec-my-feature
...
```

**Note**: During `spellcaster cast`, if requirements.yaml is newer than the frozen file, spellcaster auto-regenerates the frozen file. But for CI/merge you should commit explicit frozen files.

### Step 8: Local Integration Testing

Before pushing, validate locally:

```bash
# 1. Validate chaudron structure
spellcaster validate ~/dev/chaudron

# 2. Cast a dev NavyaDrive locally
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use dev --default --default_config

# 3. Optionally cast to a temp directory to avoid overwriting system install
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use dev --destination_path /tmp/my_cast

# 4. Run post-cast validation
spellcaster test --path /opt/navya/navya_drive
```

### Step 9: Open MR in Chaudron

```bash
git add requirements.yaml frozen_files/
git commit -m "Add my_project EC for my-feature"
git push origin ec/my-feature
```

Open a Merge Request on GitLab using the **EC MR template** (`merge_request_ec.md`).

## Chaudron CI Pipeline & MR Labels

### Labels Control What CI Runs

The CI pipeline behavior is driven by MR labels:

| MR Labels | Validate | Packages | Casts | Diagrams | NRT |
|-----------|----------|----------|-------|----------|-----|
| _(Draft MR)_ | Auto | Auto | No | No | No |
| `EC` | Auto | Auto | No | No | No |
| `EC_READY` | Auto | Auto | Auto | Auto | Default |
| `EC_MATURE` | Auto | Auto | Auto | Auto | Default |
| `FIX` | Auto | Auto | Auto | Auto | Default |
| `HOTFIX` | Auto | Auto | Auto | Auto | Default |

**Typical label progression**:
1. Start with `EC` label → validation and packages only (quick feedback)
2. When ready for integration testing → add `EC_READY` → triggers casts and NRT
3. When stabilized → change to `EC_MATURE` → triggers full CI (same as EC_READY but signals maturity)
4. After RM review → `STATE_MATURE` → final approval signal

### CI Pipeline Stages

```
validate ──► generate ──► build ──► test ──► report
```

| Stage | What It Does |
|-------|-------------|
| **validate** | Grimoire config format, duplicates, package coherence, file references |
| **generate** | Rebuilds Conan packages if new versions detected |
| **build** | Casts NavyaDrive (saves as CI artifact, expires in 1 day) |
| **test** | Diagram validation (RTMaps .rtd consistency) + NRT (non-regression tests) |
| **report** | Aggregates NRT results into MR test report |

### Useful CI Variables

Override defaults in the GitLab pipeline UI:

| Variable | Purpose |
|----------|---------|
| `PLATFORMS` | Comma-separated list of platforms to build (default: `all`) |
| `FORCE_BUILD_CAST` | Force cast jobs even without proper labels |
| `FORCE_TEST_NRT` | Force NRT (requires `FORCE_BUILD_CAST` too) |
| `NRT_RUN_ALL_TESTS` | Run all NRT (not just defaults) |
| `NRT_DELAYED` | Delay NRT to run at 8 PM |

## MR Checklist (EC)

The EC MR template requires:

### Developer Checklist
- [ ] `EC` label set
- [ ] Integration reviewed
- [ ] Implementation reviewed (if component changed)
- [ ] Unitary tests report written
- [ ] Test cases written (codebeamer)
- [ ] DoD (Definition of Done) written
- [ ] Changelog written
- [ ] **Stabilization**:
  - [ ] Components and dependencies version stable
  - [ ] Dependencies frozen

### Release Manager Checklist
- [ ] `EC` label set
- [ ] Unitary tests report reviewed
- [ ] Demand reviewed (Implemented → Closed)
- [ ] DoD reviewed
- [ ] Changelog reviewed
- [ ] Go/noGo meeting done
- [ ] DIVA test report reviewed (Auto NRT, I&A, I&V)
- [ ] Stabilization reviewed
- [ ] `STATE_MATURE` label set
- [ ] 'Squash commits' option set

## Stabilization & Merge to Main

### Before Merge: Turn EC Channels to Stable

In your **C++ project** (not in chaudron), before merging:

1. Change all `ec-<name>` dependency channels to `stable` in `project.yaml`:

```yaml
# BEFORE (EC)
dependencies:
  internals:
    - ref: libraries_ipc/[^1.8]@navya/ec-header-stamps

# AFTER (stabilized)
dependencies:
  internals:
    - ref: libraries_ipc/[^1.8]@navya/stable
```

2. Commit with message: `"Turn ec-my-feature channel in stable"`
3. Ensure `project.yaml` version matches what the `main` branch expects
4. Merge `ec/my-feature` into `main`
5. Create release tag on `main`: `vX.Y.Z`

### In Chaudron: Turn EC Refs to Stable

Similarly, update `requirements.yaml`:

```yaml
# BEFORE
- ref: my_project/1.3.0@navya/ec-my-feature

# AFTER
- ref: my_project/1.3.0@navya/stable
```

Re-freeze, merge to `main`, tag.

### Post-Merge Cleanup

**Always clean up EC branches and tags** after merge:

```bash
# Delete EC branch (local + remote)
git branch -D ec/my-feature
git push origin :ec/my-feature

# Delete EC tags
git push origin :ec1.3.0-ec-my-feature
git push origin :ec1.3.1-ec-my-feature
git tag -d ec1.3.0-ec-my-feature ec1.3.1-ec-my-feature
```

## Fix Workflow

### Quick Fix on main (No Pre-Release)

```bash
git checkout main
git checkout -b fix/<codebeamer-bug-id>
# Apply fix, commit
# Merge directly to main (use merge_request_fix.md template)
```

MR requires `FIX` or `HOTFIX` label.

### Fix Needing Pre-Release

If the fix needs testing via Chaudron before merge, use an EC-style branch:

```bash
git checkout -b ec/fix-<bug-id>
# Follow the full EC workflow above
```

### Maintenance Fix (Specific Release)

```bash
# 1. Create maintenance branch from release tag
git checkout -b maintenance/v2.0.0 v2.0.0

# 2. Create fix branch
git checkout -b fix/<bug-id>
# Apply fix

# 3. Merge to maintenance
git checkout maintenance/v2.0.0
git merge --no-ff fix/<bug-id>
git tag v2.0.1-m-2.0.0

# 4. Optionally propagate to main
git checkout main
git cherry-pick <fix-commits>
```

## Internal EC (Unscheduled R&D)

For internal development not tied to a roadmap item:

```bash
# Create internal EC
git checkout -b ec/mpc    # internal R&D branch

# When a scheduled feature depends on it:
git checkout ec/mpc
git checkout -b ec/dynamic-behavior-v1
# Follow nominal EC process from here
```

## Doyle EC Internals

How Doyle detects and handles EC releases:

### Version Detection

```python
# project_file.py: EC detection from version string
tag_prefix = "ec" if "-ec-" in version else "v"
tag = f"{tag_prefix}{version}"
```

### Git Tag Recognition

```python
# git_tools.py: matches both v* and ec* tags
MATCH_VERSION = re.compile(r"(v|ec)([0-9]+.[0-9]+.[0-9]+[a-z]?(-.*)?)")
# git describe --match=v* --match=ec*
```

### Upload Channel

```python
# conan_package.py: channel becomes part of the Conan reference
def navya_reference(name, version, channel="dirty"):
    return f"{name}/{version}@navya/{channel}"

# CLI default channel is "dirty"; CI overrides with stable/ec-*/m-*
# doyle upload -c ec-my-feature  →  my_project/1.3.0@navya/ec-my-feature
```

## Spellcaster Frozen File Mechanics

### Cast Resolution Order

1. Spellcaster checks if frozen file exists for the target
2. If missing or if `requirements.yaml` is newer (mtime comparison) → auto-regenerates frozen file
3. `DoyleRepoClient` loads frozen file references and renders a conanfile
4. `conan install` runs with frozen references → packages are fetched

### Frozen File Format

```
# frozen_files/shuttle_evo3_base_pc1_dev_frozen.txt
Boost/1.79.0@moris/stable
libraries_grimoire/2.9.1@navya/stable
my_project/1.3.0@navya/ec-my-feature
localisation_fusion_tools/0.10.4@navya/ec-exwayz
...
```

One Conan reference per line. These are exact pins — no version ranges.

## Quick Reference: End-to-End EC Integration

```bash
# === C++ PROJECT ===
# 1. Create EC branch
git checkout main && git checkout -b ec/my-feature

# 2. Develop, commit
# ... code changes ...

# 3. Tag EC release
git tag ec1.3.0-ec-my-feature
git push origin ec/my-feature --tags
# CI uploads: my_project/1.3.0@navya/ec-my-feature

# === CHAUDRON ===
# 4. Create matching EC branch
cd ~/dev/chaudron
git checkout main && git checkout -b ec/my-feature

# 5. Update requirements.yaml
#    ref: my_project/1.3.0@navya/ec-my-feature

# 6. Freeze
spellcaster freeze ~/dev/chaudron --vehicle_type shuttle --pc_id 1

# 7. Validate locally
spellcaster validate ~/dev/chaudron
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use dev --default

# 8. Push & open MR (EC label)
git add -A && git commit && git push origin ec/my-feature

# 9. Label progression: EC → EC_READY → EC_MATURE

# === STABILIZATION ===
# 10. In C++ project: turn ec-my-feature → stable, merge to main, tag vX.Y.Z
# 11. In chaudron: update refs to stable, re-freeze, merge to main, tag

# === CLEANUP ===
# 12. Delete ec/my-feature branches and ec* tags everywhere
```

## Common Scenarios

### Scenario: Multiple Projects Changed for One Feature

If your feature touches projects A, B, and C:

1. Create `ec/my-feature` in all three projects
2. Tag and release each: `A/1.0.1@navya/ec-my-feature`, `B/2.3.0@navya/ec-my-feature`, `C/0.5.0@navya/ec-my-feature`
3. In chaudron `ec/my-feature`, update all three refs in requirements.yaml
4. Freeze and validate
5. At stabilization: turn all three to stable, merge all three to main, then merge chaudron

### Scenario: My EC Depends on Another Team's EC

If your project depends on `libraries_ipc` which is on an EC channel:

```yaml
# In your project.yaml:
dependencies:
  internals:
    - ref: libraries_ipc/[^1.8]@navya/ec-header-stamps

# In chaudron requirements.yaml:
- ref: libraries_ipc/1.8.5@navya/ec-header-stamps
- ref: my_project/1.3.0@navya/ec-my-feature
```

Both ECs must stabilize (turn to stable) before either can merge to `main`.

### Scenario: Quick Local Test Without Full EC Process

For quick iteration without going through full CI:

```bash
# Build and create local package
doyle create local --no-tests
# Available as: my_project/version@navya/local

# Temporarily update chaudron requirements to use local
# ref: my_project/version@navya/local

# Cast locally
spellcaster cast ~/dev/chaudron shuttle/evo3/base 1 --use dev --default
```

**Warning**: `local` channel packages are only on your machine. Never commit `@navya/local` refs to chaudron.

### Scenario: Rebase After Another EC Merged

```bash
# Another EC just merged to main in both C++ project and chaudron

# 1. Rebase C++ project
cd ~/dev/my_project
git checkout ec/my-feature
git rebase main
git push -f origin ec/my-feature
# Re-tag if needed

# 2. Rebase chaudron
cd ~/dev/chaudron
git checkout ec/my-feature
git rebase main
# Re-freeze (requirements may have changed)
spellcaster freeze ~/dev/chaudron --vehicle_type shuttle --pc_id 1
git push -f origin ec/my-feature
```

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| CI doesn't run casts/NRT | MR has `EC` label only | Add `EC_READY` or `EC_MATURE` label |
| Package not found in Artifactory | EC tag not pushed or CI failed | Check CI pipeline on your C++ project; verify tag exists |
| Frozen file validation error | Frozen file out of date | Run `spellcaster freeze` and commit the updated frozen file |
| Cast fails: package version conflict | Multiple ECs touching same dependency | Coordinate with other team; one EC may need to rebase on the other |
| `spellcaster validate` fails | requirements.yaml syntax or missing spell references | Check ref format: `name/version@user/channel`, ensure all source files exist |
| Merge blocked: EC channels still present | Forgot to turn ec-name to stable | In C++ project: update dependencies to `@navya/stable`, re-release, update chaudron |
| Dead branches/tags after rebase | Old EC tags pointing to pre-rebase commits | Delete old tags, recreate on rebased branch |
| NRT failures | Integration issue or flaky test | Check NRT report in MR; re-run with `FORCE_TEST_NRT=true` if flaky |

## Related Skills

- **navya**: Ecosystem overview, shared infrastructure, NavyaDrive layout, cross-tool workflows
- **doyle**: C++ workspace manager — build, tag, upload packages (`doyle upload -c <channel>`)
- **spellcaster**: Drive composition — cast, freeze, validate (`spellcaster freeze`, `spellcaster cast`)
- **grimoire**: Configuration library — `.conf` file format used in chaudron's `conf.d/`
- **rtmaps**: RTMaps middleware — `.pck` packages and `.rtd` diagrams deployed via chaudron spells
