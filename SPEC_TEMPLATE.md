# 🧪 Technical Specification Template

**Purpose:**  
A comprehensive template for creating technical specification documents that follow consistent formatting, structure, and conventions. This template is based on proven documentation practices from complex software projects.

---

## 📋 How to Use This Template

1. **Copy this file** to your project as `SPEC.md`
2. **Replace all bracketed placeholders** `[like-this]` with your project-specific information
3. **Follow the formatting conventions** demonstrated in each section
4. **Remove unused sections** if they don't apply to your project
5. **Update the specification** whenever major architectural changes occur

---

# [Project Name] Technical Specification

**Status:** [Proof of Concept | Alpha | Beta | Stable | Production]  
**Target:** [Hardware platform, software environment, or deployment context]  
**License:** [License type and any mixed licensing notes]

---

## 1. Project Identity

### What This Is
- [Primary purpose in 1-2 sentences]
- [Key architectural decision or approach]
- [Deployment or distribution method]
- [Core technology stack]

### What This Is Not
- [Common misconception 1]
- [Common misconception 2]
- [Out-of-scope use case]
- [Unsupported scenario]

### Tested Hardware/Environments
```
[Primary Test Platform] ([identifier/codename])
├─ Status: [Working | Partial | Broken]
├─ [Feature 1]: [Status and notes]
├─ [Feature 2]: [Status and notes]
├─ [Feature 3]: [Status and notes]
└─ [Feature 4]: [Status and notes]

[Secondary Test Platform] ([identifier/codename])
├─ Status: [Working | Partial | Broken]
├─ [Feature 1]: [Status and notes]
├─ [Feature 2]: [Status and notes]
├─ [Feature 3]: [Status and notes]
└─ [Feature 4]: [Status and notes]
```

### Supported Platforms (Infrastructure Only)
```
[platform1], [platform2], [platform3], [platform4]
└─ Note: Only [platform1] confirmed working as of writing
```

---

## 2. System Architecture

### Layer Model
```
[Top Layer - User-facing]
    ↓
[Application Layer]
    ↓
[Framework/Runtime Layer]
    ↓
[System Layer]
    ↓
[Hardware Abstraction Layer]
    ↓
[Hardware/Firmware Layer]
```

### Configuration Layout
```
[project-root]/ (project root)
├─ [entry-point-file]           - [Purpose]
├─ [lock-file]                  - [Purpose]
├─ [config-file]                - [Purpose]
│
├─ [system-modules-dir]/        - [Purpose]
│  ├─ [core-modules-dir]/       - [Purpose]
│  │  ├─ [module-1].ext         - [Purpose]
│  │  ├─ [module-2].ext         - [Purpose]
│  │  ├─ [module-3].ext         - [Purpose]
│  │  └─ [module-4].ext         - [Purpose]
│  ├─ [feature-modules]/*.ext   - [Purpose]
│  └─ [arch-specific].ext       - [Purpose]
│
├─ [user-modules-dir]/          - [Purpose]
│  ├─ [packages-file]           - [Purpose]
│  ├─ [theme-file]              - [Purpose]
│  ├─ [app-configs]/*.ext       - [Purpose]
│  └─ [lib-dir]/                - [Purpose]
│
├─ [configs-dir]/               - [Purpose]
│  ├─ [variant-1]/
│  │  ├─ [config-file].ext      - [Purpose]
│  │  ├─ [hardware-config].ext  - [Purpose]
│  │  ├─ [user-config].ext      - [Purpose]
│  │  └─ [custom-configs]/      - [Purpose]
│  ├─ [variant-2]/
│  └─ [templates]/
│     ├─ [system-template].ext  - [Purpose]
│     └─ [user-template].ext    - [Purpose]
│
├─ [overlays-dir]/              - [Purpose]
│  ├─ [overlay-1].ext           - [Purpose]
│  ├─ [overlay-2].ext           - [Purpose]
│  └─ [overlay-3].ext           - [Purpose]
│
├─ [packages-dir]/              - [Purpose]
│  ├─ [category-1]/*.ext        - [Purpose]
│  └─ [category-2]/*.ext        - [Purpose]
│
├─ [feature-config-dir]/        - [Purpose]
│  ├─ [main-config].ext         - [Purpose]
│  ├─ [modules-dir]/            - [Purpose]
│  │  ├─ [module-1].ext         - [Purpose]
│  │  ├─ [module-2].ext         - [Purpose]
│  │  └─ [module-3].ext         - [Purpose]
│  ├─ [assets-dir]/             - [Purpose]
│  └─ [resources-dir]/          - [Purpose]
│
└─ [integration-dir]/           - [Purpose]
   ├─ [system-config].ext       - [Purpose]
   └─ [user-config].ext         - [Purpose]
```

