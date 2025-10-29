# 🧠 LLM Workspace Notes — nixos-config Edition

This document defines the **LLM workspace standards** and operational workflow for the  
**nixos-config repository** — a modular, declarative, and multi-host NixOS configuration system.  
It synthesizes **LLM documentation standards**, commit conventions, validation rules, and project-specific workflows.  

---

## 📘 Context

This configuration manages **NixOS systems** with fully integrated **Home Manager**,  
**Flakes**, and **multi-host support** under shared user configuration.  
Each host (e.g. `nixos0`, `surface0`, `thinkpad0`) builds from a common flake tree and shares modules.

### Key Conventions
- No `home-manager` standalone: it’s integrated into NixOS flake builds.
- Flake rebuilds require explicit host targeting (per `user-config.nix`).
- Git tracking must include *all new files* under `hosts/`, `system_modules/`, and `home_modules/`.

---

## 🧩 Rebuild + Git Integration Commands

### One-Step Full Commit-Rebuild-Push
```bash
nixos-commit-rebuild-push "<[feat|fix|refactor|docs]:summary>"
```
> - Automatically runs `git add .`  
> - Validates commit message format  
> - Performs `flake check` and rebuilds system  
> - Pushes changes if successful

### Local Rebuild (No Git)
```bash
nixos-rebuild-basic
```
Used for temporary rebuild testing.  
Does not commit or push — ideal for flake evaluation or experimental changes.

---

## ⚒️ Core LLM Responsibilities

LLMs maintaining `nixos-config` **must ensure**:
1. Every newly created `.nix` file contains a valid **module header comment**.
2. Each commit follows the **structured format** below.
3. No flake-breaking modifications are pushed (run `nix flake check` always).
4. Content consistency is maintained across hosts, overlays, and user modules.
5. Updates to templates (`hosts/minimal.nix` and `hosts/home-minimal.nix`) mirror repository standards.

---

## 💾 Commit Message Rules (LLM-Aware Format)

### Format
```
<type>(scope): <action> <summary>

[optional body]
```

### Type Keywords
| Type | Meaning |
|------|----------|
| feat | New system/home module or feature |
| fix | Correct misconfiguration, module path, or logic |
| refactor | Code structuring without behavior change |
| docs | Update/specify documentation, comments, SPEC.md |
| style | Formatting and whitespace only |
| chore | Maintenance (flake input updates, dependency bumps) |
| perf | Performance optimization |
| revert | Undo a previous commit |

### Scope Examples
```
flake.nix
home_modules
system_modules
hosts
hypr_config
overlays
```

**Example Commits**
```bash
feat(home_modules): add zen-browser configuration
fix(fcitx5): temporarily disable qt6 build
docs(SPEC): update section 5 with new theme layout
refactor(system_modules): reorganize network stack setup
```

### LLM Validation Pattern
```bash
^(feat|fix|docs|style|refactor|test|chore|perf|revert)\([^)]+\): [a-z].+[^.]$
```
LLM commits failing this regex should trigger correction before finalization.

### Multi-Scope and List Support
Commits may include **comma-delimited scopes** and **list bodies** for grouped changes.

**Examples**
```bash
feat(home_modules,system_modules): add theme and display modules
```

```bash
docs(SPEC,llm-note): update validation and commit sections
```

Multi-line bodies are allowed to describe grouped file updates or features:

```bash
feat(hosts): add new host configurations

- nixos0: enable GitHub Actions runner
- thinkpad0: optimize power management
- surface0: add BD-PROCHOT fix
```

---

## 🧱 Module Header Conventions

Each `.nix` file must include a descriptive header in the following format:

### Template
```nix
# <Module Name>
#
# Purpose: <Brief description of its function>
# Dependencies: <pkg1, pkg2, ...> | None
# Related: <file1.nix, file2.nix> | None
#
# This module:
# - <What it enables/configures>
# - <Dependency or related feature>
# - <Additional internal notes>
```

### Example (System Module)
```nix
# Networking Configuration Module
#
# Purpose: Manage firewall and network manager configuration.
# Dependencies: networkmanager, wpa_supplicant
# Related: hardware.nix, services.nix
#
# This module:
# - Enables NetworkManager (wpa_supplicant backend)
# - Configures system firewall for SSH
# - Handles WiFi power management settings
```

### Sectioning Rules
| Header Level | Markup | Example |
|---------------|---------|----------|
| L1 | `# TITLE` + `=` underbar | `# AUDIO CONFIGURATION MODULE` |
| L2 | `## Section` + `-` underbar | `## PipeWire` |
| L3 | `### Subpoint` | `### Notes` |

**Example**
```nix
# DISPLAY CONFIGURATION MODULE
# ============================================
## Wayland Configuration
# --------------------------------------------
services.displayManager.sddm.enable = true;

### Notes
# Hyprland runs wayland-native; ensure no X11 dependencies persist.
```

---

## 🧭 File Tracking + Validation Rules

### Always Tracked
- All `.nix`, `.sh`, `.fish`, `.conf`, `.md`, and `flake.lock`
- All contents under:
  ```
  hosts/
  home_modules/
  system_modules/
  overlays/
  packages/
  hypr_config/
  syncthing_config/
  ```

