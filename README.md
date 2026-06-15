# popcat19-nixos-hm

NixOS + Home Manager multi-host configuration: Hyprland, PMD theming, profile presets, Klipper 3D printer appliance, one-shot installer images.

## Quick start

### From an existing NixOS install

```bash
git clone https://github.com/PopCat19/popcat19-nixos-hm
cd popcat19-nixos-hm
sudo nixos-rebuild switch --flake .
```

### From the one-shot installer image

Build and write the minimal installer to a USB stick, then boot from it:

```bash
nix build .#installer-zst
zstd -d result/popcat19-installer.img.zst -o installer.img
sudo dd if=installer.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Login as `popcat19` / `popcat19`, then switch to any host:

```bash
cd ~/popcat19-nixos-hm
sudo nixos-rebuild switch --flake .#popcat19-nixos0
```

### Pi SD card image

Two options: NixOS or Alpine diskless:

```bash
# NixOS printer appliance (full closure baked in)
nix build .#sd-popcat19-klipper0

# Alpine diskless (immutable read-only root, no DB corruption on power loss)
nix build .#alpine-klipper-img

# Write with helper
sudo ./tools/write-image.sh klipper -d /dev/sdX          # NixOS
sudo ./tools/write-image.sh alpine-klipper -d /dev/sdX  # Alpine
```

> ⚠️ The NixOS sd-image requires `--impure` for SSH key seeding. Alpine images are pure.

<details open>
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
│   ├── services/                # Service configuration bundles (zrok, sillytavern)
│   ├── shared/                  # Shared user-config kernel (identity, theme, fonts, features)
│   ├── system/modules/          # System-level NixOS modules (~35 modules)
│   │   └── klipper/             # Klipper 3D printer stack (printer, moonraker, mainsail, AP fallback)
│   ├── nix-options.nix          # Nix daemon settings (features, GC, trusted users)
│   └── stateversion.nix         # Single source of truth for state versions
├── flake-modules/               # Flake-parts modules (nixos, images, overlays, formatter, nix-on-droid)
├── lib/                         # Shared helper library (mkHost, mkHome, helpers)
├── overlays/                    # Package overlays (OpenTabletDriver, Friction graphics)
├── tools/                       # CLI utilities (profile manager, debug)
├── conventions/                 # Dev conventions (see conventions/DEVELOPMENT.md)
├── .github/workflows/           # CI: flake check, dev→main sync
└── flake.nix                    # Flake entry point
```

</details>

<details open>
<summary>Hosts</summary>

| Host | Machine | Arch | Profile | Notes |
|------|---------|------|---------|-------|
| `popcat19-nixos0` | Desktop (AMD Ryzen 5 5500) | x86_64 | `default` | Dual monitor, ROCm, gaming + dev, distributed build server |
| `popcat19-surface0` | Surface Pro (i5-8350U) | x86_64 | `surface` | Touch/pen input, thermal management, WiFi fixes |
| `popcat19-thinkpad0` | ThinkPad laptop | x86_64 | `laptop` | External HDMI, TLP power management, zRAM |
| `popcat19-dedede0` | ChromeOS (shimboot) | x86_64 | `shimboot` | Pruned config, pinned systemd for ChromeOS compat |
| `popcat19-klipper0` | Raspberry Pi 4B | aarch64 | `klipper` | Headless printer appliance, setup AP fallback |
| `popcat19-aarch640` | Generic aarch64 stub | aarch64 | `minimal` | Template for new aarch64 hosts |

</details>

<details>
<summary>Profiles</summary>

Profiles compose system modules into deployable presets. Each host points to one profile via its `user-config.nix`.

- **`default`**: Full desktop: Hyprland, PipeWire, virtualization, VPN, gaming, Syncthing, OpenRGB
- **`laptop`**: Desktop minus desktop-specifics; adds TLP, zRAM
- **`surface`**: Surface Pro: touch, thermal management, surface-control group
- **`minimal`**: Headless/server: SSH, Docker, no display stack
- **`shimboot`**: ChromeOS shimboot: pruned home modules, minimal services
- **`klipper`**: Pi 4B printer appliance: Klipper, Moonraker, Mainsail, WiFi, AP fallback

Manage profiles with `tools/profile-manager-tui.sh`.

</details>

<details>
<summary>Images</summary>

The flake produces one-shot installer and device images with the flake source pre-cloned at `~/popcat19-nixos-hm`.

| Package | System | Description |
|---------|--------|-------------|
| `installer-raw` | x86_64-linux | Minimal raw-EFI disk image (user, fish, SSH, sing-box, git) |
| `installer-zst` | x86_64-linux | Same, zstd-compressed |
| `sd-popcat19-klipper0` | aarch64-linux | Pi 4B SD card image (full Klipper closure, zstd-compressed) |
| `alpine-klipper-apkovl` | x86_64-linux | Alpine diskless apkovl tarball for Klipper Pi 4B |
| `alpine-klipper-img` | x86_64-linux | Alpine diskless dd-able SD image for Klipper Pi 4B (FAT32+ext4, MBR) |

