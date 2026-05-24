# popcat19-nixos-hm

Personal NixOS configuration — Hyprland + PMD theming, multi-host, profile-based.

## Quick start

```bash
# Clone and build for current host
git clone <repo-url> && cd popcat19-nixos-hm
sudo nixos-rebuild switch --flake .

# Build for specific host
sudo nixos-rebuild switch --flake .#popcat19-nixos0

# Update inputs
nix flake update
```

<details>
<summary>Architecture</summary>

```
.
├── configuration/
│   ├── base/                    # Minimal bootable skeleton
│   ├── builders/                # Distributed build host configs
│   ├── fish_functions/          # Custom Fish shell functions
│   ├── home/                    # Home-manager configuration
│   │   ├── hyprland/            # Hyprland compositor (shaders, scripts, modules)
│   │   ├── modules/             # Per-app home module (~40 modules)
│   │   ├── noctalia/            # Noctalia Wayland shell
│   │   └── wallpaper/           # Wallpaper assets
│   ├── hosts/                   # Per-machine configurations
│   ├── profiles/                # Composable profile presets
│   ├── secrets/                 # Agenix-encrypted secrets
│   ├── system/modules/          # System-level NixOS modules (~30 modules)
│   ├── nix-options.nix          # Nix daemon settings (features, GC, trusted users)
│   ├── stateversion.nix         # Single source of truth for state versions
│   └── user-config.nix          # Shared user/host/theme/fonts config
├── flake-modules/               # Flake-parts modules (nixos, overlays, formatter)
├── lib/                         # Shared helper library (mkHost, mkHome, helpers)
├── overlays/                    # Package overlays (OpenTabletDriver, Friction graphics)
├── tools/                       # CLI utilities (profile manager, debug, cachix push)
├── conventions/                 # Dev conventions (see conventions/DEVELOPMENT.md)
├── .github/workflows/           # CI: flake check, cachix push, dev→main sync
└── flake.nix                    # Flake entry point
```

</details>

<details open>
<summary>Hosts</summary>

| Host | Machine | Profile | Notes |
|------|---------|---------|-------|
| `popcat19-nixos0` | Desktop (AMD Ryzen 5 5500) | `default` | Dual monitor, ROCm, gaming + dev, distributed build server |
| `popcat19-surface0` | Surface Pro (i5-8350U) | `surface` | Touch/pen input, thermal management, WiFi fixes |
| `popcat19-thinkpad0` | ThinkPad laptop | `laptop` | External HDMI, TLP power management, zRAM |
| `popcat19-dedede0` | ChromeOS (shimboot) | `shimboot` | Pruned config, pinned systemd for ChromeOS compat |

</details>

<details>
<summary>Profiles</summary>

Profiles compose system modules into deployable presets. Each host points to one profile via its `user-config.nix`.

- **`default`** — Full desktop: Hyprland, PipeWire, virtualization, VPN, gaming, Syncthing, OpenRGB
- **`laptop`** — Desktop minus desktop-specifics; adds TLP
- **`surface`** — Surface Pro: touch, thermal throttling, surface-control group
- **`minimal`** — Headless/server: SSH, Docker, no display stack
- **`shimboot`** — ChromeOS shimboot: pruned home modules, minimal services

Manage profiles with `tools/profile-manager-tui.sh`.

</details>

<details>
<summary>Flake inputs</summary>

| Input | Purpose |
|-------|---------|
| `nixpkgs` | Unstable channel |
| `home-manager` | User-level dotfile management |
| `flake-parts` | Modular flake structure |
| `stylix` | System-wide theming (GTK, Qt, cursors) |
| `pmd` | Personal Material Design theme |
| `agenix` | Secret encryption |
| `aagl` | Anime game launchers |
| `zen-browser` | Zen browser package |
| `noctalia-shell` | Wayland bar/launcher |
| `llm-agents` | LLM agent tooling |
| `lm-modal` | Wayland LLM overlay |
| `opentabletdriver` | Drawing tablet driver (source) |
| `shimboot` | ChromeOS NixOS bootstrapping |

</details>

<details>
<summary>Home-manager modules</summary>

~40 modules covering: editors (Zed, VSCodium, Helix, Micro), terminals (Kitty), shell prompts (Starship), git config, browsers (Zen, Vesktop), gaming (MangoHUD, OBS), AI tools (Ollama, Playwright), screenshots, fonts, theming, file sync, and privacy tools.

See `configuration/home/modules/context.md` for the full inventory.

</details>

<details>
<summary>System modules</summary>

~30 modules covering: boot, audio (PipeWire), display (Hyprland + SDDM), networking (firewall, NetworkManager), hardware (Bluetooth, I2C), virtualization (Docker, libvirt, KVM, Waydroid), VPN (Mullvad), secret management (agenix), power management, OpenRGB, Sunshine streaming, SearXNG, Syncthing, tablet input, fonts, and XDG portals.

See `configuration/system/modules/context.md` for the full inventory.

</details>

<details>
<summary>Tools</summary>

- **`profile-manager-tui.sh`** — Interactive terminal UI for profile operations
- **`profile-manager.sh`** — Profile management CLI (create, set/get host profiles)
- **`debug-nix-config.sh`** — Diagnose Nix daemon config mismatches
- **`push-to-cachix.sh`** — Push derivations to personal Cachix cache
- **`test-profile-manager.sh`** — Profile manager test runner

</details>

<details>
<summary>CI/CD</summary>

| Workflow | Trigger | Action |
|----------|---------|--------|
| `flake-check.yml` | Push to `dev` | `nix flake check` on all hosts |
| `cachix-nixos.yml` | Push to `dev` | Build + push to Cachix |
| `sync-dev-main.yml` | Push to `main` | Sync back to `dev` (bidirectional) |

</details>

<details>
<summary>Development</summary>

See [`conventions/DEVELOPMENT.md`](conventions/DEVELOPMENT.md) for coding standards and repo conventions.

</details>

> ⚠️ Personal dotfiles — breaking changes may occur without notice.
