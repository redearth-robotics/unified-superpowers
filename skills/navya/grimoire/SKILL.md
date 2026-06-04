---
name: grimoire
description: Navya's C++ configuration management library (libraries_grimoire). Use when reading/writing configuration options via URI-based access, working with .conf JSON files, using grimoire::Core API, or dealing with Scope/validators. Triggers - 'grimoire', 'configuration option', 'config:/', 'readBooleanConfiguration', 'readStringConfiguration', 'readDoubleConfiguration', 'writeConfiguration', 'Scope::AUTO', '.conf file', 'configuration_checker'.
---

# Grimoire - Navya Central Configuration Manager

Grimoire (`libraries_grimoire`) is Navya's C++ library for URI-based access to hierarchical JSON configuration files. It provides typed read/write operations with validation, scoped overrides (global/site/vehicle/feature), and consistency checking.

**Source code**: `git@gitlab.navya.tech:5x/grimoire.git`
**Conan reference**: `libraries_grimoire/[^2.9]@navya/stable`
**C++ standard**: 17
**Version**: 2.9.2

## Core Concepts

- **URI-based access**: All config options are accessed via URIs like `config:/basename/path/to/option`
- **Scoped overrides**: Values cascade GLOBAL -> FEATURE -> SITE -> VEHICLE (vehicle wins)
- **JSON config files**: Options stored in `.conf` files (JSON format) under `conf.d/` directories
- **Typed values**: bool, string, int32, int64, double, enum, list, matrix
- **Validators**: Each option can have validation rules (min/max, regex, enum values)
- **Overridability**: Options can be marked as non-overridable

## Include & Namespace

```cpp
#include <libraries/grimoire/grimoire.h>          // Main header (includes common.h + core.h)
#include <libraries/grimoire/core/core.h>         // grimoire::Core class
#include <libraries/grimoire/common/common.h>     // uri_t, Scope enum
#include <libraries/grimoire/consistency/validation.h>  // Consistency checking

// Namespace
using namespace grimoire;  // or prefix with grimoire::
```

## URI Format

```
config:/<config_basename>/<path>/<to>/<option>
```

- `config:` is the scheme
- `<config_basename>` is the JSON file name without `.conf` extension
- The rest is the dotted path into the JSON tree

Example: for file `conf1.conf` containing `{"primitiveTypes": {"overridableValues": {"StringValue": {...}}}}`, the URI is:
```
config:/conf1/primitiveTypes/overridableValues/StringValue
```

## Scope Enum

```cpp
enum class Scope {
    GLOBAL  = 0x80,  // <root>/navya_drive/etc/conf.d/xxx.conf (read-only defaults)
    SITE    = 0x01,  // <root>/site/conf.d/xxx.conf
    VEHICLE = 0x02,  // <root>/vehicle/conf.d/xxx.conf
    FEATURE = 0x04,  // <root>/features/<feature_name>/conf.d/xxx.conf
    AUTO    = 0xFF   // Default: uses override search heuristic (VEHICLE > SITE > FEATURE > GLOBAL)
};
```

## grimoire::Core API

### Construction

```cpp
// Default constructor - uses default root path (/opt/navya or NAVYA_ROOT_INSTALL_PATH env var)
grimoire::Core config;

// Custom root path
grimoire::Core config("/path/to/config/root");

// Static factory (deprecated, use constructor)
auto config = grimoire::Core::getConfigurationHandler("/path/to/root");

// Static root path management
grimoire::Core::setDefaultRootPath("/custom/root");
grimoire::Core::resetDefaultRootPath();
std::string root = grimoire::Core::getDefaultRootPath();

// Product type (default: "navya_drive", env: NAVYA_PRODUCT_TYPE)
grimoire::Core::setDefaultProductType("mms_drive");
grimoire::Core::resetDefaultProductType();
std::string product = grimoire::Core::getDefaultProductType();
```

### Reading Values (3 overloads per type)

Each read method has three overloads:
1. **Throwing**: Returns value or throws on error
2. **Fallback + Logger v3**: Returns fallback on error, logs via `logger::Logger`
3. **Fallback + Logger v4**: Returns fallback on error, logs via internal Logger v4

