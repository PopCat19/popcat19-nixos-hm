# 🏴‍☠️ Stolen from HyDE-nix: Rose Pine Configurations

This document summarizes the configurations "stolen" from hydenix and adapted for your nixos-config setup.

## 🎯 What We've Successfully Stolen

### 1. Enhanced Rose Pine Fastfetch Configuration
**File**: `fastfetch_config/config.jsonc`
**Source**: HyDE-Project themes + hydenix module structure
**Enhancements**:
- ✅ **Rose Pine Color Scheme**: All UI elements use official Rose Pine RGB colors
- ✅ **Custom NixOS Logo**: Rose Pine themed ASCII art in `logos/rose-pine-nixos.txt`
- ✅ **Better Visual Hierarchy**: Enhanced separators and module grouping
- ✅ **Extended Information**: CPU/GPU temperatures, swap usage, better formatting
- ✅ **Professional Layout**: Inspired by hydenix's fastfetch module structure

**Key Features Stolen**:
```jsonc
// Rose Pine color codes used throughout
"color": {
  "keys": "\u001b[38;2;156;207;216m",     // Foam (cyan)
  "title": "\u001b[38;2;235;111;146m",    // Love (red)
},
"separator": "\u001b[38;2;110;106;134m ⁃ \u001b[0m",  // Muted separator
```

### 2. Comprehensive GTK Theme Module
**File**: `gtk_config/rose-pine-theme.nix`
**Source**: hydenix's gtk.nix module architecture + comprehensive theming
**Stolen Features**:
- ✅ **Complete GTK Coverage**: GTK2, GTK3, GTK4 all themed like hydenix
- ✅ **Custom CSS Integration**: Hand-crafted Rose Pine styling
- ✅ **KDE/Qt Integration**: Enhanced kdeglobals and Kvantum configuration
- ✅ **Mutable Configurations**: Force + mutable flags like hydenix uses
- ✅ **Tool Integration**: nwg-look, xsettingsd, dconf all configured
- ✅ **Package Management**: All necessary theming packages included

**Hydenix-Style Configuration Pattern**:
```nix
# Stolen from hydenix's approach to mutable theme files
home.file.".config/kdeglobals" = {
  text = ''
    # Rose Pine KDE theme configuration
  '';
  force = true;
  mutable = true;  # Allows runtime theme changes
};
```

### 3. Rose Pine Color System
**File**: `gtk_config/rose-pine-colors.nix`
**Source**: Official Rose Pine palette + hydenix color management approach
**Stolen Architecture**:
- ✅ **Centralized Colors**: Single source of truth for all Rose Pine colors
- ✅ **Multiple Formats**: Hex, RGB, ANSI escape codes
- ✅ **Semantic Mapping**: UI element specific color assignments
- ✅ **GTK/Qt Specific**: Separate color definitions for different toolkits

### 4. Integration Scripts & Documentation
**Files**: 
- `scripts/integrate-hydenix-theme.sh`
- `HYDENIX_INTEGRATION_GUIDE.md`
- `STOLEN_FROM_HYDENIX.md` (this file)

**Stolen Concepts**:
- ✅ **Modular Architecture**: Separate files for different concerns
- ✅ **Comprehensive Documentation**: Detailed guides and troubleshooting
- ✅ **Integration Scripts**: Automated setup and testing
- ✅ **Color-coded Output**: Rose Pine themed terminal output

## 🔧 How the Theft Was Accomplished

### 1. Reverse Engineering hydenix Module Structure
```bash
# Analyzed hydenix's module system
hydenix/hydenix/modules/hm/fastfetch.nix
hydenix/hydenix/modules/hm/gtk.nix
hydenix/hydenix/modules/hm/shell.nix
```

### 2. Extracting Theme Sources
- **Challenge**: hydenix uses `pkgs.hydenix.hyde` which pulls from HyDE-Project themes
- **Solution**: Recreated the essential theming without the complex package dependencies
- **Result**: Self-contained Rose Pine configuration that doesn't require hydenix

### 3. Adapting Configuration Patterns
**Original hydenix pattern**:
```nix
home.file = {
  ".config/fastfetch/config.jsonc" = {
    source = "${pkgs.hydenix.hyde}/Configs/.config/fastfetch/config.jsonc";
  };
};
```

**Our stolen adaptation**:
```nix
home.file.".config/fastfetch" = {
  source = ./fastfetch_config;
  recursive = true;
};
```

## 🎨 Rose Pine Theme Integration

