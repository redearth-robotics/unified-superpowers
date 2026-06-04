---
name: rtmaps
description: RTMaps real-time middleware for autonomous vehicle data-flow programming. Use when writing RTMaps components (MAPSComponent), working with .rtd diagrams, using RTMaps macros (MAPS_BEGIN_INPUTS_DEFINITION, MAPS_OUTPUT, MAPS_COMPONENT_DEFINITION), InputReader/OutputGuard API, .pck packages, or running rtmaps/rtmaps_runtime. Triggers - 'rtmaps', 'MAPSComponent', 'MAPS_OUTPUT', 'InputReader', 'OutputGuard', '.rtd', '.pck', 'rtmaps_runtime', 'MAPS_BEGIN_INPUTS_DEFINITION', 'MAPS_COMPONENT_DEFINITION', 'Birth', 'Core', 'Death', 'Dynamic'.
---

# RTMaps - Real-Time Middleware for Data-Flow Programming

RTMaps (Real-Time Multisensor Applications) is a component-based middleware for real-time data acquisition, processing, and recording. At Navya, it is the runtime framework that executes perception, decision, and actuation pipelines on vehicles.

**Installation**: `/opt/rtmaps`
**SDK**: `/opt/rtmaps/sdk/ubuntu2404_x86_64/`
**Version**: 4.x (Conan ref: `RTMAPS/[^4.6.2]@moris/stable`)
**GUI**: `/opt/rtmaps/bin/rtmaps` (Studio)
**Headless runtime**: `/opt/rtmaps/bin/rtmaps_runtime`

> **Build system**: At Navya, RTMaps components are built with **Doyle** (not raw CMake). See the **doyle** skill for `project.yaml` and build commands.
> **Deployment**: RTMaps `.pck` packages and `.rtd` diagrams are deployed via **Spellcaster** casts. See the **spellcaster** skill.
> **Configuration**: Runtime config lives in `rtmaps.conf` (Grimoire JSON format). See the **grimoire** skill.
> **Ecosystem overview**: See the **navya** umbrella skill for shared infrastructure, NavyaDrive layout, and cross-tool workflows.

## Core Concepts

- **Component**: A C++ class (inheriting `MAPSComponent`) that processes data. Has typed inputs, outputs, properties, and a lifecycle (`Dynamic` > `Birth` > `Core` loop > `Death`)
- **Diagram** (`.rtd`): A visual data-flow graph connecting component instances via wires. Edited in RTMaps Studio or generated programmatically
- **Package** (`.pck`): A shared library (`.so`/`.dll`) containing one or more compiled components, loadable by RTMaps at runtime
- **Wire**: A typed connection between an output of one component and an input of another. Data flows through wires as `MAPSIOElt` (I/O elements)
- **Property**: A user-configurable parameter on a component (string, int, float, bool, enum). Set in the diagram or at runtime
- **Action**: A triggerable function on a component (like a button in Studio)

## Class Hierarchy

```
MAPSModuleBase          (abstract base - internal)
  MAPSModule            (legacy base - DO NOT USE directly)
    MAPSComponent       (modern base - USE THIS)
```

Always inherit from `MAPSComponent`. Never from `MAPSModule` or `MAPSModuleBase` directly.

## Component Lifecycle

```
               Construction
                    |
                    v
              +-----------+
              | Dynamic() |  Define inputs/outputs/properties/actions
              +-----------+  Called once during diagram load
                    |
                    v
              +-----------+
              |  Birth()  |  Initialize resources, open files/devices
              +-----------+  Called once when diagram starts
                    |
                    v
              +-----------+
              |   Core()  |  <-- Main processing loop
              +-----------+      Called repeatedly by the engine
                    |            MUST contain exactly ONE blocking call
                    v            (Wait, StartReading, SynchroStartReading, Rest, etc.)
              +-----------+
              |  Death()  |  Cleanup resources
              +-----------+  Called once when diagram stops
```

### Lifecycle Rules