```cpp
grimoire::Core config;
const uri_t uri = "config:/conf1/primitiveTypes/overridableValues/BooleanValue";

// 1. Throwing version
bool val = config.readBooleanConfiguration(uri);
bool val = config.readBooleanConfiguration(uri, Scope::GLOBAL);

// 2. Fallback with Logger v3
logger::Logger log("MyModule");
bool val = config.readBooleanConfiguration(uri, false, log);
bool val = config.readBooleanConfiguration(uri, false, log, Scope::VEHICLE);

// 3. Fallback with Logger v4 (preferred)
bool val = config.readBooleanConfiguration(uri, false);
bool val = config.readBooleanConfiguration(uri, false, Scope::VEHICLE);
```

### All Read Methods

| Method | Return type | JSON `type` |
|---|---|---|
| `readBooleanConfiguration` | `bool` | `"bool"` |
| `readStringConfiguration` | `std::string` | `"string"` |
| `readInteger32Configuration` | `int32_t` | `"int32"` |
| `readInteger64Configuration` | `int64_t` | `"int64"` |
| `readDoubleConfiguration` | `double` | `"double"` |
| `readEnumConfiguration` | `std::string` | `"enum"` (returns string label) |
| `readInteger32EnumConfiguration` | `int32_t` | `"enum"` (returns integer value) |
| `readListInteger32Configuration` | `std::vector<int32_t>` | `"list"` + subType `"int32"` |
| `readListInteger64Configuration` | `std::vector<int64_t>` | `"list"` + subType `"int64"` |
| `readListStringConfiguration` | `std::vector<std::string>` | `"list"` + subType `"string"` |
| `readListDoubleConfiguration` | `std::vector<double>` | `"list"` + subType `"double"` |
| `readMatrixInteger32Configuration` | `tuple<vector<int32_t>, uint, uint>` | `"matrix"` + subType `"int32"` |
| `readMatrixDoubleConfiguration` | `tuple<vector<double>, uint, uint>` | `"matrix"` + subType `"double"` |

### Reading Default Values (always from GLOBAL scope)

```cpp
bool val = config.readDefaultBooleanConfiguration(uri);
std::string val = config.readDefaultStringConfiguration(uri);
int32_t val = config.readDefaultInteger32Configuration(uri);
int64_t val = config.readDefaultInteger64Configuration(uri);
double val = config.readDefaultDoubleConfiguration(uri);
std::string val = config.readDefaultEnumConfiguration(uri);
int32_t val = config.readDefaultInteger32EnumConfiguration(uri);
// Also: readDefaultList*Configuration, readDefaultMatrix*Configuration
```

### Writing Values

All write methods return `bool` (always true on success, throw on error).
Default scope is `Scope::VEHICLE`.

```cpp
config.writeBooleanConfiguration(uri, true);
config.writeBooleanConfiguration(uri, true, Scope::SITE);

config.writeStringConfiguration(uri, "new value");
config.writeInteger32Configuration(uri, 42);
config.writeInteger64Configuration(uri, 123456789LL);
config.writeDoubleConfiguration(uri, 3.14);
config.writeEnumConfiguration(uri, "ENUM_VAL_3");

config.writeListInteger32Configuration(uri, {1, 2, 3});
config.writeListInteger64Configuration(uri, {4LL, 5LL, 6LL});
config.writeListStringConfiguration(uri, {"a", "b", "c"});
config.writeListDoubleConfiguration(uri, {1.1, 2.2, 3.3});

config.writeMatrixInteger32Configuration(uri, {1, 2, 3, 4, 5, 6});
config.writeMatrixDoubleConfiguration(uri, {1.1, 2.2, 3.3, 4.4});

// IMPORTANT: Call commit() to persist changes to disk
config.commit();
```

### Inspection & Navigation

