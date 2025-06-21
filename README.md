NixOS Configuration Flake
=========================

A clean, consolidated NixOS configuration flake featuring Hyprland, Rose Pine theming, 
gaming support, and comprehensive Home Manager integration.

Table of Contents
-----------------
1. Overview
2. Prerequisites
3. Installation
4. Configuration
5. Features
6. Recent Updates
7. Troubleshooting
8. Contributing

Overview
--------

This configuration provides a complete, optimized NixOS setup with:
- Hyprland compositor with HyprPanel (consolidated configuration)
- Rose Pine theming for GTK/Qt applications
- Gaming support via AAGL (Anime Game Launcher)
- Enhanced screenshot functionality with shader awareness
- Comprehensive Home Manager configuration
- Custom packages and overlays
- Declarative script management through nix expressions

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
- home.nix           - Home Manager user configuration (includes script expressions)
- hardware-configuration.nix - Hardware-specific settings
- docs/              - Comprehensive documentation
- fish_functions/    - Fish shell functions
- fish_themes/       - Fish shell themes
- gtk_config/        - GTK theming configuration
- hypr_config/       - Consolidated Hyprland configuration
- micro_config/      - Micro editor configuration

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
- Script expressions (screenshot, theme checker)

configuration.nix:
- System-level services and packages
- Hardware configuration
- Boot configuration
- Network settings
- Essential screenshot tools (grim, slurp, wl-clipboard)

Features
--------

Desktop Environment:
- Hyprland Wayland compositor (consolidated configuration)
- HyprPanel for system panel
- Rose Pine theming throughout
- Fuzzel application launcher
- Kitty terminal emulator

Screenshots:
- Enhanced screenshot system with hyprshade integration
- Current monitor detection and capture
- Region selection with monitor constraints
- Automatic shader toggling for clean captures
- Instant clipboard integration

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
- Fixed font rendering (no forced system defaults)

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

Configuration Management:
- Consolidated Hyprland configuration (single file for core settings)
- Declarative script management through nix expressions
- Modular design for system-specific settings
- Comprehensive documentation in docs/ directory
- 43% file reduction while preserving functionality

Recent Updates
--------------

### Major Improvements (v2024)
- **Fixed Hyprland configuration errors** - Zero config errors, clean parsing
- **Enhanced screenshot functionality** - Current monitor capture with hyprshade integration
- **Consolidated configuration** - Single hyprland.conf for core settings
- **Script migration** - All scripts converted to nix expressions in home.nix
- **File reduction** - 43% fewer files (79 → 45) while preserving functionality
- **Font fixes** - Removed problematic system font defaults affecting browsers

### Available Scripts
- `screenshot-full` - Full monitor screenshot with shader awareness
- `screenshot-region` - Interactive region selection on current monitor  
- `check-rose-pine-theme` - Comprehensive theme status checker

### Documentation
- See `docs/CONSOLIDATION-SUMMARY.md` for detailed changes
- See `docs/QUICKREF.md` for common commands
- See `docs/ANIMATIONS.md` and `docs/SHADERS.md` for configuration guides

Troubleshooting
---------------

Common Issues:

1. **Hyprland configuration errors**:
   - Run: `hyprctl configerrors` to check for issues
   - All configuration is now in `hypr_config/hyprland.conf`
   - Check for syntax errors in keybindings

2. **Screenshot not working**:
   - Ensure grim, slurp, and wl-clipboard are installed (included in system packages)
   - Check script permissions: `ls -la ~/.local/bin/screenshot-*`
   - Test manually: `~/.local/bin/screenshot-full`

3. **Theme not applying**:
   - Run: `check-rose-pine-theme` for comprehensive status check
   - Ensure Home Manager rebuild: `home-manager switch`
   - Check dconf settings: `dconf read /org/gnome/desktop/interface/gtk-theme`

4. **Browser fonts not working**:
   - System font defaults have been removed to fix browser rendering
   - Restart browser after Home Manager rebuild
   - Check GTK theme application with `nwg-look -a`

5. **Flake build errors**:
   - Verify hostname matches flake.nix configuration
   - Update flake.lock: `nix flake update`
   - Check for dirty git tree warnings

6. **Home Manager issues**:
   - Ensure username matches in both flake.nix and home.nix
   - Verify home directory path is correct
   - Check for conflicting configurations

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
$ check-rose-pine-theme

Screenshots:
$ screenshot-full
$ screenshot-region

System information:
$ fastfetch

Check Hyprland config:
$ hyprctl configerrors

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

Quick Reference
---------------

### Essential Commands
```bash
# System management
sudo nixos-rebuild switch --flake .#<hostname>  # Apply changes
nix flake update                                # Update packages
nix-collect-garbage -d                         # Clean up

# Screenshots (enhanced with shader support)
screenshot-full                                 # Current monitor
screenshot-region                              # Interactive selection

# Theme management
check-rose-pine-theme                          # Comprehensive status
nwg-look -a                                    # Apply GTK theme

# Configuration validation
hyprctl configerrors                           # Check Hyprland config
```

### File Structure
- **Core config**: `hypr_config/hyprland.conf` (consolidated)
- **Scripts**: Defined in `home.nix` as nix expressions
- **Documentation**: Comprehensive guides in `docs/` directory
- **Modular configs**: `monitors.conf`, `userprefs.conf` for system-specific settings

For support, consult:
- **Local documentation**: `docs/` directory for detailed guides
- NixOS Manual: https://nixos.org/manual/
- Home Manager Manual: https://nix-community.github.io/home-manager/
- Hyprland Wiki: https://wiki.hyprland.org/
- ArchWiki: https://wiki.archlinux.org/ (for general Linux concepts)

---
**Configuration Status**: ✅ Consolidated • ✅ Zero Config Errors • ✅ Enhanced Functionality
