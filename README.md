# NixOS Configuration

A modern, gaming-focused NixOS configuration with Hyprland Wayland compositor and Rose Pine theming.

## 🚀 Quick Start

1. **Install NixOS** - Follow our [installation guide](docs/installation.md)
2. **Configure** - Edit [`user-config.nix`](user-config.nix) with your settings
3. **Rebuild** - Run `nixos-rebuild switch --flake .#$(hostname)`

## ✨ Features

- **Modern Wayland desktop** with Hyprland compositor
- **Gaming-optimized** with Steam, Proton, and gaming tools
- **Development-ready** with VS Code, language servers, and containers
- **Beautiful theming** with Rose Pine color scheme
- **Modular design** for easy customization

## 📚 Documentation

- **[Installation Guide](docs/installation.md)** - Fresh NixOS installation
- **[Configuration Guide](docs/configuration.md)** - System configuration
- **[Features Overview](docs/features.md)** - What's included
- **[Customization Guide](docs/customization.md)** - Personalize your setup
- **[Troubleshooting](docs/troubleshooting.md)** - Solve common issues

## 🛠️ Quick Commands

```bash
# Rebuild system
nixos-rebuild switch --flake .#$(hostname)

# Update packages
nix flake update

# Check system
nix flake check

# Rollback
sudo nixos-rebuild switch --rollback
```

## 🎯 Quick Configuration

Edit [`user-config.nix`](user-config.nix):

```nix
{
  user = {
    username = "your-username";
    fullName = "Your Name";
    email = "your@email.com";
  };
  
  host = {
    hostname = "your-computer";
    system = "x86_64-linux";
  };
}
```

## 🎮 Gaming Features

- **Steam** with Proton support
- **Lutris** for non-Steam games
- **MangoHUD** performance overlay
- **GameMode** optimization
- **Discord** for gaming communication

## 💻 Development Tools

- **VS Code** with extensions
- **Docker** container support
- **Language servers** for multiple languages
- **Git** with GUI tools
- **Terminal** with fish shell

## 🎨 Theming

- **Rose Pine** color scheme
- **GTK themes** and icons
- **Hyprland** animations
- **Consistent** appearance across apps

## 🔧 System Architecture

```
nixos-config/
├── system_modules/     # System-level config
├── home_modules/       # User-level config
├── hypr_config/        # Hyprland settings
├── docs/              # Documentation
├── user-config.nix    # Your settings
└── flake.nix          # Nix flake
```

## 🆘 Getting Help

- **Documentation**: Browse [docs/](docs/)
- **Issues**: Report on GitHub
- **Community**: NixOS and Hyprland communities

---

**Ready to get started?** Check out the [installation guide](docs/installation.md) or dive into [customization](docs/customization.md)!
