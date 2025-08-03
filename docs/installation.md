# Installation

This NixOS configuration requires NixOS 23.05+ with flakes enabled and a Wayland-compatible system.

## Quick Setup

```bash
# Clone repository
git clone https://github.com/PopCat19/popcat19-nixos-hm.git ~/nixos-config
cd ~/nixos-config

# Copy your hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
echo "hardware-configuration.nix" >> .gitignore

# Configure your system in user-config.nix
# Then apply the configuration
sudo nixos-rebuild switch --flake .#<your-hostname>
```

## Requirements

- NixOS 23.05 or later
- Flakes enabled in system configuration
- Git for repository management
- Root access for system changes
- Wayland-compatible hardware

## Configuration

Edit [`user-config.nix`](../user-config.nix) to set your hostname, username, and preferences. The configuration is modular and designed for easy customization.

## Post-Installation

Reboot your system and log into the Hyprland session. Verify that applications launch correctly and system services are running as expected.

## Troubleshooting

Use `journalctl -xe` for system errors, `nix flake check` to validate configuration, and `nixos-rebuild test --flake .#<hostname>` to test without switching.