### Critical Patches/Modifications
```
[Component Name]
└─ [patch-name].patch
   ├─ [What it changes]
   ├─ Required: [Why it's necessary]
   └─ Source: [Upstream or origin]

[Component Name 2]
└─ [modification description]
   ├─ [Implementation detail]
   └─ Source: [Origin]

[Component Name 3]
└─ [workaround-name]
   ├─ [Problem it solves]
   ├─ [Implementation approach]
   └─ Source: [Custom patch or upstream]
```

---

## 3. Component Reference

### Build Artifacts/Inputs
```
[artifact-name]
├─ Purpose: [Single-line intent]
├─ Dependencies: [dependency1, dependency2]
├─ Related: [related-component-1, related-component-2]
└─ Provides: [Key outputs or functionality]

[artifact-name-2]
├─ Purpose: [Single-line intent]
├─ Dependencies: [dependency1]
├─ Related: [related-component]
└─ Provides: [Key outputs or functionality]

[artifact-name-3]
├─ Purpose: [Single-line intent]
├─ Dependencies: None
├─ Related: None
└─ Provides: [Key outputs or functionality]
```

### Module Organization
```
[module-category].ext
├─ Purpose: [Single-line intent]
├─ Dependencies: [pkg1, pkg2] | None
├─ Related: [file1.ext, file2.ext] | None
└─ Provides: [Key exports or functionality]

[module-category-2].ext
├─ Purpose: [Single-line intent]
├─ Dependencies: [module-category]
├─ Related: [file3.ext]
└─ Provides: [Key exports or functionality]

[module-category-3].ext
├─ Purpose: [Single-line intent]
├─ Dependencies: [module-category, module-category-2]
├─ Related: [file4.ext, file5.ext]
└─ Provides: [Key exports or functionality]
```

### Configuration Variants
```
[config-variant-1]/
├─ Purpose: [Use case]
├─ Size Target: [Size constraint]
├─ [Key Feature 1]: [Implementation]
├─ [Key Feature 2]: [Implementation]
└─ Features: [Feature list]

[config-variant-2]/
├─ Purpose: [Use case]
├─ Size Target: [Size constraint]
├─ Extends: [config-variant-1]
├─ Adds: [Additional components]
└─ Features: [Feature list]

[config-variant-3]/
├─ Purpose: [Use case]
├─ Size Target: [Size constraint]
├─ [Key Feature 1]: [Implementation]
├─ [Key Feature 2]: [Implementation]
├─ [Key Feature 3]: [Implementation]
└─ Features: [Feature list]
```

---

## 4. Build Pipeline

### Reproducibility Matrix
```
Component              | Reproducible | Notes
-----------------------|--------------|------------------------
[Component 1]          | Yes          | [Reason]
[Component 2]          | Yes          | [Reason]
[Component 3]          | Mostly       | [Caveat]
[Component 4]          | No           | [Reason]
[Component 5]          | No           | [Reason]
```