The alpine-klipper images are pure Nix derivations (no --impure, no mounts, no sudo).
Flash alpine-klipper-img directly: `sudo dd if=result of=/dev/mmcblk0 bs=4M status=progress conv=fsync`
or use the write helper: `sudo ./tools/write-image.sh alpine-klipper -d /dev/mmcblk0`

The installer includes sing-box TUN proxy (togglable via `singbox_on` / `singbox_off`), so you can rebuild behind a proxy from first boot.

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
| `aagl` | Anime game launchers (x86_64 only) |
| `zen-browser` | Zen browser package |
| `nixcord` | Vesktop Discord client with Vencord |
| `nix-gaming` | Low-latency PipeWire module |
| `noctalia-shell` | Wayland bar/launcher |
| `llm-agents` | LLM agent tooling |
| `nix-on-droid` | Android Nix environment |
| `nixos-raspberrypi` | Pi 4B hardware support (U-Boot, kernel, firmware) |
| `shimboot` | ChromeOS NixOS bootstrapping |

</details>

<details>
<summary>Klipper Pi features</summary>

Two deployment options for the `popcat19-klipper0` host:

### NixOS (sd-popcat19-klipper0)

- **Klipper** + **Moonraker** + **Mainsail**: full web-controlled printer stack
- **WiFi client**: seeded once from agenix secret, then mutable at runtime
- **Fallback AP**: if home WiFi is unreachable, the Pi broadcasts its own `Klipper-Setup`
  access point after 60s (password from agenix, `192.168.50.1/24`)
- Toggle manually: `klipper_ap_on` / `klipper_ap_off`
- SPI enabled for ADXL345 input shaper calibration
- Journald capped at 200 MB / 7 day retention for SD card longevity

### Alpine diskless (alpine-klipper-img)

For Pi 4B only: immutable read-only root that runs from RAM. Fixes NixOS DB corruption
on unclean poweroff. Built as a pure Nix derivation, output is a single dd-able image.

- **Alpine Linux**: runs from RAM, rootfs never mounted r/w
- **Persistent /home** on labelled ext4 partition (survives power loss)
- **Klipper** + **Moonraker** + **Mainsail**: installed on first boot via OpenRC services
- **Syncthing**: pi-klipper folder only (nixos0 + klipper), printer configs, no large shared pool
- **Starship prompt**: mirrors starship.nix config
- **Fish shell** with `kupdate` alias for in-place stack updates
- **GPIO fan**: DT overlay (gpio-fan, GPIO14, 55°C), fan on above 55°C, off below
- **WiFi client** + **AP fallback**: AP appears on every boot if client WiFi unreachable after 60s
- **In-place update**: `kupdate` (git pull klipper/moonraker + download latest mainsail + restart)
- **First boot flow**: AP `Klipper-Setup` broadcasts (PSK `klipper-setup`, `192.168.50.1`).
  SSH in, set client PSK: `sudo nmcli connection modify Beave_Net_IoT wifi-sec.psk '<psk>'`,
  persist: `sudo lbu commit`, reboot, AP stops, client WiFi takes over.

See `configuration/system/modules/klipper/context.md` for module details.

</details>

<details>
<summary>Home-manager modules</summary>

~40 modules covering: editors (Zed, VSCodium, Helix, Micro), terminals (Kitty), shell prompts (Starship), git config, browsers (Zen, Vesktop), gaming (MangoHUD, OBS), AI tools (Ollama, Playwright), screenshots, fonts, theming, file sync, and privacy tools.

See `configuration/home/modules/context.md` for the full inventory.

</details>

<details>
<summary>System modules</summary>

~35 modules covering: boot, audio (PipeWire), display (Hyprland + SDDM), networking (firewall, NetworkManager), hardware (Bluetooth, I2C), virtualization (Docker, libvirt, KVM, Waydroid), VPN (Mullvad), sing-box TUN proxy, secret management (agenix), power management, OpenRGB, Sunshine streaming, SearXNG, Syncthing, tablet input, fonts, and XDG portals.

See `configuration/system/modules/context.md` for the full inventory.

</details>

<details>
<summary>Tools</summary>

- **`profile-manager-tui.sh`**: Interactive terminal UI for profile operations
- **`profile-manager.sh`**: Profile management CLI (create, set/get host profiles)
- **`debug-nix-config.sh`**: Diagnose Nix daemon config mismatches
- **`push-to-cachix.sh`**: Push derivations to personal Cachix cache
- **`test-profile-manager.sh`**: Profile manager test runner

</details>

<details>
<summary>CI/CD</summary>

| Workflow | Trigger | Action |
|----------|---------|--------|
| `flake-check.yml` | Push to `dev` | `nix flake check` on all hosts |
| `sync-dev-main.yml` | Push to `main` | Sync back to `dev` (bidirectional) |

</details>

<details>
<summary>Development</summary>

See [`conventions/DEVELOPMENT.md`](conventions/DEVELOPMENT.md) for coding standards and repo conventions.

</details>

> ⚠️ Personal dotfiles: breaking changes may occur without notice.
