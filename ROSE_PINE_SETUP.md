# Rose Pine NixOS Configuration Setup Guide

## Overview
Complete NixOS configuration with Rose Pine theme integration across Kitty terminal, Fuzzel launcher, and screenshot utilities. All components are themed consistently with the Rose Pine color palette.

## ✨ Features Implemented

### 🖥️ Kitty Terminal with Rose Pine Theme
- **Full Rose Pine color scheme** with proper contrast ratios
- **JetBrainsMono Nerd Font** size 10 for optimal readability and icon support
- **Optimized performance settings** (repaint delay, input delay)
- **Translucent background** (0.95 opacity) with blur effects
- **Tab management** with Rose Pine themed tab bar
- **Comprehensive keybindings** for terminal workflow
- **Fastfetch greeting** displays system info on terminal startup

### 🚀 Enhanced Fuzzel Launcher
- **Rose Pine theme integration** with proper color mapping
- **Fuzzy search algorithm** (fzf) for intelligent matching
- **Application icons** with Papirus-Dark icon theme
- **Improved UX features**:
  - Search placeholders and prompts
  - Enhanced keyboard navigation
  - Result sorting and filtering
  - Action support for applications

### 📸 Screenshot System
- **Multiple capture modes**:
  - `MOD+P` - Full screen screenshot
  - `MOD+Shift+P` - Full screen without hyprshade
  - `MOD+Ctrl+P` - Region selection
- **Hyprshade integration** for clean captures
- **Automatic clipboard copying**
- **Desktop notifications** with preview
- **Screenshot editing** support (satty/swappy)
- **Organized storage** in `~/Pictures/Screenshots/`

### 📊 Fastfetch System Information
- **Beautiful system info display** with NixOS logo
- **Custom Fish shell greeting** replaces default fish greeting
- **Rose Pine themed colors** for consistent visual experience
- **Comprehensive system stats**:
  - OS, kernel, uptime, packages
  - Desktop environment and window manager
  - Hardware info (CPU, GPU, memory, disk)
  - Network information and display setup
  - Theme and font information

## 🎨 Rose Pine Color Palette

| Color | Hex Code | Usage |
|-------|----------|--------|
| **Base** | `#191724` | Primary background |
| **Surface** | `#1f1d2e` | Secondary background |
| **Overlay** | `#26233a` | Elevated surfaces |
| **Muted** | `#6e6a86` | Dimmed text |
| **Subtle** | `#908caa` | Placeholder text |
| **Text** | `#e0def4` | Primary text |
| **Love** | `#eb6f92` | Red accent |
| **Gold** | `#f6c177` | Yellow accent |
| **Rose** | `#ebbcba` | Pink accent |
| **Pine** | `#31748f` | Blue accent |
| **Foam** | `#9ccfd8` | Cyan accent |
| **Iris** | `#c4a7e7` | Purple accent |

## 🔧 System Configuration

### Hostname Configuration
- **System hostname**: `popcat19-nixos0`
- **Flake target**: `.#popcat19-nixos0`
- **Fish environment variables** properly configured

### Package Management
All utilities and dependencies are managed through Home Manager:
```nix
# Screenshot utilities
grim          # Wayland screenshot capture
slurp         # Region selection
wl-clipboard  # Clipboard management
swappy        # Screenshot annotation
satty         # Advanced screenshot editor
libnotify     # Desktop notifications
zenity        # Dialog boxes

# System information
fastfetch     # System info display tool
```

## 🎯 Usage Instructions

### Taking Screenshots
1. **Full Screen**: Press `Super+P`
   - Captures entire screen with current display settings
   - Automatically copies to clipboard
   - Shows notification with preview

2. **Full Screen (Clean)**: Press `Super+Shift+P`
   - Temporarily disables hyprshade for clean capture
   - Useful for sharing without visual effects
   - Auto-restores hyprshade after capture

3. **Region Selection**: Press `Super+Ctrl+P`
   - Interactive region selection with slurp
   - Optional screenshot editing with satty/swappy
   - Precise control over capture area

### Kitty Terminal Features
- **Font scaling**: `Ctrl+Plus/Minus` to adjust font size (default: 10)
- **Tab management**: `Ctrl+Shift+T` for new tab
- **Window management**: `Ctrl+Shift+Enter` for new window
- **Copy/Paste**: `Ctrl+Shift+C/V` for clipboard operations
- **System info greeting**: Fastfetch displays on new terminal sessions

### Fuzzel Launcher
- **Launch**: Press `Super+A`
- **Search**: Type application name or keywords
- **Navigation**: Arrow keys or vim-style navigation
- **Execute**: Enter to launch, Tab for alternatives

### Fastfetch Display
- **Automatic greeting**: Shows system info when opening new terminal
- **Custom configuration**: Rose Pine themed with comprehensive stats
- **Manual execution**: Run `fastfetch` anytime for system overview
- **Fish integration**: Replaces default fish greeting message

## 📁 File Structure