```cpp
// Check if URI exists (even intermediate nodes)
bool exists = config.checkExistence(uri);

// Check if URI is a terminal leaf
bool leaf = config.isLeaf(uri);

// Get value type: "bool", "string", "int32", "int64", "double", "enum", "list", "matrix"
std::string type = config.getValueType(uri);

// Get subtype for lists/matrices: "int32", "int64", "string", "double"
std::string subtype = config.getListOrMatrixSubtype(uri);

// Get description
std::string desc = config.getDescription(uri);

// List child nodes
std::vector<std::string> children = config.listChildNodes(uri);

// List all config files at a scope
std::vector<std::string> configs = config.listConfigurations(Scope::GLOBAL);

// List root keys in a config file
std::vector<std::string> keys = config.listRootKeys("conf1");

// Check overridability
bool overridable = config.isOverridable(uri);
bool deprecated = config.isDeprecated(uri);
std::string where = config.getOverrideLocation(uri); // "GLOBAL", "SITE", "VEHICLE"

// Get validators
auto validators = config.getValidators(uri);

// Get available features
auto features = config.getAvailableFeatures();        // all features
auto features = config.getAvailableFeatures(true);     // enabled only
```

### Reset & Invalidation

```cpp
// Reset a value back to its GLOBAL default
config.resetToDefaultValue(uri);

// Reset at a specific scope (SITE or VEHICLE only)
config.resetAtScope(uri, Scope::VEHICLE);

// Invalidate cached configs (force re-read from disk)
config.invalidateConfigurations(Scope::VEHICLE);

// Check if uncommitted local modifications exist
bool dirty = config.containsLocalModifications();
```

### Path Management

```cpp
std::string root = config.getRootPath();
std::string cache = config.getCachePath();
config.setCachePath("/new/cache/path");

std::string path = config.getConfigurationPath(Scope::GLOBAL);
config.setConfigurationPath(Scope::VEHICLE, "/custom/vehicle/path");

std::string data = config.getDataPath(Scope::GLOBAL);
std::string features = config.getFeaturesConfigurationPath();
```

## JSON Configuration File Format (.conf)

Configuration files are JSON. Each leaf node must have `value`, `type`, and optionally `overridable`, `validation`, `desc`, `deprecated`.

```json
{
  "section": {
    "subsection": {
      "MyOption": {
        "value": 42,
        "type": "int32",
        "overridable": true,
        "desc": "Description of this option",
        "validation": {
          "min": 0,
          "max": 100
        }
      },
      "MyEnum": {
        "value": "OPTION_A",
        "type": "enum",
        "overridable": true,
        "validation": {
          "values": {
            "OPTION_A": 1,
            "OPTION_B": 2,
            "OPTION_C": 3
          }
        }
      },
      "MyList": {
        "value": [1, 2, 3],
        "type": "list",
        "overridable": true,
        "validation": {
          "subType": "int32",
          "min": 0,
          "max": 100
        }
      },
      "MyMatrix": {
        "value": [1.0, 2.0, 3.0, 4.0, 5.0, 6.0],
        "type": "matrix",
        "overridable": true,
        "validation": {
          "subType": "double",
          "rows": 2,
          "cols": 3
        }
      }
    }
  }
}
```

### Supported Types and Validation Rules

| Type | `type` field | Validation fields |
|---|---|---|
| Boolean | `"bool"` | (none) |
| String | `"string"` | `expression` (regex) |
| Integer 32 | `"int32"` | `min`, `max` |
| Integer 64 | `"int64"` | `min`, `max` |
| Double | `"double"` | `min`, `max` |
| Enum | `"enum"` | `values` (map of string label -> int value) |
| List | `"list"` | `subType` + type-specific validators |
| Matrix | `"matrix"` | `subType`, `rows`, `cols` |

## File System Layout

> See the **navya** skill for the complete NavyaDrive filesystem layout.

Grimoire-specific scope paths (relative to root, default `/opt/navya`):

| Scope | Path | Priority |
|-------|------|----------|
| GLOBAL | `<product_type>/etc/conf.d/*.conf` | Lowest (defaults) |
| FEATURE | `features/<name>/conf.d/*.conf` | |
| SITE | `site/conf.d/*.conf` | |
| VEHICLE | `vehicle/conf.d/*.conf` | Highest (wins) |

## MatrixValue Template

```cpp
template<typename T>
struct MatrixValue {
    std::vector<T> values;  // Row-major: [v00, v01, ..., v10, v11, ...]
    unsigned int rows;
    unsigned int cols;
};
```

