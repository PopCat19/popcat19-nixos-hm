# Installation Guide

This guide walks you through setting up this NixOS configuration on your system.

## Prerequisites

Before starting, ensure you have:

- **NixOS 23.05 or later** with flakes enabled
- **Git** installed for cloning the repository
- **System supporting Wayland compositors**
- **Root access** for system configuration

### Enabling Flakes (if not already enabled)

If flakes aren't enabled on your system, add the following to your NixOS configuration:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

## Step-by-Step Installation

### 1. Clone the Repository

```bash
git clone https://github.com/PopCat19/popcat19-nixos-hm.git ~/nixos-config
cd ~/nixos-config
```

### 2. Copy Hardware Configuration

**Important**: Replace the hardware configuration with your own system-specific file:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
echo "hardware-configuration.nix" >> .gitignore
```

### 3. Configure Your System

Edit [`user-config.nix`](../user-config.nix) to customize your setup:

```nix
{
  host = {
    hostname = "your-hostname";    # Your desired hostname
    system = "x86_64-linux";       # or "aarch64-linux" for ARM64
  };

  user = {
    username = "your-username";    # Your username
    fullName = "Your Full Name";   # Your display name
    email = "your@email.com";      # Your email for Git
  };

  # Customize default applications
  defaultApps = {
    browser = "firefox";
    terminal = "kitty";
    editor = "micro";
    fileManager = "dolphin";
    musicPlayer = "spotify";
    videoPlayer = "vlc";
  };

  # Network configuration
  network = {
    firewall.allowedTCPPorts = [ 22 80 443 ];
    firewall.allowedUDPPorts = [ ];
    trustedInterfaces = [ ];
  };
}
```

### 4. Apply the Configuration

```bash
sudo nixos-rebuild switch --flake .#<your-hostname>
```

Replace `<your-hostname>` with the hostname you configured in `user-config.nix`.

## Post-Installation

After successful installation:

1. **Reboot** to ensure all services start correctly
2. **Test Wayland session** by logging into Hyprland
3. **Verify applications** launch correctly
4. **Check system services** are running as expected

## Troubleshooting Installation

If you encounter issues:

- **Check logs**: `journalctl -xe` for system errors
- **Verify flake**: `nix flake check` to validate configuration
- **Test build**: `nixos-rebuild test --flake .#<hostname>` to test without switching
- **Review hardware**: Ensure your hardware configuration matches your system

## Next Steps

- [Configuration Reference](configuration.md) - Understand the modular structure
- [Customization Guide](customization.md) - Personalize your setup
- [Features Overview](features.md) - Explore available features