# HyDE-nix Integration Guide: "Stolen" Configurations

This guide shows you how to integrate the Rose Pine fastfetch and GTK configurations "stolen" from hydenix into your nixos-config.

## 🎯 What We've "Stolen"

### 1. Enhanced Fastfetch Configuration
- **Source**: `fastfetch_config/config.jsonc` (updated)
- **Features**: 
  - Rose Pine color scheme using RGB color codes
  - NixOS logo with Rose Pine theming
  - Enhanced module layout with better visual separation
  - Temperature monitoring for CPU/GPU
  - Custom Rose Pine ASCII art logo

### 2. Comprehensive GTK Theme Module
- **Source**: `gtk_config/rose-pine-theme.nix` (new)
- **Features**:
  - Complete GTK2/3/4 theming with Rose Pine colors
  - Custom CSS for both GTK3 and GTK4
  - Enhanced KDE/Qt integration via Kvantum
  - Comprehensive kdeglobals configuration
  - nwg-look integration for theme management
  - dconf/GSettings configuration

### 3. Rose Pine Color Definitions
- **Source**: `gtk_config/rose-pine-colors.nix` (new)
- **Features**:
  - Official Rose Pine color palette
  - Multiple format support (hex, RGB, ANSI)
  - Semantic color mapping
  - GTK and Qt specific color definitions

## 🚀 Integration Steps

### Step 1: Enable Enhanced Fastfetch

Update your `home.nix` to uncomment and use the new fastfetch configuration:

```nix
# Replace the commented fastfetch section in home.nix with:
home.file.".config/fastfetch" = {
  source = ./fastfetch_config;
  recursive = true;
};

# Add fastfetch to packages if not already present:
home.packages = with pkgs; [
  fastfetch
  # ... other packages
];
```

### Step 2: Integrate Comprehensive GTK Theming

**Option A: Import the module directly**
Add to your `home.nix` imports:

```nix
{ pkgs, config, system, lib, inputs, ... }:

{
  imports = [
    ./gtk_config/rose-pine-theme.nix
  ];
  
  # Remove your existing gtk configuration block to avoid conflicts
  # The imported module will handle all GTK theming
}
```

**Option B: Manual integration**
If you prefer to keep your current structure, copy the relevant sections from `gtk_config/rose-pine-theme.nix` into your existing `home.nix`.

### Step 3: Update Home Manager Rebuild

```bash
# Navigate to your nixos-config directory
cd ~/nixos-config

# Rebuild with new configurations
home-manager switch --flake .

# Or if using nixos-rebuild
sudo nixos-rebuild switch --flake .
```

### Step 4: Test the Integration

```bash
# Test fastfetch with new Rose Pine theme
fastfetch

# Test fastfetch with custom logo
fastfetch --logo ~/nixos-config/fastfetch_config/logos/rose-pine-nixos.txt

# Launch nwg-look to verify GTK theming
nwg-look

# Test Qt theming with kvantum manager
kvantummanager
```

## 🎨 Customization Options

### Fastfetch Customization

Edit `fastfetch_config/config.jsonc`:

```jsonc
// Change logo
"logo": {
  "source": "~/nixos-config/fastfetch_config/logos/rose-pine-nixos.txt",
  // or use: "source": "nixos" for default NixOS logo
}

// Add/remove modules
"modules": [
  // Add new modules like:
  {
    "type": "battery",
    "key": "🔋 Battery",
    "keyColor": "yellow"
  }
]
```

### GTK Theme Customization

Edit `gtk_config/rose-pine-theme.nix`:

```nix
# Modify colors in the extraCss sections
gtk3.extraCss = ''
  @define-color rose_pine_love #your_custom_color;
'';
```

### Color Scheme Reference

Use `gtk_config/rose-pine-colors.nix` for consistent colors across configs:

```nix
# Import colors in other modules
let
  rosePineColors = import ./gtk_config/rose-pine-colors.nix;
in {
  # Use colors like: rosePineColors.colors.love
}
```

## 🔧 Troubleshooting

### Fastfetch Issues

```bash
# If fastfetch doesn't show custom logo:
fastfetch --logo-type file --logo ~/nixos-config/fastfetch_config/logos/rose-pine-nixos.txt

# If colors don't appear correctly:
# Check terminal color support:
fastfetch --color-keys blue --color-title red

# Reset fastfetch config:
rm -rf ~/.config/fastfetch
home-manager switch --flake .
```

### GTK Theme Issues

```bash
# If GTK apps don't theme correctly:
# Check GTK theme is available:
ls ~/.nix-profile/share/themes/

# Reset GTK settings:
gsettings reset-recursively org.gnome.desktop.interface

# Force theme reload:
nwg-look
```

### Qt/KDE Theme Issues

```bash
# If Qt apps don't theme correctly:
# Check Kvantum themes:
ls ~/.config/Kvantum/

# Reset Qt settings:
rm ~/.config/qt6ct/qt6ct.conf
qt6ct

# Check Kvantum manager:
kvantummanager
```

## 📁 File Structure

```
nixos-config/
├── fastfetch_config/
│   ├── config.jsonc          # Enhanced Rose Pine fastfetch config
│   └── logos/
│       └── rose-pine-nixos.txt  # Custom Rose Pine ASCII logo
├── gtk_config/
│   ├── rose-pine-theme.nix   # Comprehensive GTK theme module
│   └── rose-pine-colors.nix  # Rose Pine color definitions
└── home.nix                  # Updated to import new modules
```

## 🎯 Key Improvements Over Original

### Fastfetch Enhancements
- **Rose Pine color scheme**: All elements use official Rose Pine colors
- **Better visual hierarchy**: Improved separators and grouping
- **Enhanced NixOS branding**: Custom Rose Pine NixOS logo
- **More information**: Added swap, temperatures, better formatting

### GTK Theme Enhancements
- **Complete coverage**: GTK2, GTK3, GTK4 all properly themed
- **Custom CSS**: Hand-crafted Rose Pine styling
- **Better KDE integration**: Enhanced kdeglobals and Kvantum config
- **Tool integration**: nwg-look, xsettingsd, dconf all configured
- **Mutable configs**: Allows runtime theme adjustments

### Organization Improvements
- **Modular structure**: Separate files for different concerns
- **Color consistency**: Centralized color definitions
- **Easy maintenance**: Clear separation of concerns
- **Documentation**: Comprehensive guides and comments

## 🔗 Related Files

- `ROSE_PINE_GTK_GUIDE.md` - Detailed GTK theming guide
- `ROSE_PINE_SETUP.md` - General Rose Pine setup
- `home.nix` - Main Home Manager configuration

## 📝 Notes

- This integration maintains compatibility with your existing setup
- All configurations are mutable where appropriate for runtime changes
- The theming is comprehensive but can be selectively applied
- Colors follow the official Rose Pine specification
- Configurations are inspired by hydenix but adapted for your specific setup

**Status**: Ready for integration
**Compatibility**: NixOS 24.05+ with Home Manager
**Theme**: Rose Pine (complete)
**Source**: Configurations "stolen" and enhanced from hydenix