1. **Dynamic()**: Declare all inputs, outputs, properties, and actions. No heavy work.
2. **Birth()**: Allocate resources, open connections. Properties are readable here.
3. **Core()**: The engine calls this in a loop. **ONE and only one blocking call per Core() invocation** (this is what yields control back to the engine scheduler). If you need to wait on multiple inputs, use `SynchroStartReading` or `InputReader`.
4. **Death()**: Release resources. Always called even if Birth() or Core() threw an error.

## Component Template

Canonical template from `/opt/rtmaps/templates.u/src/maps_ComponentTemplate.cpp`:

```cpp
// File: my_component.cpp

#include "maps.h"

// ---- Component Declaration Macros ----

MAPS_BEGIN_INPUTS_DEFINITION(MyComponent)
    MAPS_INPUT("input1", MAPS::FilterInteger32, MAPS::FifoReader)
MAPS_END_INPUTS_DEFINITION

MAPS_BEGIN_OUTPUTS_DEFINITION(MyComponent)
    MAPS_OUTPUT("output1", MAPS::Integer32, nullptr, nullptr, 0)
MAPS_END_OUTPUTS_DEFINITION

MAPS_BEGIN_PROPERTIES_DEFINITION(MyComponent)
    MAPS_PROPERTY("gain", 1.0, false, false)
MAPS_END_PROPERTIES_DEFINITION

MAPS_BEGIN_ACTIONS_DEFINITION(MyComponent)
    MAPS_ACTION("reset", MyComponent::Reset)
MAPS_END_ACTIONS_DEFINITION

MAPS_COMPONENT_DEFINITION(MyComponent, "MyComponent", "1.0.0",
                           128,            // priority (0-255, higher = more priority)
                           MAPS::Threaded, // scheduling: Threaded or Sequential
                           MAPS::Threaded, // sub-scheduling
                           -1,             // nb inputs (-1 = as declared)
                           -1,             // nb outputs (-1 = as declared)
                           0,              // nb properties auto-read (deprecated, use 0)
                           0)              // reserved

// ---- Component Class ----

class MyComponent : public MAPSComponent
{
    // Called when diagram is loaded
    void Dynamic() override;
    // Called when diagram starts
    void Birth() override;
    // Main processing loop (called repeatedly)
    void Core() override;
    // Called when diagram stops
    void Death() override;
    // Custom action
    void Reset(MAPSModule* /* unused */, int /* unused */, MAPSModule* /* unused */);
};

void MyComponent::Dynamic()
{
    // Nothing extra needed if inputs/outputs/properties defined via macros
}

void MyComponent::Birth()
{
    // Initialize resources
}

void MyComponent::Core()
{
    // ONE blocking call per Core() invocation
    MAPSIOElt* elt = StartReading(Input(0));
    if (elt == nullptr)
        return;

    int32_t value = elt->Integer32();
    double gain = GetFloatProperty("gain");
    int32_t result = static_cast<int32_t>(value * gain);

    MAPSIOElt* out = StartWriting(Output(0));
    out->Integer32() = result;
    out->Timestamp() = elt->Timestamp();
    StopWriting(out);
}

void MyComponent::Death()
{
    // Cleanup
}

void MyComponent::Reset(MAPSModule*, int, MAPSModule*)
{
    // Action handler
}
```

## I/O Declaration Macros

### Inputs

```cpp
MAPS_BEGIN_INPUTS_DEFINITION(ComponentName)
    MAPS_INPUT("name", Filter, ReaderType)
    // ... more inputs
MAPS_END_INPUTS_DEFINITION
```

**Filters** (what data types this input accepts):