### Build Graph
```
[entry-point-file]
├─ [build-configurations]
│  └─ [variant-configs]/[variant].ext
│     ├─ [system-modules]/*.ext (imports)
│     │  ├─ [core-modules]/*.ext
│     │  └─ [feature-modules].ext
│     │
│     ├─ [hardware-config].ext (generated)
│     │
│     └─ [user-config-manager].[username]
│        └─ [user-configs]/[variant].ext
│           ├─ [user-modules]/*.ext (imports)
│           │  ├─ [packages-file].ext (aggregates [packages-dir]/*.ext)
│           │  ├─ [theme-file].ext (applies theme)
│           │  └─ [app-configs].ext
│           │
│           └─ (optional) [variant-configs]/
│              └─ [feature-config].ext (overrides [feature-config-dir]/)
│                 └─ [modules]/*.ext
│
├─ [overlays] (final: prev:)
│  ├─ [overlay-manager].ext (imports)
│  │  ├─ [overlay-1].ext (theme packages)
│  │  ├─ [overlay-2].ext (version lock)
│  │  └─ [overlay-3].ext (compatibility fixes)
│  │
│  └─ [external-repository].overlays.default
│
└─ [user-config-function].ext (pure function)
   ├─ Input: { [parameter1] ?, [parameter2] ?, ... }
   ├─ Output: [Structured metadata]
   └─ Used by: All system and user modules
```

### Pure vs Impure Operations
```
Pure ([build system] sandbox):
├─ Package installation
├─ Configuration file generation
├─ Module evaluation
└─ Derivation building

Impure (requires [privileges]):
├─ [build-command] [switch] (system activation)
├─ [user-env-manager] activation (user environment)
├─ [remote-connection] connections
├─ [bootloader] installation
└─ Hardware probing ([hardware-config].ext)
```

---

## 5. Configuration System

### User Configuration Entry Point
```
[user-config-file].ext (pure function)
├─ [category].[option1]               - [Description]
├─ [category].[option2]               - [Description]
├─ [category].[option3]               - [Description]
├─ [setting-group].*                  - [Description]
├─ [system-param]                     - [Description]
├─ [locale-param]                     - [Description]
└─ [path-definitions].*               - [Description]
```

### Configuration Layers
```
┌─────────────────────────────────────┐
│ [Custom Config Layer]               │ ← Highest priority
├─────────────────────────────────────┤
│ [Application Config Layer]          │
├─────────────────────────────────────┤
│ [Base Config Layer]                 │
├─────────────────────────────────────┤
│ [System Defaults]                   │ ← Lowest priority
└─────────────────────────────────────┘
```

### Module Structure
```
[config-root]/
├─ [user-config-file]                  - [Purpose]
├─ [base-config-dir]/
│  ├─ [main-config-file]               - [Purpose]
│  └─ [modules-subdir]/
│     ├─ [module-1].ext                - [Purpose]
│     ├─ [module-2].ext                - [Purpose]
│     ├─ [module-3].ext                - [Purpose]
│     ├─ [module-4].ext                - [Purpose]
│     ├─ [subdir-1]/
│     │  ├─ [helper-1].ext             - [Purpose]
│     │  ├─ [helper-2].ext             - [Purpose]
│     │  └─ [helper-3].ext             - [Purpose]
│     └─ [subdir-2]/
│        ├─ [utility-1].ext            - [Purpose]
│        └─ [utility-2].ext            - [Purpose]
├─ [extended-config-dir]/
│  ├─ [main-config-file]               - [Purpose]
│  ├─ [system-modules]/
│  │  ├─ [module-1].ext                - [Purpose]
│  │  └─ [module-2].ext                - [Purpose]
│  ├─ [user-modules]/
│  │  ├─ [module-1].ext                - [Purpose]
│  │  ├─ [module-2].ext                - [Purpose]
│  │  ├─ [module-3].ext                - [Purpose]
│  │  ├─ [lib]/
│  │  │  └─ [library-module].ext       - [Purpose]
│  │  └─ [packages]/
│  │     ├─ [package-category-1].ext   - [Purpose]
│  │     └─ [package-category-2].ext   - [Purpose]
│  └─ [feature-config-dir]/
│     ├─ [feature-config-1].ext        - [Purpose]
│     ├─ [feature-config-2].ext        - [Purpose]
│     └─ [feature-modules]/
│        ├─ [feature-module-1].ext     - [Purpose]
│        └─ [feature-module-2].ext     - [Purpose]
└─ [assets-dir]/
   └─ [asset-file]
```

