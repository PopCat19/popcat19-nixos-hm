# 🧠 General LLM Workspace Reference

**Purpose:**  
Provide a unified workspace reference for **LLM-based development** and contributors to maintain consistent documentation, module formats, coding conventions, and project-wide workflow practices.  
This document acts as a **meta-specification** for any repository using structured documentation and **LLM-assisted collaboration**.

---

## 1. Identity and Scope

### What This Is
- A living reference for standardized commenting, structure, and flake workflows.
- A universal framework defining **LLM instruction rules**, **commit formatting**, and **workspace validation**.
- Repository-agnostic — usable across any structured codebase (Nix, Python, etc.).

### What This Is Not
- A single project’s technical spec (see SPEC.md for those)
- A user guide for programming languages
- A replacement for inline documentation — this is **for workspace-level consistency**

---

## 2. Document Architecture

```
llm-note.md (this file)
├─ Section 1: Identity and Scope
├─ Section 2: Document Architecture
├─ Section 3: Commenting Standards
├─ Section 4: Commit Message Format
├─ Section 5: Git and Tracking Rules
├─ Section 6: Flake & Evaluation Workflow
├─ Section 7: Module Header Reference
├─ Section 8: Validation & Automation
└─ Section 9: Quick Reference Commands
```

---

## 3. Commenting Standards

### 3.1 Module Header Template
```nix
# <Module Name>
#
# Purpose: <Single-line concise description>
# Dependencies: <pkg1, pkg2> | None
# Related: <file1.ext, file2.ext> | None
#
# This module:
# - <Key task or function>
# - <Another specific action>
# - <Integration or dependency note>
```

### 3.2 Section Header Hierarchy
| Level | Type | Separator | Example |
|-------|------|------------|----------|
| L1 | Main Heading | `=` | `# AUDIO CONFIGURATION MODULE` |
| L2 | Section/Subgroup | `-` | `## PipeWire Setup` |
| L3 | Inline Detail | None | `### Notes` |

**Example**
```nix
# DISPLAY CONFIGURATION MODULE
# ============================================
## Wayland Setup
# --------------------------------------------
services.displayManager.sddm.enable = true;

### Notes
# Hyprland replaces X11, ensure XDG portals are enabled.
```

### 3.3 Rule Set Summary
- Always describe **what** a section/config does, not how.
- Limit to **3–5 bullets** in the “This module” section.
- Use **active voice verbs**: “Enables”, “Sets”, “Configures”.
- Maintain exactly **one space after #** in all inline comments.

---

## 4. Commit Message Format

### 4.1 Structure
```
<type>(scope): <action> <summary>

[optional body]
```

### 4.2 Types
| Type | Meaning |
|------|----------|
| feat | New feature |
| fix | Bug fix |
| refactor | Structural rework with same behavior |
| docs | Documentation only |
| style | Code/formatting consistency |
| chore | Maintenance or dependency updates |
| perf | Performance changes |
| revert | Reverse prior commit |

### 4.3 Example
```
feat(networking): add IPv6 firewall configuration

- Enables IPv6 for UFW
- Updates default networking policy
```

### 4.4 Validation Regex
```bash
^(feat|fix|docs|style|refactor|test|chore|perf|revert)\([^)]+\): [a-z].+[^.]$
```

### 4.5 Reminder Checklist
```
[ ] Lowercase summary
[ ] No trailing period
[ ] Active verb ("add" not "added")
[ ] ≤72 characters total
[ ] “why” in body if not obvious
```

---

## 5. Git and Tracking Rules

### 5.1 Always Track
```
*.nix, *.sh, *.py, *.fish, *.md, LICENSE, flake.lock
/tools/*, /modules/*, /scripts/*, /overlays/*
```

### 5.2 Never Track
```
result*
work/
temp/
.direnv/
.vscode/
/.idea
*.img
*.zip
```

### 5.3 Practical Commands
```bash
# View tracking
git ls-files

# Discover ignored files
git status --ignored

# Ensure lockfile updated
nix flake lock --update-input nixpkgs
```

---

## 6. Flake & Evaluation Workflow

### 6.1 Rebuild and Validation
```bash
nixos-rebuild switch --flake .#<host>
nix flake check --impure --accept-flake-config
```

### 6.2 Build Graph Quick Test
```bash
nix flake show
nix build .#nixosConfigurations.<hostname> --dry-run
```

### 6.3 Validation Failures
| Error | Meaning | Fix |
|--------|----------|------|
| “unexpected IN” | Syntax error | Fix extra commas/braces |
| “file not found” | Missing import | Check `imports = [ ... ];` |
| “infinite recursion” | Circular dependency | Verify self-imports |
| “type mismatch” | Wrong value | Check expected option type |

---

## 7. Module Header Reference

### Template Ready-to-Copy
```nix
# <Module Title>
#
# Purpose: <Concise functional goal>
# Dependencies: <Package names> | None
# Related: <Linked modules> | None
#
# This module:
# - <Enables something>
# - <Configures something>
# - <Integrates something>
```

### Notes
- Maintain a one-line **Purpose**
- Keep 3–5 bullets max
- Always uppercase first word in every bullet

---

## 8. Validation & Automation

### Continuous Integration
LLMs should ensure all commits validate with:
```bash
nix flake check --impure --accept-flake-config
```

Expected success:
```
✔ flake evaluation completed
✔ all derivations valid
```

### Pre-push Hook Example
```bash
#!/bin/bash
nix flake check --impure --accept-flake-config || { echo "Flake check failed"; exit 1; }
```

LLMs must refuse to finalize a commit summary if validation fails unless explicitly allowed under `[skip-check]`.

---

## 9. Quick Reference Commands

### Evaluation
```bash
nix flake show
fastfetch
whoami && hostname
```

### Git
```bash
git add .
git commit -m "feat(module): add display configuration"
git push
```

### Build/Check
```bash
nixos-rebuild switch --flake .#<host>
nix flake check
```

### Recovery / Debug
```bash
journalctl -xe
sudo dmesg | tail -50
systemctl status <service>
```

---

## 10. Meta Guidelines

### ❖ General Rule Hierarchy
1. **Semantic Headers > Raw Comments**  
   → Every module must declare purpose and dependencies.
2. **Descriptive Commits > Minimal Commits**  
   → Write self-explanatory messages.
3. **Validation > Speed**  
   → Never skip flake checks before committing or pushing.

### ❖ Tonal / Writing Guidance
- Prefer declarative tone: “This module enables …”
- Avoid anthropomorphic or marketing language
- Keep paragraphs ≤4 lines
- Define every acronym upon first use
- When instructing an LLM, maintain neutral and descriptive phrasing

### ❖ Update Protocol
- Update this file whenever **comment style**, **flake workflow**, or **commit conventions** evolve.
- Keep all referencing repositories aligned; mark generated headers with:
  ```
  # Generated by LLM
  ```

---

## 11. Example: Full Workflow Snapshot

```bash
# Create new module
touch ./system_modules/networking.nix

# Write module header
vim ./system_modules/networking.nix
# --> Insert standardized header (Purpose, Dependencies, etc.)

# Validate flake
nix flake check --impure --accept-flake-config

# Commit with LLM-approved syntax
git add .
git commit -m "feat(networking): add basic network configuration"

# Rebuild host
sudo nixos-rebuild switch --flake .#popcat19-nixos0
```

---

**End of General LLM Workspace Reference**  
Maintained under internal **LLM documentation standards** for clarity, structure, and reproducibility.  
For project-specific details, see `SPEC_TEMPLATE.md` or repository-local `SPEC.md`.