| Filter | Data Type |
|--------|-----------|
| `MAPS::FilterInteger32` | 32-bit integer |
| `MAPS::FilterInteger64` | 64-bit integer |
| `MAPS::FilterFloat32` | 32-bit float |
| `MAPS::FilterFloat64` | 64-bit float |
| `MAPS::FilterBool` | Boolean |
| `MAPS::FilterString` | Text string |
| `MAPS::FilterIplImage` | OpenCV IplImage (legacy) |
| `MAPS::FilterMAPSImage` | RTMaps image |
| `MAPS::FilterCANFrame` | CAN bus frame |
| `MAPS::FilterStream8` | Raw byte stream |
| `MAPS::FilterCustomStructure` | Custom C struct |
| `MAPS::FilterAny` | Accept any type |

**Reader Types** (how data is consumed from the input FIFO):

| Reader | Behavior |
|--------|----------|
| `MAPS::FifoReader` | Blocking FIFO. `StartReading` blocks until data arrives. Every sample is read exactly once, in order. **Default and most common.** |
| `MAPS::SamplingReader` | Non-blocking. Returns the latest available sample (or nullptr). Samples may be skipped. Use for sensor fusion where you want "latest value". |
| `MAPS::LastOrNextReader` | Returns the last received sample immediately, or blocks for the next one if nothing available yet. |
| `MAPS::Wait4NextReader` | Like FifoReader but skips to the most recent sample instead of queuing. |
| `MAPS::NeverskippingReader` | Every sample is guaranteed to be read even under load (backpressure). Use for critical data. |

### Outputs

```cpp
MAPS_BEGIN_OUTPUTS_DEFINITION(ComponentName)
    MAPS_OUTPUT("name", DataType, subtype, description, fifo_size)
    // ... more outputs
MAPS_END_OUTPUTS_DEFINITION
```

**Data Types**: `MAPS::Integer32`, `MAPS::Integer64`, `MAPS::Float32`, `MAPS::Float64`, `MAPS::Bool`, `MAPS::String`, `MAPS::IplImage`, `MAPS::MAPSImage`, `MAPS::CANFrame`, `MAPS::Stream8`, `MAPS::DrawingObject`, `MAPS::CustomStructure`

- `subtype`: Usually `nullptr`
- `description`: Usually `nullptr`
- `fifo_size`: FIFO buffer size. `0` = default engine size

### Properties

```cpp
MAPS_BEGIN_PROPERTIES_DEFINITION(ComponentName)
    MAPS_PROPERTY("name", default_value, is_read_only, is_persistent)
    MAPS_PROPERTY_ENUM("name", "VAL1|VAL2|VAL3", 0, false, false)  // enum with index default
    MAPS_PROPERTY_USER_INTERFACE("name", default, readonly, persistent, "ui_hint")
MAPS_END_PROPERTIES_DEFINITION
```

**Reading properties in code:**

```cpp
int    val = GetIntegerProperty("name");
double val = GetFloatProperty("name");
bool   val = GetBoolProperty("name");
MAPSString val = GetStringProperty("name");
MAPSEnumStruct e = GetEnumProperty("name");  // e.selectedEnum = index
```

### Actions

```cpp
MAPS_BEGIN_ACTIONS_DEFINITION(ComponentName)
    MAPS_ACTION("action_name", ComponentName::HandlerMethod)
MAPS_END_ACTIONS_DEFINITION

// Handler signature:
void ComponentName::HandlerMethod(MAPSModule* caller, int actionNb, MAPSModule* source);
```

## Legacy I/O API

The traditional `StartReading`/`StartWriting` API:

```cpp
// ---- Reading (blocking, one input) ----
MAPSIOElt* elt = StartReading(Input(0));         // blocks on input 0
MAPSIOElt* elt = StartReading(Input("name"));    // by name
if (elt == nullptr) return;                       // shutdown signal

// Read typed data
int32_t   v = elt->Integer32();
int64_t   v = elt->Integer64();
float     v = elt->Float32();
double    v = elt->Float64();
bool      v = elt->Bool();
const char* s = elt->String();
MAPSTimestamp t = elt->Timestamp();
int vectorSize = elt->VectorSize();              // for vector data
int32_t* arr = elt->Integer32Ptr();              // pointer to array

// ---- Reading (blocking, multiple inputs) ----
int inputIdx = -1;
MAPSIOElt* elt = StartReading(NbInputs(), inputIdx);  // blocks on ANY input
// inputIdx now tells which input fired

// ---- Synchronized reading (all inputs at once) ----
MAPSIOElt** elts = new MAPSIOElt*[NbInputs()];
SynchroStartReading(NbInputs(), elts);
// elts[0], elts[1], etc. are all valid
delete[] elts;

// ---- Writing ----
MAPSIOElt* out = StartWriting(Output(0));
out->Integer32() = 42;
out->Timestamp() = timestamp;
StopWriting(out);                                // publishes the element

// ---- Writing with size (for vectors/images) ----
MAPSIOElt* out = StartWriting(Output(0), dataSize);
memcpy(out->Data(), src, dataSize);
out->VectorSize() = numElements;
StopWriting(out);
```

## Modern I/O API (InputReader + OutputGuard)

**Recommended over legacy API.** Located in `/opt/rtmaps/packages/rtmaps_input_reader/`.

### InputReader

Type-safe, RAII-based input reading. Created in `Birth()`, used in `Core()`.

```cpp
#include "maps_io_access.hpp"   // or "maps.h" if already included

class MyComponent : public MAPSComponent
{
    // Declare reader as member
    std::unique_ptr<MAPS::InputReader> m_reader;

    void Birth() override
    {
        // Create reader in Birth()
        m_reader = MAPS::MakeInputReader::Reactive(
            this,
            Input(0),                                        // which input
            &MyComponent::ProcessData                       // callback
        );
    }

    void Core() override
    {
        // ONE blocking call: the reader handles waiting
        m_reader->Read();
    }

    // Callback receives typed data
    void ProcessData(const MAPSTimestamp ts, const int32_t& data)
    {
        // Process data here
        // ts = timestamp of the input element
        // data = typed reference to the payload
    }
};
```

### InputReader Factory Methods

```cpp
// ---- Reactive: callback on each new sample ----
MAPS::MakeInputReader::Reactive(
    this,
    Input(0),                            // single input
    &MyComponent::Callback               // member function pointer
);

// ---- Reactive on multiple inputs ----
MAPS::MakeInputReader::Reactive(
    this,
    MAPS::InputList{Input(0), Input(1)}, // multiple inputs
    &MyComponent::Callback               // called for each input that fires
);

// ---- Synchronized: all inputs at once ----
MAPS::MakeInputReader::Synchronized(
    this,
    MAPS::InputList{Input(0), Input(1)},
    &MyComponent::SyncCallback           // called when ALL inputs have data
);

// ---- Periodic Sampling: read at fixed rate ----
MAPS::MakeInputReader::PeriodicSampling(
    this,
    MAPS::InputList{Input(0)},
    &MyComponent::SamplingCallback,
    10000                                // period in microseconds
);

// ---- Triggered: read on trigger input, sample others ----
MAPS::MakeInputReader::Triggered(
    this,
    Input(0),                            // trigger input (FifoReader)
    MAPS::InputList{Input(1), Input(2)}, // sampled inputs
    &MyComponent::TriggeredCallback
);
```

### OutputGuard (RAII Writing)

```cpp
#include "maps_io_access.hpp"

void MyComponent::ProcessData(const MAPSTimestamp ts, const int32_t& data)
{
    // RAII: acquires output buffer, publishes on destruction
    MAPS::OutputGuard<int32_t> guard(this, Output(0));
    guard.Data()      = data * 2;
    guard.Timestamp() = ts;
    // StopWriting called automatically when guard goes out of scope
}

// For vector/array output:
MAPS::OutputGuard<int32_t> guard(this, Output(0), numElements);
int32_t* ptr = guard.DataPtr();
for (int i = 0; i < numElements; ++i)
    ptr[i] = values[i];
guard.VectorSize() = numElements;
guard.Timestamp()  = ts;
```

### Custom Structures with I/O API