```
nixos-config/
├── flake.nix                 # Main system configuration
├── configuration.nix         # NixOS system settings
├── home.nix                  # Home Manager configuration
├── hypr_config/
│   ├── keybindings.conf      # Hyprland keybindings
│   └── rose-pine.conf        # Rose Pine color definitions
├── scripts/
│   ├── screenshot-full.sh    # Full screen capture script
│   └── screenshot-region.sh  # Region selection script
├── fastfetch_config/
│   └── config.jsonc          # Fastfetch configuration with Rose Pine theme
└── fish_functions/           # Custom Fish shell functions
```

## 🔄 Build and Deploy

### Standard Rebuild
```bash
# Navigate to config directory
cd ~/nixos-config

# Rebuild system
sudo nixos-rebuild switch --flake .#popcat19-nixos0

# Or use fish abbreviation
nrb
```

### Development Workflow
```bash
# Check configuration
nix flake check

# Test build without switching
sudo nixos-rebuild build --flake .#popcat19-nixos0

# Commit changes
git add .
git commit -m "Description of changes"
git push
```

## 🛠️ Manual Setup Steps

### Screenshot Scripts
Due to Nix path limitations, screenshot scripts need manual installation:
```bash
# Copy scripts to local bin
cp ~/nixos-config/scripts/screenshot-*.sh ~/.local/bin/
chmod +x ~/.local/bin/screenshot-*

# Rename for keybinding compatibility
mv ~/.local/bin/screenshot-full.sh ~/.local/bin/screenshot-full
mv ~/.local/bin/screenshot-region.sh ~/.local/bin/screenshot-region
```

### Fastfetch Configuration
Manual setup for custom fastfetch config:
```bash
# Copy fastfetch config
mkdir -p ~/.config/fastfetch
cp ~/nixos-config/fastfetch_config/config.jsonc ~/.config/fastfetch/

# Test fastfetch display
fastfetch

# Restart terminal to see fish greeting
```

### Theme Verification
After rebuild, verify theme application:
```bash
# Check Kitty config
ls -la ~/.config/kitty/kitty.conf

# Check Fuzzel config
cat ~/.config/fuzzel/fuzzel.ini

# Test screenshot functionality
~/.local/bin/screenshot-full

# Test fastfetch greeting
fish -c 'fish_greeting'
```

## 🔍 Troubleshooting

### Screenshot Issues
- **Scripts not found**: Ensure `~/.local/bin` is in PATH
- **No notifications**: Check if `libnotify` is installed
- **Hyprshade errors**: Verify hyprshade is available and configured

### Theme Issues
- **Kitty theme not applied**: Check symlink in `~/.config/kitty/`
- **Fuzzel colors wrong**: Verify fuzzel.ini generation
- **Font not rendering**: Ensure JetBrainsMono Nerd Font is installed

### Fastfetch Issues
- **No greeting in terminal**: Check fish configuration reload
- **Config not found**: Verify `~/.config/fastfetch/config.jsonc` exists
- **Wrong colors**: Ensure fastfetch config uses Rose Pine theme
- **Package not available**: Verify fastfetch is in home.packages

### Build Issues
- **Flake check fails**: Ensure all file paths are correct
- **Home Manager errors**: Check package availability
- **Path not found**: Verify all source references exist

## 🎨 Customization

### Color Adjustments
Modify Rose Pine colors in:
- `home.nix` - Kitty and Fuzzel color settings
- `hypr_config/rose-pine.conf` - Hyprland color variables

### Keybinding Changes
Update screenshot keybindings in:
- `hypr_config/keybindings.conf`

### Font Modifications
Change fonts in:
- `home.nix` - Kitty and Fuzzel font settings (currently size 10)

### Fastfetch Customization
Modify system info display:
- `fastfetch_config/config.jsonc` - Add/remove modules, change colors
- Fish greeting function in `home.nix` shellInit section

## 📋 Dependencies

### System Requirements
- **NixOS 24.11+** with Home Manager
- **Hyprland** window manager
- **Wayland** display server
- **PipeWire** for audio (notifications)

### Runtime Dependencies
- **grim/slurp** - Screenshot capture
- **wl-clipboard** - Wayland clipboard
- **libnotify** - Desktop notifications
- **hyprshade** - Shader management
- **satty/swappy** - Screenshot editing
- **fastfetch** - System information display

## 🔗 Integration Notes

### Fish Shell Integration
- Environment variables set for config paths
- Custom functions work with new hostname
- Abbreviations support screenshot workflow
- Custom fastfetch greeting function replaces default fish greeting
- Automatic system info display on terminal startup

### Hyprland Integration
- Keybindings configured for all screenshot modes
- Theme colors consistent with system palette
- Window rules compatible with screenshot tools

### Home Manager Integration
- All user configurations managed declaratively
- Automatic symlinking of config files
- Package management through Nix

---

**Configuration Version**: June 2025  
**System**: NixOS 25.11 with Hyprland  
**Theme**: Rose Pine (complete integration)  
**Hostname**: popcat19-nixos0  
**Terminal**: Kitty with fastfetch greeting (font size 10)  
**System Info**: Fastfetch with custom Rose Pine configuration