### Color Palette Successfully Stolen
```nix
colors = {
  base = "#191724";      # Background
  surface = "#1f1d2e";   # Secondary background  
  overlay = "#26233a";   # Tertiary background
  muted = "#6e6a86";     # Muted text
  subtle = "#908caa";    # Subtle text
  text = "#e0def4";      # Primary text
  love = "#eb6f92";      # Red accent
  gold = "#f6c177";      # Yellow accent
  rose = "#ebbcba";      # Pink accent
  pine = "#31748f";      # Teal accent
  foam = "#9ccfd8";      # Cyan accent
  iris = "#c4a7e7";      # Purple accent
};
```

### Theme Application Strategy
1. **Fastfetch**: RGB color codes in JSON configuration
2. **GTK**: CSS variables and extraConfig sections
3. **Qt/KDE**: kdeglobals and Kvantum configuration
4. **Terminal**: ANSI escape codes for scripts and output

## 🚀 Usage Instructions

### Quick Integration
```bash
# Navigate to nixos-config
cd ~/nixos-config

# Run the integration script
./scripts/integrate-hydenix-theme.sh

# Manual integration alternative
# 1. Add to home.nix imports:
#    ./gtk_config/rose-pine-theme.nix
# 2. Enable fastfetch config:
#    home.file.".config/fastfetch" = {
#      source = ./fastfetch_config;
#      recursive = true;
#    };
# 3. Rebuild: home-manager switch --flake .
```

### Testing the Stolen Goods
```bash
# Test fastfetch with Rose Pine theme
fastfetch

# Test custom Rose Pine NixOS logo
fastfetch --logo ~/nixos-config/fastfetch_config/logos/rose-pine-nixos.txt

# Verify GTK theming
nwg-look

# Verify Qt theming  
kvantummanager
```

## 📁 File Structure Created

```
nixos-config/
├── fastfetch_config/
│   ├── config.jsonc                    # 🏴‍☠️ Enhanced Rose Pine fastfetch
│   └── logos/
│       └── rose-pine-nixos.txt         # 🏴‍☠️ Custom Rose Pine ASCII logo
├── gtk_config/
│   ├── rose-pine-theme.nix             # 🏴‍☠️ Comprehensive GTK theming
│   └── rose-pine-colors.nix            # 🏴‍☠️ Color definitions
├── scripts/
│   └── integrate-hydenix-theme.sh      # 🏴‍☠️ Integration automation
├── HYDENIX_INTEGRATION_GUIDE.md        # 🏴‍☠️ Detailed integration guide
└── STOLEN_FROM_HYDENIX.md              # 🏴‍☠️ This documentation
```

## 🎯 Key Improvements Over Original

### Fastfetch Enhancements
- **Better Color Usage**: More strategic use of Rose Pine colors
- **Enhanced Layout**: Improved visual hierarchy and separators
- **Custom Branding**: Rose Pine themed NixOS logo
- **Extended Info**: More system information displayed

### GTK Theme Enhancements  
- **Complete Coverage**: All GTK versions properly themed
- **Custom CSS**: Hand-crafted Rose Pine styling
- **Better KDE Integration**: More comprehensive kdeglobals
- **Tool Integration**: Better integration with theme management tools

### Architecture Improvements
- **Self-Contained**: No dependency on hydenix packages
- **Modular Design**: Clean separation of concerns
- **Documentation**: Comprehensive guides and comments
- **Automation**: Scripts for easy integration and testing

## 🔍 What We Didn't Steal (Yet)

- **Wallpaper Management**: hydenix's wallbash system
- **Theme Switching**: hydenix's multi-theme switching capability  
- **Icon Theming**: Custom icon generation and management
- **SDDM/GRUB Themes**: Login and boot loader theming
- **Complete Shell Integration**: hydenix's shell prompt integration

## 🏴‍☠️ Legal Disclaimer

All configurations are inspired by and adapted from the open-source hydenix project and HyDE-Project themes. Original configurations are available under their respective open-source licenses. This "theft" is actually just appreciation and adaptation of excellent open-source work! 

**Original Sources**:
- hydenix: https://github.com/richen604/hydenix
- HyDE-Project: https://github.com/HyDE-Project/
- Rose Pine: https://rosepinetheme.com/

## 🌹 Status

**Integration Status**: ✅ Ready for deployment
**Compatibility**: NixOS 24.05+ with Home Manager
**Theme Coverage**: Complete Rose Pine integration
**Documentation**: Comprehensive guides provided
**Automation**: Integration script available

**Enjoy your stolen Rose Pine paradise! 🏴‍☠️🌹**