```cpp
// Define your struct
struct MyData {
    double x, y, z;
    int32_t id;
};

// Declare output with custom structure
MAPS_BEGIN_OUTPUTS_DEFINITION(MyComponent)
    MAPS_OUTPUT_USER_STRUCTURE("output1", MyData)
MAPS_END_OUTPUTS_DEFINITION

// Write custom structure
MAPS::OutputGuard<MyData> guard(this, Output(0));
guard.Data().x  = 1.0;
guard.Data().y  = 2.0;
guard.Data().z  = 3.0;
guard.Data().id = 42;
guard.Timestamp() = ts;
```

## Building RTMaps Components at Navya (Doyle)

At Navya, all C++ projects including RTMaps components are built using **Doyle** (not raw CMake). Load the **doyle** skill for full `project.yaml` reference and build commands.

### project.yaml for an RTMaps Package

```yaml
header:
  schema_version: 1.0.0
general:
  name: driving_control_trajectory_tracker
  description: Trajectory tracking controller RTMaps component
  url: git@gitlab.navya.tech:driving/control/trajectory_tracker.git
  cppstd: 17
library:
  dependencies:
    externals:
      - ref: RTMAPS/[^4.6.2]@moris/stable    # RTMaps SDK dependency
      - ref: Eigen/[^3.2.4]@moris/stable
    internals:
      - ref: libraries_grimoire/[^2.9]@navya/stable
      - ref: libraries_spline/[^1.0]@navya/stable
applications:
  list:
    - name: trajectory_tracker
      type: pck                                # RTMaps package type
      dependencies:
        externals:
          - ref: RTMAPS/[^4.6.2]@moris/stable
```

**Key points:**
- RTMaps SDK is an **external** dependency: `RTMAPS/[^4.6.2]@moris/stable`
- Application type must be `pck` (RTMaps package)
- The `pck` type tells Doyle's CMake generator to produce a `.pck` shared library instead of an executable

### Build Workflow

```bash
# 1. Clone project
doyle clone driving_control_trajectory_tracker/1.0.0@navya/stable

# 2. Setup build environment (Doyle handles CMake generation + Conan deps)
doyle build setup -u -b missing

# 3. Build
cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make

# 4. Output: build/lib/DRIVING_control_trajectory_tracker.pck

# 5. Upload to Artifactory
doyle upload -c stable
```

### .pck Naming Convention

Doyle produces `.pck` files following this naming: `CATEGORY_component_name.pck`

| Team/Category | Prefix | Example |
|---------------|--------|---------|
| Driving | `DRIVING_` | `DRIVING_control_trajectory_tracker.pck` |
| Perception/Sensors | `PERCEPTION_` | `PERCEPTION_localisation_imu.pck` |
| Mission | `MISSION_` | `MISSION_fleet_manager.pck` |
| Diagnostic | `DIAGNOSTIC_` | `DIAGNOSTIC_vehicle_monitor.pck` |
| Libraries | `LIBRARIES_` | `LIBRARIES_maps_io.pck` |

## RTMaps Studio

GUI application for designing and debugging data-flow diagrams.

**Launch**: `/opt/rtmaps/bin/rtmaps`

### Key operations

| Action | How |
|--------|-----|
| Create diagram | File > New > Diagram |
| Add component | Drag from Package Browser or right-click canvas |
| Connect components | Drag from output port to input port |
| Load package | Packages > Load Package > select `.pck` file |
| Set property | Select component > Properties panel |
| Run diagram | Click Play / F5 |
| Record data | Use `RTMaps_Recorder` component |
| Replay data | Use `RTMaps_Replayer` component |

### Package Search Paths

RTMaps Studio searches for `.pck` files in:

1. `$RTMAPS_SDKDIR/packages/` (built-in)
2. User-configured additional paths (Preferences > Packages)
3. NavyaDrive paths: `navya_drive/lib/internal/pck/`, `navya_drive/lib/external/pck/`

## RTMaps Runtime (Headless)

