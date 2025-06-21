# 🐬 Dolphin Rose Pine Theming Guide for Hyprland + NixOS

Complete guide to enable Rose Pine theming for Dolphin file manager in Hyprland.

## 🎯 Problem Solved

**Issue**: Dolphin file manager doesn't respect Rose Pine theming even when Kvantum is configured
**Root Cause**: Dolphin primarily reads `kdeglobals` for theming, not just Kvantum configuration
**Solution**: Comprehensive Rose Pine theming setup with proper `kdeglobals` management

## 🌹 Rose Pine Theme

Your system is now configured with the beautiful Rose Pine theme:
- Soothing pine-inspired colors
- Perfect for extended coding sessions
- Easy on the eyes
- Consistent across all KDE/Qt applications

## 🔧 What Was Fixed

### 1. **Added Missing kdeglobals Configuration**
The key missing piece! Dolphin reads this file for color schemes:
- Location: `~/.config/kdeglobals`
- Contains KDE-specific Rose Pine color definitions
- Managed through Home Manager with `force = true`

### 2. **Enhanced Package Configuration**
Added essential packages to `home.nix`:
```nix
rose-pine-kvantum                   # Rose Pine Kvantum themes
libsForQt5.qtstyleplugin-kvantum   # Qt5 Kvantum support
kdePackages.qtstyleplugin-kvantum  # Qt6 Kvantum support
```

### 3. **Application-Specific Overrides**
Configured Kvantum to apply Rose Pine to specific applications:
```ini
[Applications]
dolphin=rose-pine-rose
ark=rose-pine-rose  
gwenview=rose-pine-rose
systemsettings=rose-pine-rose
kate=rose-pine-rose
kwrite=rose-pine-rose
```

### 4. **Comprehensive Configuration Files**
- **kdeglobals**: KDE global settings (most important for Dolphin)
- **kvantum.kvconfig**: Kvantum theme selection (`rose-pine-rose`)
- **qt6ct.conf**: Qt6 application theming with Kvantum style

## 📱 Themed Applications

All these applications now properly display Rose Pine theming:
- 📁 **Dolphin** (file manager) ← Main target!
- 🗜️ **Ark** (archive manager)
- 🖼️ **Gwenview** (image viewer)
- ⚙️ **System Settings**
- 📝 **Kate** (text editor)
- 🔧 **KWrite** (simple editor)
- 🖥️ **All other Qt/KDE applications**

## 🚀 Quick Status Check

Use this command to verify your theming setup:

```bash
~/nixos-config/scripts/check-rose-pine-theme.sh
```

This will check:
- ✅ Environment variables
- ✅ Theme files existence
- ✅ Configuration files
- ✅ Available applications

## 🛠️ Implementation Details

### **Environment Variables**
Your system is configured with these critical variables:
```bash
export QT_QPA_PLATFORMTHEME="qt6ct"
export QT_STYLE_OVERRIDE="kvantum" 
export QT_QPA_PLATFORM="wayland;xcb"
```

### **Key Configuration Files**

1. **kdeglobals** (`~/.config/kdeglobals`):
   - Contains Rose Pine color scheme
   - Used by Dolphin and all KDE applications
   - Managed by Home Manager

2. **Kvantum Config** (`~/.config/Kvantum/kvantum.kvconfig`):
   ```ini
   [General]
   theme=rose-pine-rose

   [Applications]
   dolphin=rose-pine-rose
   ```

3. **Qt6ct Config** (`~/.config/qt6ct/qt6ct.conf`):
   - Points to Rose Pine Kvantum theme
   - Sets Kvantum as the Qt style
   - Configures Papirus-Dark icons

## 🐛 Troubleshooting

### Theme Not Applying to Dolphin?

1. **Check Status**:
   ```bash
   ~/nixos-config/scripts/check-rose-pine-theme.sh
   ```

2. **Verify Environment Variables**:
   ```bash
   echo $QT_QPA_PLATFORMTHEME  # Should be: qt6ct
   echo $QT_STYLE_OVERRIDE     # Should be: kvantum
   ```

3. **Force Application Restart**:
   ```bash
   pkill dolphin && dolphin &
   ```

4. **Check Theme Files**:
   ```bash
   ls ~/.config/Kvantum/RosePine/
   # Should show: rose-pine-rose.kvconfig, rose-pine-rose.svg
   ```

### Still Having Issues?

1. **Logout and back in** to reload environment variables
2. **Restart Hyprland** for complete session reload
3. **Rebuild Home Manager**:
   ```bash
   fish -c "nixos-apply-config"
   ```
4. **Use manual tools**:
   - `kvantummanager` for Kvantum theme management
   - `qt6ct` for Qt-specific settings

## 📦 Key Packages

Essential packages for Rose Pine theming:
- `rose-pine-kvantum` - Rose Pine theme files from upstream
- `libsForQt5.qtstyleplugin-kvantum` - Qt5 Kvantum support
- `kdePackages.qtstyleplugin-kvantum` - Qt6 Kvantum support
- `qt6ct` - Qt6 configuration tool

## 🎨 Manual Customization

### **Using Kvantum Manager**
```bash
kvantummanager
```
- Select Rose Pine variants
- Adjust transparency and blur
- Fine-tune colors
- Configure per-application settings

### **Using Qt6ct**
```bash
qt6ct
```
- Verify Kvantum style is selected
- Check icon theme (should be Papirus-Dark)
- Adjust fonts if needed

## ✅ Success Indicators

When everything is working correctly:
- ✅ Dolphin shows Rose Pine dark background
- ✅ File browser uses Rose Pine color scheme
- ✅ Buttons and menus are properly themed
- ✅ Selection colors are Rose Pine blue/teal
- ✅ Other KDE apps match the theme
- ✅ Status checker shows all green checkmarks

## 🔧 Technical Notes

### **Why This Solution Works**

1. **kdeglobals Priority**: KDE applications like Dolphin read kdeglobals first for color schemes
2. **Kvantum Integration**: Provides the actual styling engine and SVG-based themes
3. **Qt6ct Bridge**: Ensures Qt6 applications use Kvantum as their style
4. **Home Manager Management**: Keeps configuration in sync with system rebuilds

### **File Locations**
- Theme files: `~/.config/Kvantum/RosePine/`
- Kvantum config: `~/.config/Kvantum/kvantum.kvconfig`
- KDE colors: `~/.config/kdeglobals`
- Qt6 settings: `~/.config/qt6ct/qt6ct.conf`

## 🚨 Emergency Reset

If theming breaks completely:
```bash
# Remove theme configurations (they'll be recreated by Home Manager)
rm ~/.config/kdeglobals ~/.config/Kvantum/kvantum.kvconfig ~/.config/qt6ct/qt6ct.conf

# Rebuild Home Manager
fish -c "nixos-apply-config"

# Check status
~/nixos-config/scripts/check-rose-pine-theme.sh
```

---

**🎉 Enjoy your beautifully themed Dolphin file manager!**

*This setup provides consistent Rose Pine theming across all KDE/Qt applications in your Hyprland environment. The dark, soothing colors are perfect for long coding sessions and provide excellent readability.*

## 📞 Support

If you encounter issues:
1. Run the status checker first
2. Check the troubleshooting section
3. Ensure all environment variables are set correctly
4. Try manual theme tools for fine-tuning

Your Dolphin file manager should now display beautiful Rose Pine colors that match your overall system theme!