---

## 6. Execution/Deployment Mechanism

### Execution Tree
```
[System Init] (PID 0)
└─ [Boot Stage 1]
   └─ [Boot Stage 2]
      └─ [Runtime Init] (PID 1)
         └─ [Initialization Process]
            └─ [Detection Phase]
               └─ [Discovery Process]
                  ├─ [Option 1 Check]
                  ├─ [Option 2 Check]
                  └─ [Option 3 Check]
                     └─ [Selection Menu]
                        └─ [User Choice]
                           └─ [execution-function]()
                              ├─ [Pre-flight Check 1]
                              │  └─ [Action if needed]
                              ├─ [Mount/Setup Phase]
                              ├─ [integration-function]()
                              │  └─ [Resource Binding]
                              │     ├─ [Bind 1]
                              │     └─ [Bind 2]
                              ├─ [Cleanup Tasks]
                              └─ [Transition to Runtime]
                                 └─ exec [main-runtime-binary]
                                    └─ [Runtime Manager] (PID 1 in new context)
                                       ├─ [Service 1]
                                       ├─ [Service 2]
                                       └─ [Service 3]
                                          └─ [Application Layer]
                                             └─ [User Applications]
```

### Resource Integration
```
[resource-source] ([location])
├─ [resource-type-1]/          - [Purpose]
└─ [resource-type-2]/          - [Purpose]

integration-function()
├─ [Action 1]
├─ [Action 2]
└─ [Action 3]

Why [approach] instead of [alternative]?
├─ [Benefit 1]
├─ [Benefit 2]
└─ [Benefit 3]
```

---

## 7. Known Constraints

### Hardware/Platform Support
```
Feature       | Status      | Notes
--------------|-------------|----------------------------------
[Feature 1]   | Working     | [Details]
[Feature 2]   | Variable    | [Platform-dependent notes]
[Feature 3]   | Limited     | [Specific limitations]
[Feature 4]   | Unavailable | [Reason]
[Feature 5]   | Variable    | [Conditions]
```

### Software Limitations
```
[Component 1]
├─ [Limitation 1]
├─ [Limitation 2]
└─ [Limitation 3]

[Resource Constraints]
├─ [Constraint 1]: [Details]
├─ [Constraint 2]: [Details]
└─ [Constraint 3]: [Details]

[Performance Notes]
├─ [Bottleneck 1]
├─ [Bottleneck 2]
└─ [Bottleneck 3]
```

### [Specific Limitation Category]
- [Limitation details with version or configuration context]

### Incompatible Configurations
```
[Incompatible Scenario 1]
└─ [Reason]
   └─ [Workaround status]

[Incompatible Scenario 2]
└─ [Affected platforms]
   └─ [Reason]
```

---

## 8. Extension Points

### Adding New [Platform/Variant]
```
Required steps:
1. [Step 1 description]:
   └─ [tool/script] > [output-file]

2. Create [config-dir]/[variant]/ directory:
   ├─ [config-file].ext (copy from [template-file])
   ├─ [user-config].ext (copy from [user-template])
   └─ [hardware-config].ext (from step 1)

3. Add [variant] to [config-file]:
   └─ [list] = [ ... "[variant]" ];

4. (Optional) Add [variant]-specific modules:
   ├─ [config-dir]/[variant]/[system-modules]/*.ext
   └─ [config-dir]/[variant]/[custom-configs]/*.ext

5. Build and test:
   └─ [build-command] [variant]
```