For vehicle deployment (no GUI). Executes `.rtd` diagrams from command line.

```bash
/opt/rtmaps/bin/rtmaps_runtime [options] <diagram.rtd>
```

| Option | Description |
|--------|-------------|
| `<diagram.rtd>` | Diagram file to execute |
| `--pck-path <dir>` | Additional package search directory |
| `--property <comp.prop=value>` | Override component property |
| `--log-level <level>` | Set log verbosity |

**Example** (typical NavyaDrive launch):

```bash
/opt/rtmaps/bin/rtmaps_runtime \
    --pck-path /opt/navya/navya_drive/lib/internal/pck \
    --pck-path /opt/navya/navya_drive/lib/external/pck \
    /opt/navya/navya_drive/resource_diag.rtd
```

## Common Data Types Reference

### MAPSIOElt Accessors

| Accessor | Data type | Read | Write |
|----------|-----------|------|-------|
| `Integer32()` | `int32_t&` | Yes | Yes |
| `Integer64()` | `int64_t&` | Yes | Yes |
| `Float32()` | `float&` | Yes | Yes |
| `Float64()` | `double&` | Yes | Yes |
| `Bool()` | `bool` | Yes | Yes |
| `String()` | `const char*` / `MAPSString` | Yes | Yes |
| `Timestamp()` | `MAPSTimestamp&` | Yes | Yes |
| `VectorSize()` | `int&` | Yes | Yes |
| `Data()` | `void*` | Yes | Yes |
| `Integer32Ptr()` | `int32_t*` | Yes | - |
| `Float64Ptr()` | `double*` | Yes | - |
| `BufferSize()` | `int` | Yes | - |

### MAPSTimestamp

```cpp
MAPSTimestamp ts = elt->Timestamp();     // microseconds since epoch
MAPSTimestamp now = MAPS::CurrentTime(); // current RTMaps time
```

### MAPSString

```cpp
MAPSString s = "hello";
const char* c = s.Str();                // C string
int len = s.Len();                      // length
```

## Installation Layout

```
/opt/rtmaps/
  bin/
    rtmaps                              # Studio (GUI)
    rtmaps_runtime                      # Headless runtime
    rtmaps_compiler                     # Diagram compiler
  sdk/
    ubuntu2404_x86_64/
      include/
        maps.h                          # Main header (includes everything)
        maps_component.h                # MAPSComponent class
        maps_module.h                   # MAPSModule (legacy base)
        maps_io_access.hpp              # Modern InputReader/OutputGuard API
        maps_types.h                    # MAPSIOElt, MAPSTimestamp, etc.
      lib/
        librtmaps_*.so                  # SDK libraries
  packages/
    rtmaps_input_reader/                # InputReader package + samples
      samples/
        src/
          maps_InputReader_sample.cpp   # Reactive reader example
          maps_SynchronizedReader_sample.cpp
          maps_TriggeredReader_sample.cpp
    *.pck                               # Built-in packages
  templates.u/
    src/
      maps_ComponentTemplate.cpp        # Canonical component template
      maps_MultipleInputsComponentTemplate.cpp
    CMakeLists.txt                      # Template CMake (reference only at Navya - use Doyle)
  user_sdk/
    samples.u/                          # C++ samples
      src/
        maps_sample_*.cpp               # Various example components
  doc/
    RTMaps_Developer_Manual.pdf         # Component development guide (~120pp)
    RTMaps_User_Manual.pdf              # Studio user guide (~135pp)
    RTMaps_SDK_Samples_*.pdf            # SDK samples walkthrough (~93pp)
    RTMaps_External_API_*.pdf           # External API reference (~145pp)
    RTMaps_SDK_API_Reference_*.pdf      # Full API reference (~1401pp)
    RTMaps_Migration_*.pdf              # Migration guide
    RTMaps_PythonBridge_*.pdf           # Python bridge
    RTMaps_SocketBridge_*.pdf           # Socket bridge
```

