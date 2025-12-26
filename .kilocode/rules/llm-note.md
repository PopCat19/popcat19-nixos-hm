# LLM Workspace Notes — nixos-config Edition

LLM workspace standards for modular, declarative, multi-host NixOS configuration system.

## Key Conventions

- Home Manager integrated into NixOS flake builds
- Flake rebuilds require explicit host targeting
- Git tracking includes all files under hosts/, system_modules/, home_modules/

## Core LLM Responsibilities

1. Every .nix file contains valid module header comment
2. Commits follow structured format
3. No flake-breaking modifications (run `nix flake check`)
4. Content consistency across hosts, overlays, user modules
5. Templates mirror repository standards

## Commit Message Rules

### Format
```
<type>(scope): <action> <summary>
```

### Type Keywords
- feat: New system/home module or feature
- fix: Correct misconfiguration, module path, logic
- refactor: Code structuring without behavior change
- docs: Update/specify documentation, comments, SPEC.md
- style: Formatting and whitespace only
- chore: Maintenance (flake input updates, dependency bumps)
- perf: Performance optimization
- revert: Undo previous commit

### Validation Pattern
```bash
^(feat|fix|docs|style|refactor|test|chore|perf|revert)\([^)]+\): [a-z].+[^.]$
```

## Module Header Conventions

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
| Level | Markup | Example |
|-------|--------|---------|
| L1 | `# TITLE` + `=` | `# AUDIO MODULE` + `# ====` |
| L2 | `## Section` + `-` | `## PipeWire` + `# ----` |
| L3 | `### Subpoint` | `### Notes` |

## Flake Testing Workflow

### Before Commit
```bash
nix flake check --impure --accept-flake-config
```

### Host Validation
```bash
for host in nixos0 surface0 thinkpad0; do
  nixos-rebuild dry-run --flake .#$host
done
```

## Pre-Commit Checklist

- [ ] nix flake check passes (impure, accepted config)
- [ ] Commit message follows LLM regex format
- [ ] No temporary files or build artifacts added
- [ ] Headers present for all new modules
- [ ] hosts/minimal.nix and home-minimal.nix remain valid templates

## Style Guidelines

- Tone: Declarative and technical
- Verb style: Present tense ("Enables", "Configures")
- No first-person ("I", "we")
- Always include: One-liner Purpose field in headers
- Code blocks: Use fenced triple-backtick markdown
- Formatting: 100-character print width max per line

## Example Commit Flow

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

## Reference Commands

```bash
# Evaluate host
nixos-rebuild dry-run --flake .#popcat19-nixos0

# Validate flake tree
nix flake check --impure --accept-flake-config

# Show outputs
nix flake show

# List tracked modules
git ls-files home_modules/ system_modules/ overlays/ hosts/