## Exception Hierarchy

```
std::runtime_error
  +-- GrimoireException                        # Base grimoire error
  |     +-- OperationNotAllowed                # Operation forbidden in current mode
  +-- CoreException                            # Base core error
        +-- URIAccessException                 # Invalid URI or access error
        |     +-- OverridingAccessException    # Non-overridable option write attempt
        |     +-- FeatureLevelOverridingException
        |     +-- LevelOverridingNotSupportedException
        |     +-- ResetNotSupportedForScopeException
        |     +-- WriteOperationException
        +-- TypeMismatchException              # Wrong type read
        +-- FileFormatException                # Corrupted .conf file
        +-- FolderAccessException              # Missing directory
        +-- UnsupportedConfigurationTypeException
```

## Consistency Checking

```cpp
#include <libraries/grimoire/consistency/validation.h>

grimoire::Core config;

// Get list of errors
auto errors = grimoire::checkConfigurationConsistency(config);
for (const auto& e : errors) {
    // e.level: LEVEL_FILE or LEVEL_CONFIGURATION_KEY
    // e.scope: which scope had the issue
    // e.file_or_key: affected file or key
    // e.reason: description of the error
}

// Or log directly
logger::Logger log("Checker");
bool ok = grimoire::checkConfigurationConsistency(config, log);
```

## URIHelper Utility

```cpp
#include <libraries/grimoire/core/uri_helper.h>

URIHelper helper("config:/conf1/section/option");
bool valid = helper.isValid();
std::string basename = helper.getBasename();  // "conf1"
std::string dotted = helper.toDottedPath();   // "section.option"
size_t d = helper.depth();

// Manipulate URI path
helper.addTail("subkey");
helper.removeTail();
std::string tail = helper.popTail();

// RAII tail management
{
    AddTailRemoveTail guard(helper, "temporary_key");
    // helper now points to .../temporary_key
}  // Automatically removed
```

## project.yaml Dependency

To depend on grimoire in a Navya project:

```yaml
library:
  dependencies:
    internals:
      - ref: libraries_grimoire/[^2.9]@navya/stable
```

> To set up a doyle project with grimoire, see the **doyle** skill for `project.yaml` reference.

## Common Usage Patterns

### Read with fallback (preferred pattern)

```cpp
grimoire::Core config;
double speed = config.readDoubleConfiguration(
    "config:/driving/limits/maxSpeed", 5.0);
```

### Read, modify, commit

```cpp
grimoire::Core config;
int32_t val = config.readInteger32Configuration("config:/myconf/section/param");
config.writeInteger32Configuration("config:/myconf/section/param", val + 1, Scope::VEHICLE);
config.commit();
```

### Check before read

```cpp
grimoire::Core config;
const uri_t uri = "config:/myconf/section/param";
if (config.checkExistence(uri) && config.isLeaf(uri)) {
    std::string type = config.getValueType(uri);
    if (type == "int32") {
        int32_t val = config.readInteger32Configuration(uri);
    }
}
```

### Iterate children

```cpp
grimoire::Core config;
auto children = config.listChildNodes("config:/myconf/section");
for (const auto& child : children) {
    // child is the key name, build full URI to access
}
```

## Environment Variables

> See the **navya** skill for shared Navya environment variables (`NAVYA_ROOT_INSTALL_PATH`, `NAVYA_PRODUCT_TYPE`).

These variables directly affect grimoire's default paths:
- `NAVYA_ROOT_INSTALL_PATH`: Override default root path (default: `/opt/navya`)
- `NAVYA_PRODUCT_TYPE`: Override product type subdirectory (default: `navya_drive`)

## Application: configuration_checker

The library ships with a `configuration_checker` application that validates configuration file consistency across all scopes.


## Related Skills

- **navya**: Ecosystem overview, shared infrastructure, NavyaDrive layout, cross-tool workflows
- **doyle**: C++ workspace manager (for adding grimoire as a dependency via `project.yaml`)
- **spellcaster**: Drive composition (produces NavyaDrive with `.conf` files that grimoire reads at runtime)