## Navya Integration Points

### NavyaDrive Layout

RTMaps artifacts in a casted NavyaDrive:

| Path | Content |
|------|---------|
| `navya_drive/lib/internal/pck/` | Internal `.pck` packages (Navya-built) |
| `navya_drive/lib/external/pck/` | External `.pck` packages (third-party) |
| `navya_drive/etc/conf.d/rtmaps.conf` | RTMaps runtime configuration (Grimoire format) |
| `navya_drive/resource_diag*.rtd` | RTMaps diagrams per PC/vehicle |

### Spellcaster Integration

`.pck` packages are deployed via `.spell` files in Chaudron:

```yaml
# chaudron/lib/internal/pck/.spell
- source: <rd-conan-int:doyle>driving_control_trajectory_tracker/driving_control_trajectory_tracker.pck
  destination: lib/internal/pck/DRIVING_control_trajectory_tracker.pck
  owners:
    - driving@navya.tech
  users:
    - integration@navya.tech
  pc_target:
    shuttle/evo3: [1]
```

`.rtd` diagrams are local resources in Chaudron:

```yaml
# chaudron/conf.d/rtmaps/.spell
- source: resource_diag_shuttle_pc1.rtd
  destination: resource_diag.rtd
  owners:
    - integration@navya.tech
  users:
    - driving@navya.tech
  pc_target:
    shuttle/evo3: [1]
```

### Grimoire Configuration

RTMaps runtime settings in `rtmaps.conf` (Grimoire JSON format):

```json
{
    "runtime": {
        "LogLevel": {
            "value": "INFO",
            "type": "enum",
            "overridable": true,
            "validation": { "values": { "DEBUG": 0, "INFO": 1, "WARNING": 2, "ERROR": 3 } }
        },
        "DiagramPath": {
            "value": "resource_diag.rtd",
            "type": "string",
            "overridable": true,
            "desc": "Main diagram file to load"
        }
    }
}
```

Read in C++:

```cpp
grimoire::Core config;
std::string diagram = config.readStringConfiguration("config:/rtmaps/runtime/DiagramPath", "resource_diag.rtd");
```

## Common Patterns

### Multi-Input Component (Sensor Fusion)

```cpp
MAPS_BEGIN_INPUTS_DEFINITION(FusionComponent)
    MAPS_INPUT("lidar",  MAPS::FilterCustomStructure, MAPS::FifoReader)
    MAPS_INPUT("camera", MAPS::FilterMAPSImage,       MAPS::SamplingReader)
    MAPS_INPUT("imu",    MAPS::FilterCustomStructure, MAPS::SamplingReader)
MAPS_END_INPUTS_DEFINITION

// Use InputReader for clean multi-input handling
void FusionComponent::Birth()
{
    m_reader = MAPS::MakeInputReader::Triggered(
        this,
        Input("lidar"),                              // trigger on lidar (FifoReader)
        MAPS::InputList{Input("camera"), Input("imu")}, // sample camera + IMU
        &FusionComponent::OnLidarFrame
    );
}

void FusionComponent::Core()
{
    m_reader->Read();
}

void FusionComponent::OnLidarFrame(
    const MAPSTimestamp ts,
    const MyLidarData& lidar,
    const MAPSImage& camera,
    const MyImuData& imu)
{
    // Fuse data here
    MAPS::OutputGuard<MyFusedData> out(this, Output(0));
    out.Data() = Fuse(lidar, camera, imu);
    out.Timestamp() = ts;
}
```

### Component with Grimoire Configuration

```cpp
#include "maps.h"
#include <libraries/grimoire/grimoire.h>

class ConfiguredComponent : public MAPSComponent
{
    grimoire::Core m_config;
    double m_maxSpeed;

    void Birth() override
    {
        m_maxSpeed = m_config.readDoubleConfiguration(
            "config:/driving/limits/maxSpeed", 5.0);
    }

    void Core() override
    {
        // Use m_maxSpeed in processing
        MAPSIOElt* elt = StartReading(Input(0));
        if (!elt) return;
        double speed = std::min(elt->Float64(), m_maxSpeed);
        MAPSIOElt* out = StartWriting(Output(0));
        out->Float64() = speed;
        out->Timestamp() = elt->Timestamp();
        StopWriting(out);
    }
};
```

