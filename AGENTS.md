# AGENTS.md

## Project overview

Personal NixOS + Home Manager multi-host configuration. Hyprland compositor, PMD theming, profile-based host presets. 4 hosts (desktop, Surface, ThinkPad, ChromeOS), ~40 home modules, ~35 system modules.

## Setup commands

```bash
# Build for current host
sudo nixos-rebuild switch --flake .

# Build for specific host
sudo nixos-rebuild switch --flake .#popcat19-nixos0

# Update flake inputs
nix flake update

# Format Nix files
nix fmt .
```

## Build and test

```bash
# Validate full flake (resource-intensive; CI runs on push)
nix flake check --accept-flake-config

# Lint shell scripts
./conventions/dev-conventions.sh lint

# Fast local checks (run before commit)
statix fix . && deadnix -e . && nix fmt .
```

## Code style

- **Nix:** `nixfmt` (RFC 166). `let...in` for locals, `inherit` when names match, alphabetize attrsets, `follows` for input pinning.
- **Fish:** `set -l` for locals, `$status` not `$?`, `string` builtins over `sed`/`tr`.
- **Bash:** `#!/usr/bin/env bash`, strict mode (`set -Eeuo pipefail`), `[[ ]]` over `[ ]`.
- **Full reference:** `conventions/DEVELOPMENT.md`

## Directory structure

```
configuration/     NixOS + Home Manager config (hosts, profiles, modules, secrets)
flake-modules/     Flake-parts modules (nixos, nix-on-droid, formatter, overlays)
lib/               Builder functions (mk-host, mk-home) and helpers
overlays/          Custom package overlays
tools/             CLI utilities (profile manager, debug)
conventions/       Dev conventions and tooling
.github/           CI workflows (flake-check, dev-main sync)
```

## Conventions

- **File naming:** `kebab-case.ext` for files, `snake_case/` for directories
- **File headers:** Every module file must have a `Purpose:` line in its header
- **context.md:** Directories with 5+ non-obvious files require a context.md; keep it in sync with file additions/removals
- **Depth limit:** Max 6 levels from repo root
- **Module wiring:** Every new file must be imported somewhere; remove references before deleting
- **DRY validation:** Run `./conventions/dev-conventions.sh lint` for shell, CI for Nix
- **Full reference:** `conventions/DEVELOPMENT.md`, quick reference: `conventions/SKILL.md`

## Commit format

```
<type>(scope): <verb> <summary>
```

Types: `feat` `fix` `refactor` `docs` `style` `test` `chore` `perf` `revert`
Append `[untested]` if skipping flake check, `[skip-check]` if intentionally bypassing checks.

## Gotchas

- **Flakes read from git tree.** Always `git add --intent-to-add .` before running flake commands, or newly created files will be invisible.
- **Never rebase shared branches** (main, dev). Squash/rebase only on experimental branches.
- **Secrets** managed via agenix; encrypted files in `configuration/secrets/`.
- **Host-specific config** lives at `configuration/hosts/<hostname>/`. Each host references a profile from `configuration/profiles/`.
- **Reuse `follows`** to avoid duplicate nixpkgs instances: `inputs.foo.inputs.nixpkgs.follows = "nixpkgs"`.