### Ignored Files
Handled via `.gitignore`:
```
result*
work/
.temp/
.backup/
.direnv/
.vscode/
.idea/
*.img
*.zip
```

**LLMs must never add** temporary build artifacts to Git commits.

---

## 🧩 Flake Testing Workflow

### Before Commit
Run:
```bash
nix flake check --impure --accept-flake-config
```
On success:
```
✔ nixosConfigurations evaluated
✔ packages built successfully
```

If failure:
1. Inspect indicated line (syntax or missing import).  
2. Use `nixos-rebuild dry-run --flake .#<hostname>` for host validation.  
3. Fix and re-run `nix flake check`.  

### Recommended LLM Validation Chain
```
fcheck → nix flake check --impure --accept-flake-config
fshow  → nix flake show
```

### Common Errors
| Error | Description | Fix |
|-------|--------------|-----|
| `unexpected IN` | Syntax error | Fix brace or indentation |
| `file not found` | Bad import path | Verify `imports = [...]` |
| `infinite recursion` | Circular imports | Break or isolate dependencies |
| `type mismatch` | Wrong option type | Match to NixOS type |

---

## 🧩 Reproducibility and Multi-Host Awareness

- Architecture: x86_64-linux only (as of writing)  
- Distributed builds must pass SSH verification (`nixos0` → clients)  
- Cross-host structure:  
  ```
  nixos0  → build server (main)
  surface0 → client (mobile)
  thinkpad0 → client (performance-optimized)
  ```

Flake evaluation must pass on all three when:
```bash
for host in nixos0 surface0 thinkpad0; do nixos-rebuild dry-run --flake .#$host; done
```

---

## ⚒️ Validation Pipeline for LLM Commits

1. Check dependencies in `flake.nix` and `inputs` consistency.  
2. Validate using `nix flake check`.  
3. Run `nixos-rebuild` dry runs on all active hosts.  
4. Confirm all `.nix` headers have proper metadata.  
5. Commit once all validation passes.

---

## 💡 Example LLM Commit Flow

```bash
# Step 1 — Add new module
vim home_modules/fish.nix

# Step 2 — Insert standardized header
# (Purpose, Dependencies, This module section)

# Step 3 — Validate
nix flake check --impure

# Step 4 — Commit
git add .
git commit -m "feat(fish.nix): add custom fish helper functions"

# Step 5 — Rebuild
sudo nixos-rebuild switch --flake .#popcat19-nixos0
```

---

## ✅ Pre-Commit LLM Checklist
```
[ ] nix flake check passes (impure, accepted config)
[ ] Commit message follows LLM regex format
[ ] No temporary files or build artifacts added
[ ] Headers present for all new modules
[ ] hosts/minimal.nix and home-minimal.nix remain valid templates
```

---

## 🧠 LLM Writing Guidelines for nixos-config

| Category | Rule |
|----------|------|
| Tone | Declarative and technical |
| Verb style | Present tense: “Enables”, “Configures” |
| No | “I”, “we”, or conversational notes |
| Always include | One-liner Purpose field in headers |
| Code blocks | Use fenced triple-backtick markdown |
| Formatting | 100-character print width max per line |

### Example Good Style
```nix
# Environment Configuration Module
#
# Purpose: Manage system-wide environment variables for Wayland and Hyprland.
# Dependencies: nixpkgs
# Related: system_modules/display.nix
#
# This module:
# - Ensures Wayland applications use native protocols
# - Configures Ozone/GTK environment variables
# - Provides default paths for session variables
```

---

## 🔧 LLM Enforcement Actions

When generating or reviewing any `.nix` module, the assistant should:
1. Reject output if **Purpose** or **Dependencies** is missing.
2. Warn user if **flake check** not simulated.
3. Suggest consistent imports ordering:
   ```
   imports = [
     ./hardware.nix
     ../../system_modules/display.nix
     ../../home_modules/theme.nix
   ];
   ```
4. Refuse to structure commits lacking header conformance.

---

## 🧩 Maintenance Notes

- LLM-driven updates must preserve original indentation style (2 spaces).  
- Always maintain single trailing newline at file end.  
- Any section of this file modified should carry a `docs(llm-note): update section` commit.

---

## 📄 Reference Commands Summary

```
# Evaluate host
nixos-rebuild dry-run --flake .#popcat19-nixos0

# Validate flake tree
nix flake check --impure --accept-flake-config

# Show outputs
nix flake show

# List tracked modules
git ls-files home_modules/ system_modules/ overlays/ hosts/

# Generate hardware config (for new host)
sudo nixos-generate-config --show-hardware-config > ./hosts/newhost/hardware-configuration.nix
```

---

## 🐾 Postscript

This document defines LLM workspace responsibilities and formatting rules specifically for `nixos-config`.  
It supersedes the generic `llm-note.md` in this repository’s context.  
Every automation, code generation, or AI-assisted commit should adhere to these conventions.

**End of LLM Workspace Specification**