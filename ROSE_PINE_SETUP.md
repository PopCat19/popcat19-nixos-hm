# Rose Pine NixOS Configuration Setup Guide

## Overview
Complete NixOS configuration with Rose Pine theme integration across Kitty terminal, Fuzzel launcher, and screenshot utilities. All components are themed consistently with the Rose Pine color palette.

## ✨ Features Implemented

### 🖥️ Kitty Terminal with Rose Pine Theme
- **Full Rose Pine color scheme** with proper contrast ratios
- **JetBrainsMono Nerd Font** for optimal readability and icon support
- **Optimized performance settings** (repaint delay, input delay)
- **Translucent background** (0.95 opacity) with blur effects
- **Tab management** with Rose Pine themed tab bar
- **Comprehensive keybindings** for terminal workflow

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
All screenshot utilities and dependencies are managed through Home Manager:
```nix
# Screenshot utilities
grim          # Wayland screenshot capture
slurp         # Region selection
wl-clipboard  # Clipboard management
swappy        # Screenshot annotation
satty         # Advanced screenshot editor
libnotify     # Desktop notifications
zenity        # Dialog boxes
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
- **Font scaling**: `Ctrl+Plus/Minus` to adjust font size
- **Tab management**: `Ctrl+Shift+T` for new tab
- **Window management**: `Ctrl+Shift+Enter` for new window
- **Copy/Paste**: `Ctrl+Shift+C/V` for clipboard operations

### Fuzzel Launcher
- **Launch**: Press `Super+A`
- **Search**: Type application name or keywords
- **Navigation**: Arrow keys or vim-style navigation
- **Execute**: Enter to launch, Tab for alternatives

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

### Theme Verification
After rebuild, verify theme application:
```bash
# Check Kitty config
ls -la ~/.config/kitty/kitty.conf

# Check Fuzzel config
cat ~/.config/fuzzel/fuzzel.ini

# Test screenshot functionality
~/.local/bin/screenshot-full
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
- `home.nix` - Kitty and Fuzzel font settings

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

## 🔗 Integration Notes

### Fish Shell Integration
- Environment variables set for config paths
- Custom functions work with new hostname
- Abbreviations support screenshot workflow

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