### Adding [Component Type]
```
[config-path]/[module-file].ext
└─ { [deps], [userConfig], ... }: {
     # [Configuration options]
   }

Import in [config-dir]/[variant]/[config-file].ext:
└─ imports = [ ../../[module-path]/[module-file].ext ];
```

### Adding [Helper/Utility Type]
```
[helpers-path]/[new-helpers-file].ext
└─ [package-definition] = [
     ([helper-creation-function] "[command-name]" ''
       # [description]
     '')
   ];

Import in:
└─ [parent-config-file]
```

### Adding Packages
```
[packages-dir]/[category]/[package-category].ext
└─ { [deps], ... }: with [deps]; [
     [package-1]
     [package-2]
   ]

Automatically imported by [packages-file].ext
```

### Adding Overlays
```
[overlays-dir]/[name].ext
└─ final: prev: {
     [package-name] = prev.[package-name].[override-attrs] (old: {
       # Modifications
     });
   }

Import in [overlay-manager].ext:
└─ Add to list: [ (import ../[overlays-dir]/[name].ext) ]
```

### [Feature] Customization
```
Current: [Current state]
Proposed: [Proposed enhancement]

1. Create [config-dir]/[variant]/[custom-configs]/:
   ├─ [main-config].ext (imports shared [modules] + [variant] files)
   ├─ [layout-file].ext ([variant]-specific layout)
   └─ [panel-config].ext ([variant]-specific panel layout)

2. [main-config].ext imports:
   └─ ../../../[feature-config-dir]/[modules]/*.ext (shared)

3. Define [variant]-specific settings in [layout-file].ext

Example per-[variant] layout:
├─ [variant-1]: [Layout description]
├─ [variant-2]: [Layout description]
└─ [variant-3]: [Layout description]

Example per-[variant] [component] ([panel-config].ext [layouts]):
└─ [Variant] configs include [widget], [other-variant] configs omit it
```

---

## 9. Maintenance Guide

### When to Update This Spec

**Component Changes:**
```
[entry-file] modified
└─ Update: Section 4 (Build Pipeline)
          Section 6 (Execution Mechanism)

[user-config-file] modified
└─ Update: Section 5 (Configuration System)

New [system-module] added
└─ Update: Section 3 (Component Reference)

New [user-module] added
└─ Update: Section 3 (Component Reference)

New [variant] added/removed
└─ Update: Section 1 (Tested Hardware)
          Section 6 (Execution Mechanism)

New [overlay] added
└─ Update: Section 2 (Critical Patches)
          Section 3 (Component Reference)

Known issue discovered
└─ Update: Section 7 (Known Constraints)

New extension pattern created
└─ Update: Section 8 (Extension Points)
```

### Updating [Artifact Type]
```
[tool/script] [arguments]
├─ Updates: [target-files]
└─ Triggers: [downstream-effects]

[another-tool/script]
├─ Updates: [target-files]
└─ Triggers: [downstream-effects]
```

### Spec File Organization
```
Each section is independently updateable
└─ Changes to Section N should not require rewriting Section M

Avoid:
├─ Cross-references between sections (prefer duplication)
├─ Time-sensitive data (use "current state" language)
├─ Feature priority markers ("important", "critical")
└─ Implementation timelines ("will be added", "coming soon")

Prefer:
├─ State descriptions ("exists", "works", "fails")
├─ Component relationships (parent/child)
├─ Decision rationale ("why this approach")
└─ Failure modes ("when this breaks")
```

### Spec Validation Checklist
```
□ No flowcharts (use tree structures)
□ No 'NEW' or priority markers
□ No dates or version numbers (use git history)
□ No unverified performance claims
□ Each section independently comprehensible
□ Token-efficient (avoid prose, use lists)
□ Scannable headings with clear hierarchy
□ Code examples are copy-pasteable
```

---

## 10. Quick Reference

### Common Commands
```
[Primary build command]:
└─ [command] [args]

[Variant build command]:
└─ [command] [variant-args]

[Feature-specific command]:
└─ [command] [feature-args]

[Deployment command]:
└─ [command] [deploy-args]

[Post-install command]:
└─ [command]

[Setup command]:
└─ [command]

[Update command]:
└─ [command] [update-args]

[Utility command]:
└─ [command]
```

