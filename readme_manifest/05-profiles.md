Profiles compose system modules into deployable presets. Each host points to one profile via its `user-config.nix`.

- **`default`** — Full desktop: Hyprland, PipeWire, virtualization, VPN, gaming, Syncthing, OpenRGB
- **`laptop`** — Desktop minus desktop-specifics; adds TLP
- **`surface`** — Surface Pro: touch, thermal throttling, surface-control group
- **`minimal`** — Headless/server: SSH, Docker, no display stack
- **`shimboot`** — ChromeOS shimboot: pruned home modules, minimal services

Manage profiles with `tools/profile-manager-tui.sh`.
