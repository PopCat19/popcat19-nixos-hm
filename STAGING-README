NixOS Configuration Flake
=========================

A NixOS configuration flake featuring Hyprland, Rose Pine theming, gaming support,
and Home Manager integration.

Table of Contents
-----------------
1. Overview
2. Prerequisites
3. Installation
4. Configuration
5. Features
6. Troubleshooting
7. Contributing

Overview
--------

This configuration provides a complete NixOS setup with:
- Hyprland compositor with HyprPanel
- Rose Pine theming for GTK/Qt applications
- Gaming support via AAGL (Anime Game Launcher)
- Comprehensive Home Manager configuration
- Custom packages and overlays

Prerequisites
-------------

- NixOS 23.05 or later
- Flakes enabled in nix configuration
- Git installed

Installation
------------

1. Clone the repository:
   $ git clone <repository-url> /etc/nixos
   $ cd /etc/nixos

2. Update system and user information in flake.nix:
   - Change 'hostname' variable to your system hostname
   - Change 'username' variable to your username
   - Update 'system' if not using x86_64-linux

3. Generate hardware configuration:
   $ sudo nixos-generate-config --root /mnt
   $ sudo cp /mnt/etc/nixos/hardware-configuration.nix .

4. Update home.nix:
   - Change home.username to your username
   - Change home.homeDirectory to your home path
   - Update any user-specific paths

5. Initial system build:
   $ sudo nixos-rebuild switch --flake .#<hostname>

Configuration
-------------

Directory Structure:
- flake.nix           - Main flake configuration
- configuration.nix   - System-level NixOS configuration
- home.nix           - Home Manager user configuration
- hardware-configuration.nix - Hardware-specific settings
- fastfetch_config/  - System information display
- fish_functions/    - Fish shell functions
- fish_themes/       - Fish shell themes
- gtk_config/        - GTK theming configuration
- hypr_config/       - Hyprland configuration
- micro_config/      - Micro editor configuration
- scripts/           - Utility scripts

Key Configuration Files:

flake.nix:
- Defines all external dependencies
- Configures system hostname and username
- Manages overlays and custom packages
- Integrates Home Manager as NixOS module

home.nix:
- User-specific package management
- Application configurations
- Theming settings
- Shell configuration

configuration.nix:
- System-level services and packages
- Hardware configuration
- Boot configuration
- Network settings

Features
--------

Desktop Environment:
- Hyprland Wayland compositor
- HyprPanel for system panel
- Rose Pine theming throughout
- Fuzzel application launcher
- Kitty terminal emulator

Applications:
- Zen Browser (Firefox-based)
- Fish shell with custom functions
- Micro text editor
- FastFetch system information
- Gaming launchers (AAGL)

Theming:
- Rose Pine Dark GTK theme
- Papirus Dark icon theme
- Rose Pine hyprcursor
- Consistent theming across GTK/Qt
- CaskaydiaCove Nerd Font

Gaming:
- Anime Game Launcher (AAGL)
- Honkers Railway Launcher
- MangoHud overlay
- Gaming-optimized packages

Development:
- Git with user configuration
- Micro editor with plugins
- Fish shell with abbreviations
- Development tools and utilities

Customization:
- Modular configuration structure
- Custom overlays for packages
- Configurable theming
- User-specific settings

Troubleshooting
---------------

Common Issues:

1. Theme not applying:
   - Ensure Rosepine-Dark theme exists in ~/.local/share/themes/
   - Run: nwg-look -a to verify theme application
   - Check dconf settings: dconf read /org/gnome/desktop/interface/gtk-theme

2. Flake build errors:
   - Verify hostname matches flake.nix configuration
   - Update flake.lock: nix flake update
   - Check for dirty git tree warnings

3. Home Manager issues:
   - Ensure username matches in both flake.nix and home.nix
   - Verify home directory path is correct
   - Check for conflicting configurations

4. Missing packages:
   - Update flake inputs: nix flake update
   - Rebuild system: sudo nixos-rebuild switch --flake .#<hostname>
   - Clear nix store if needed: nix-collect-garbage -d

5. Hyprland issues:
   - Check Hyprland logs: journalctl --user -u hyprland
   - Verify graphics drivers are installed
   - Check hypr_config/ for configuration errors

Commands:

Build system:
$ sudo nixos-rebuild switch --flake .#<hostname>

Update flake:
$ nix flake update

Test configuration:
$ sudo nixos-rebuild test --flake .#<hostname>

Garbage collection:
$ nix-collect-garbage -d

Check theme:
$ nwg-look -a

System information:
$ fastfetch

Contributing
------------

1. Fork the repository
2. Create feature branch
3. Make changes following existing patterns
4. Test thoroughly on clean system
5. Submit pull request with clear description

Guidelines:
- Maintain modular structure
- Document significant changes
- Test on multiple systems
- Follow Nix best practices
- Keep configurations declarative

License
-------

This configuration is provided as-is for educational and personal use.
Individual components may have their own licenses.

Acknowledgments
---------------

- NixOS community for excellent documentation
- Rose Pine theme creators
- Hyprland developers
- Home Manager maintainers
- AAGL project contributors

For support, consult:
- NixOS Manual: https://nixos.org/manual/
- Home Manager Manual: https://nix-community.github.io/home-manager/
- Hyprland Wiki: https://wiki.hyprland.org/
- ArchWiki: https://wiki.archlinux.org/ (for general Linux concepts)

RTFM: Read The Fantastic Manual