### Custom Functions/Scripts
```
[function-name] '[argument]':
└─ [Description of what it does]

[script-name]:
└─ [Simple description]

[helper-function]:
└─ [Description]

[utility-function]:
└─ [Description]

[maintenance-function]:
└─ [Description]

[debug-function]:
└─ [Description]
```

### File Paths
```
Configuration:
├─ [project-root]/                     - Project root
├─ [project-root]/[entry-file]         - Entry point
├─ [project-root]/[user-config-file]   - User metadata
├─ [project-root]/[system-modules]/    - System modules
├─ [project-root]/[user-modules]/      - Home modules
├─ [project-root]/[configs-dir]/[variant]/ - Variant-specific config
├─ [project-root]/[templates]/[system-template].ext - System config template
└─ [project-root]/[templates]/[user-template].ext - User config template

Build artifacts:
├─ [output-path]/[artifact-1]            - [Purpose]
├─ [output-path]/[artifact-2]/           - [Purpose]
├─ [legacy-path]/[legacy-config]         - [Purpose]
└─ [user-profiles]/                      - [Purpose]

Runtime state:
├─ [runtime-config]/                     - [Purpose]
├─ [user-data]/[component-1]/            - [Purpose]
├─ [user-data]/[component-2]/            - [Purpose]
└─ [shared-data]/                        - [Purpose]
```

### Troubleshooting Entry Points
```
[Problem category 1]:
└─ Section 4 (Build Pipeline) → Reproducibility Matrix

[Problem category 2]:
└─ Section 2 (Critical Patches) → [Component Name]
   Section 7 (Known Constraints) → Software Limitations

[Problem category 3]:
└─ Section 2 (Critical Patches) → [Component Name]
   [configs-dir]/[variant]/[system-modules]/[services].ext

[Problem category 4]:
└─ [configs-dir]/[variant]/[system-modules]/[power-management].ext

[Problem category 5]:
└─ [configs-dir]/[variant]/[custom-configs]/[layout-file].ext

[Problem category 6]:
└─ Section 3 (Component Reference) → Module Organization

[Problem category 7]:
└─ Section 6 (Execution Mechanism) → Execution Tree

[Problem category 8]:
└─ Section 5 (Configuration System) → Configuration Layers

[Problem category 9]:
└─ Section 7 (Known Constraints) → Incompatible Configurations

Want to add new [variant]:
└─ Section 8 (Extension Points) → Adding New [Platform/Variant]

Want to customize per-[variant] [feature]:
└─ Section 8 (Extension Points) → [Feature] Customization
   [configs-dir]/[variant]/[custom-configs]/

[Component] missing:
└─ Section 3 (Component Reference) → Module Organization
   Section 8 (Extension Points) → Adding [Component Type]
```

---

**End of Specification**  
For implementation details, see source files in repository.  
For community support, see [support-location].  
For upstream documentation, see [upstream-project].

---

## 📝 Template Usage Notes

### Style Guidelines
- Use present tense to describe current state
- Keep descriptions concise and technical
- Use code blocks for all structured data
- Avoid marketing language or future promises
- Each section should be independently understandable

### Customization Tips
1. **Remove unused sections** - If a section doesn't apply, delete it entirely
2. **Adapt terminology** - Replace generic terms with project-specific ones
3. **Adjust depth** - Add more subsections for complex areas, simplify for simple projects
4. **Maintain consistency** - Use the same formatting style throughout
5. **Update regularly** - Keep the spec in sync with actual implementation

### Common Adaptations
- **Software projects**: Focus on modules, APIs, and deployment
- **Hardware projects**: Emphasize physical interfaces, drivers, and constraints
- **Research projects**: Document experimental setups and methodologies
- **Infrastructure projects**: Detail network topology and service dependencies