### Timed Processing (Periodic)

```cpp
void MyComponent::Birth()
{
    m_reader = MAPS::MakeInputReader::PeriodicSampling(
        this,
        MAPS::InputList{Input(0)},
        &MyComponent::OnTick,
        100000   // 100ms period (in microseconds)
    );
}

void MyComponent::Core()
{
    m_reader->Read();
}
```

### Rest-Based Component (No Input)

```cpp
// Component that generates data at a fixed rate (no inputs needed)
void MyGenerator::Core()
{
    Rest(100000); // Sleep 100ms (the ONE blocking call)

    MAPS::OutputGuard<int32_t> out(this, Output(0));
    out.Data() = GenerateValue();
    out.Timestamp() = MAPS::CurrentTime();
}
```

## Debugging Components

### In RTMaps Studio

1. **Console output**: Use `ReportInfo()`, `ReportWarning()`, `ReportError()` in component code
2. **Breakpoints**: Attach debugger to `rtmaps` process, set breakpoints in Core/Birth/Death
3. **Data probes**: Connect `RTMaps_Viewer` or `RTMaps_Recorder` to outputs to inspect data
4. **Timestamps**: Check timestamp consistency in the Data Monitor panel

### Logging API

```cpp
ReportInfo("Processing frame %d", frameCount);
ReportWarning("Dropped frame, late by %lld us", lateness);
ReportError("Failed to initialize sensor");
```

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Component blocks forever in Core() | Missing blocking call or deadlock | Ensure exactly ONE blocking call in Core(). Check all inputs are connected. |
| Data arrives out of order | Wrong reader type | Use `FifoReader` for ordered data, `SamplingReader` for latest-only |
| Diagram won't load package | `.pck` not in search path | Add `--pck-path` or check package paths in Studio preferences |
| Timestamp jumps | Mixing real-time and replay sources | Ensure all sources use same time base |
| Memory leak | OutputGuard not used, forgetting StopWriting | Use `OutputGuard` (RAII) instead of manual `StartWriting`/`StopWriting` |
| Core() called but no data | Input not connected in diagram | Check wire connections in Studio |
| Properties return wrong values | Reading properties in Dynamic() | Properties are only valid from Birth() onwards |

## SDK Reference

### Key Headers

| Header | Content |
|--------|---------|
| `maps.h` | Master include - brings in all SDK headers, all macros |
| `maps_component.h` | `MAPSComponent` class definition |
| `maps_module.h` | `MAPSModule` base class (legacy) |
| `maps_io_access.hpp` | `InputReader`, `OutputGuard`, `MakeInputReader` |
| `maps_types.h` | `MAPSIOElt`, `MAPSTimestamp`, `MAPSString`, data type enums |

### Full API Reference

See `/opt/rtmaps/doc/RTMaps_SDK_API_Reference_*.pdf` (~1401 pages, use as lookup only).

### Samples

- Component templates: `/opt/rtmaps/templates.u/src/`
- SDK samples: `/opt/rtmaps/user_sdk/samples.u/src/`
- InputReader samples: `/opt/rtmaps/packages/rtmaps_input_reader/samples/src/`

## Related Skills

- **doyle**: C++ workspace manager — **required for building RTMaps components at Navya** (`project.yaml`, `doyle build setup`, `doyle upload`)
- **navya**: Ecosystem overview, shared infrastructure, NavyaDrive layout, cross-tool workflows
- **spellcaster**: Drive composition — deploys `.pck` packages and `.rtd` diagrams via spells
- **grimoire**: Configuration library — `rtmaps.conf` uses grimoire JSON format; components read config via grimoire API
