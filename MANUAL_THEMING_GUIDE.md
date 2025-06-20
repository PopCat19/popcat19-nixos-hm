# Manual Theming and Default Applications Guide

This guide explains how to manually configure themes and default applications after the NixOS configuration changes that allow manual control.

## 🌐 Default Applications (Zen Browser Setup)

### Method 1: Using mimeapps.list (Recommended)

Edit `~/.config/mimeapps.list` and add/modify the `[Default Applications]` section:

```ini
[Default Applications]
x-scheme-handler/http=app.zen_browser.zen.desktop
x-scheme-handler/https=app.zen_browser.zen.desktop
text/html=app.zen_browser.zen.desktop
application/xhtml+xml=app.zen_browser.zen.desktop
```

### Method 2: Using xdg-settings (Alternative)

```bash
xdg-settings set default-web-browser app.zen_browser.zen.desktop
```

### Verify Default Browser

```bash
xdg-settings get default-web-browser
```

## 🎨 GTK Theme Configuration

### Using nwg-look (GUI - Recommended)

1. Launch nwg-look:
   ```bash
   nwg-look
   ```

2. Available themes to choose from:
   - **rose-pine-gtk** (Rose Pine theme)
   - **catppuccin-gtk** (Catppuccin theme)
   - **Adwaita** (GNOME default)
   - **Adwaita-dark** (GNOME dark theme)

3. Set your preferred:
   - **Widget Theme**: Choose from available GTK themes
   - **Icon Theme**: Papirus-Dark, Adwaita, etc.
   - **Font**: Noto Sans or your preference
   - **Cursor Theme**: Already set to rose-pine-hyprcursor

### Using gsettings (Command Line)

```bash
# Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "rose-pine-gtk"

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

# Set font
gsettings set org.gnome.desktop.interface font-name "Noto Sans 10"

# Verify settings
gsettings get org.gnome.desktop.interface gtk-theme
```

### Manual Configuration

Edit `~/.config/gtk-3.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=rose-pine-gtk
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=rose-pine-hyprcursor
gtk-cursor-theme-size=24
```

Edit `~/.config/gtk-4.0/settings.ini` (same format for GTK4 apps).

## 🖥️ Qt Theme Configuration

### Using qt6ct (GUI - Recommended)

1. Launch qt6ct:
   ```bash
   qt6ct
   ```

2. Configure:
   - **Style**: Choose from available Qt styles
   - **Palette**: Set colors or use system palette
   - **Fonts**: Match your GTK font settings
   - **Icon Theme**: Choose from available icon themes

3. Apply and save settings

### Using Kvantum Manager

1. Launch Kvantum Manager:
   ```bash
   kvantummanager
   ```

2. Available themes:
   - **RosePine** (Already installed)
   - Install additional themes via the manager

3. Select and apply your preferred theme

### Manual Kvantum Configuration

Edit `~/.config/Kvantum/kvantum.kvconfig`:

```ini
[General]
theme=RosePine
```

## 🖱️ Cursor Theme (Already Configured)

The cursor theme is automatically managed for Hyprland compatibility:
- **Theme**: rose-pine-hyprcursor
- **Size**: 24px
- **Applied to**: GTK, Qt, and Hyprland

## 🎯 Available Theme Packages

The following theme packages are installed and available:

### GTK Themes
- `rose-pine-gtk-theme` - Rose Pine GTK theme
- `catppuccin-gtk` - Catppuccin GTK theme variants

### Icon Themes
- `papirus-icon-theme` - Papirus icon theme
- `adwaita-icon-theme` - GNOME Adwaita icons

### Qt/Kvantum Themes
- `rose-pine-kvantum` - Rose Pine for Qt applications
- `libsForQt5.qtstyleplugin-kvantum` - Kvantum engine for Qt5
- `qt6Packages.qtstyleplugin-kvantum` - Kvantum engine for Qt6

### Cursor Themes
- `rose-pine-hyprcursor` - Rose Pine cursor theme (Hyprland compatible)

## 🔧 Useful Commands

### Theme Management
```bash
# Launch theme configuration tools
nwg-look          # GTK theme manager
qt6ct             # Qt6 configuration tool
kvantummanager    # Kvantum theme manager
dconf-editor      # Advanced dconf settings

# Apply theme changes
dconf update      # Apply dconf/gsettings changes
```

### Default Application Management
```bash
# List all default applications
xdg-settings list

# Check specific default
xdg-settings get default-web-browser

# Set default web browser
xdg-settings set default-web-browser app.zen_browser.zen.desktop
```

### Troubleshooting
```bash
# Check available .desktop files for applications
ls /usr/share/applications/ | grep -i zen
ls ~/.local/share/applications/ | grep -i zen

# Check mimeapps configuration
cat ~/.config/mimeapps.list

# Check current GTK settings
gsettings list-recursively org.gnome.desktop.interface
```

## 📝 Notes

1. **Hyprland Integration**: Cursor themes are automatically applied to Hyprland
2. **Consistency**: Use the same color scheme across GTK and Qt for consistency
3. **Flatpak Apps**: May need separate theming configuration
4. **Reboot/Relogin**: Some theme changes may require restarting applications or relogging
5. **Environment Variables**: QT_QPA_PLATFORMTHEME and QT_STYLE_OVERRIDE are already configured

## 🚀 Quick Setup Commands

For a quick Rose Pine setup across all applications:

```bash
# GTK
gsettings set org.gnome.desktop.interface gtk-theme "rose-pine-gtk"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

# Create Kvantum config
mkdir -p ~/.config/Kvantum
echo -e "[General]\ntheme=RosePine" > ~/.config/Kvantum/kvantum.kvconfig

# Create mimeapps config for Zen browser
mkdir -p ~/.config
cat > ~/.config/mimeapps.list << EOF
[Default Applications]
x-scheme-handler/http=app.zen_browser.zen.desktop
x-scheme-handler/https=app.zen_browser.zen.desktop
text/html=app.zen_browser.zen.desktop
application/xhtml+xml=app.zen_browser.zen.desktop
EOF

# Apply changes
dconf update
```

After running these commands, restart your applications or re-login to see the changes take effect.