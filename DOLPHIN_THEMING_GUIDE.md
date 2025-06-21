# 🐬 Dolphin Theming Guide for Hyprland + NixOS

Complete guide to fix Dolphin theming issues in Hyprland with Rose Pine and Catppuccin themes.

## 🎯 Problem Solved

**Issue**: Dolphin file manager doesn't respect Rose Pine theming even when Kvantum is configured
**Root Cause**: Dolphin primarily reads `kdeglobals` for theming, not just Kvantum configuration
**Solution**: Comprehensive theming setup with proper `kdeglobals` management

## 🎨 Available Themes

Your system now supports two beautiful themes:

### 1. **🌹 Rose Pine** (Primary)
- Soothing pine-inspired colors
- Perfect for extended coding sessions
- Easy on the eyes

### 2. **🐱 Catppuccin Frappe** (Fallback)
- Cool, pastel color palette with blue accents
- Excellent contrast and readability
- Alternative when Rose Pine isn't available

## 🚀 Quick Theme Switching

Use these simple commands in your terminal:

```bash
# Switch to Rose Pine theme
theme-rose

# Switch to Catppuccin Frappe theme  
theme-cat

# Check current theme status
theme-status

# Manual script usage
~/nixos-config/scripts/switch-kde-theme.sh rosepine
~/nixos-config/scripts/switch-kde-theme.sh catppuccin
~/nixos-config/scripts/switch-kde-theme.sh status
```

## 🔧 What Was Fixed

### 1. **Added Missing kdeglobals Configuration**
The key missing piece! Dolphin reads this file for color schemes:
- Location: `~/.config/kdeglobals`
- Contains KDE-specific color definitions
- Managed through Home Manager

### 2. **Enhanced Package Configuration**
Added essential packages to `home.nix`:
```nix
catppuccin-kvantum                  # Catppuccin Kvantum themes
catppuccin-kde                      # KDE-specific Catppuccin theme
libsForQt5.qtstyleplugin-kvantum   # Qt5 Kvantum support
kdePackages.qtstyleplugin-kvantum  # Qt6 Kvantum support
```

### 3. **Application-Specific Overrides**
Configured Kvantum to apply themes to specific applications:
```ini
[Applications]
dolphin=rose-pine-rose
ark=rose-pine-rose  
gwenview=rose-pine-rose
systemsettings=rose-pine-rose
```

### 4. **Comprehensive Configuration Files**
- **kdeglobals**: KDE global settings (most important for Dolphin)
- **kvantum.kvconfig**: Kvantum theme selection
- **qt6ct.conf**: Qt6 application theming

## 📱 Themed Applications

All these applications now properly support theming:
- 📁 **Dolphin** (file manager) ← Main target!
- 🗜️ **Ark** (archive manager)
- 🖼️ **Gwenview** (image viewer)
- ⚙️ **System Settings**
- 📝 **Kate** (text editor)
- 🔧 **KWrite** (simple editor)
- 🖥️ **Konsole** (terminal)

## 🛠️ Implementation Steps

### 1. **Update Home Manager Configuration**
The enhanced `home.nix` now includes:
- Proper kdeglobals management
- Application-specific Kvantum configuration
- Additional required packages

### 2. **Rebuild Your System**
```bash
home-manager switch
```

### 3. **Apply Theme**
```bash
theme-rose  # For Rose Pine
# or
theme-cat   # For Catppuccin
```

### 4. **Verify Setup**
```bash
theme-status  # Check configuration
```

## 🐛 Troubleshooting

### Theme Not Applying to Dolphin?

1. **Check Environment Variables**:
```bash
echo $QT_QPA_PLATFORMTHEME  # Should be: qt6ct
echo $QT_STYLE_OVERRIDE     # Should be: kvantum
```

2. **Verify Theme Files Exist**:
```bash
ls ~/.config/Kvantum/
# Should show: RosePine, Catppuccin-Frappe directories
```

3. **Force Application Restart**:
```bash
pkill dolphin && dolphin &
```

4. **Check Configuration Files**:
```bash
~/nixos-config/scripts/switch-kde-theme.sh check
```

### Still Having Issues?

1. **Log out and back in** to reload environment variables
2. **Restart Hyprland** for complete session reload
3. **Use the manual tools**:
   - `kvantummanager` for fine-tuning
   - `qt6ct` for Qt-specific settings

## ⚡ Environment Variables

Your system is configured with these critical variables:
```bash
export QT_QPA_PLATFORMTHEME="qt6ct"
export QT_STYLE_OVERRIDE="kvantum" 
export QT_QPA_PLATFORM="wayland;xcb"
```

These are automatically set by your Home Manager configuration.

## 📦 Key Packages

Essential packages for theming:
- `rose-pine-kvantum` - Rose Pine theme files
- `catppuccin-kvantum` - Catppuccin Kvantum theme files
- `catppuccin-kde` - Catppuccin KDE theme files  
- `libsForQt5.qtstyleplugin-kvantum` - Qt5 Kvantum support
- `kdePackages.qtstyleplugin-kvantum` - Qt6 Kvantum support
- `qt6ct` - Qt6 configuration tool

## 🎨 Customization

### Creating Custom Themes
1. Copy existing theme:
```bash
cp -r ~/.config/Kvantum/RosePine ~/.config/Kvantum/MyTheme
```

2. Edit theme files in the new directory
3. Update configuration:
```bash
# Edit ~/.config/Kvantum/kvantum.kvconfig
[General]
theme=MyTheme

[Applications]
dolphin=MyTheme
```

## 🔄 Advanced Usage

### Per-Application Theming
Edit `~/.config/Kvantum/kvantum.kvconfig`:
```ini
[Applications]
dolphin=rose-pine-rose
ark=catppuccin-frappe-blue
gwenview=rose-pine-rose
```

### Theme Testing
```bash
# Test current setup
~/nixos-config/scripts/switch-kde-theme.sh test

# Check environment
~/nixos-config/scripts/switch-kde-theme.sh check
```

## 📋 Quick Reference

| Command | Action |
|---------|--------|
| `theme-rose` | Switch to Rose Pine |
| `theme-cat` | Switch to Catppuccin Frappe |
| `theme-status` | Show current theme |
| `kvantummanager` | Open theme manager GUI |
| `qt6ct` | Open Qt6 settings |

## ✅ Success Indicators

When everything is working correctly:
- ✅ Dolphin shows Rose Pine/Catppuccin Frappe colors
- ✅ File browser background matches theme
- ✅ Buttons and menus are properly themed
- ✅ Selection colors are theme-appropriate
- ✅ Other KDE apps match the theme

## 🚨 Emergency Reset

If theming breaks completely:
```bash
# Restore backups (automatic backups are created)
cd ~/.config
ls *.bak.*  # List available backups

# Or reset to defaults
rm kdeglobals Kvantum/kvantum.kvconfig qt6ct/qt6ct.conf
home-manager switch  # Recreate from Home Manager
```

---

**🎉 Enjoy your beautifully themed Dolphin file manager!**

*This setup provides consistent theming across all KDE/Qt applications in your Hyprland environment, with Rose Pine as primary and Catppuccin Frappe as fallback where needed.*