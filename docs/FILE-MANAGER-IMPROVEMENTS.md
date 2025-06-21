# File Manager Improvements Summary

This document summarizes all the file manager improvements, terminal integration fixes, and theming enhancements applied to the NixOS configuration.

## Overview

The following improvements have been implemented:

1. **File Manager Bookmark Ordering** - Fixed ordering for both Dolphin and GTK file managers
2. **Terminal Integration** - Fixed "Open Terminal Here" to use kitty instead of xterm
3. **Application Defaults** - Fixed missing applications in file selection dialogs
4. **Thumbnail Support** - Enhanced thumbnail generation for webp, mp4, mkv files
5. **Theme Accessibility** - Improved Rose Pine color accessibility and opacity matching
6. **Directory Creation** - Declaratively create Videos and Music directories

## Changes Made

### System Configuration (`configuration.nix`)

#### Added Packages
- `dolphin` - KDE file manager
- `nemo` - GTK file manager alternative
- `ffmpegthumbnailer` - Video thumbnail generation
- `poppler_utils` - PDF thumbnail generation
- `libgsf` - Office document thumbnails
- `webp-pixbuf-loader` - WebP image support
- `kdePackages.kdegraphics-thumbnailers` - KDE thumbnail generators
- `kdePackages.kimageformats` - Additional image format support
- `kdePackages.kio-extras` - KDE I/O extras for thumbnails

#### Directory Creation
```nix
systemd.tmpfiles.rules = [
  "d /home/popcat19/Videos 0755 popcat19 users -"
  "d /home/popcat19/Music 0755 popcat19 users -"
];
```

#### Environment Variables
- `TERMINAL = "kitty"` - Default terminal application
- `EDITOR = "micro"` - Default text editor
- `VISUAL = "micro"` - Default visual editor
- `GST_PLUGIN_SYSTEM_PATH_1_0` - GStreamer plugin path for thumbnails
- `GDK_PIXBUF_MODULE_FILE` - GTK pixbuf module cache

### Home Manager Configuration (`home.nix`)

#### XDG MIME Applications
Comprehensive application defaults for all file types:
- **Terminal**: `kitty.desktop`
- **Text Editor**: `micro.desktop`
- **Image Viewer**: `org.kde.gwenview.desktop`
- **Video Player**: `mpv.desktop`
- **File Manager**: `org.kde.dolphin.desktop`
- **PDF Viewer**: `okular.desktop`
- **Archive Manager**: `org.kde.ark.desktop`

#### GTK Bookmarks (Nemo/Nautilus)
Ordered as requested:
1. Documents
2. Downloads
3. Pictures
4. Videos
5. Music
6. syncthing-shared
7. Desktop
8. Trash

#### Dolphin Bookmarks
Ordered as requested:
1. Home
2. Documents
3. Downloads
4. Pictures
5. Videos
6. Music
7. syncthing-shared
8. Desktop
9. Trash

#### File Manager Configurations

**Dolphin Configuration** (`~/.config/dolphinrc`):
- Enabled archive browsing
- Enhanced thumbnail support
- Proper icon sizing for different view modes
- Better preview settings

**Nemo Configuration** (`~/.config/nemo/nemo.conf`):
- Set kitty as terminal command
- Enabled thumbnail generation
- Configured proper view settings
- Added toolbar customizations

#### KDE Integration

**Terminal Integration** (`~/.config/kdeglobals`):
```ini
[General]
TerminalApplication=kitty
TerminalService=kitty.desktop
```

**Thumbnail Settings**:
```ini
[PreviewSettings]
Plugins=appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,textthumbnail,ffmpegthumbs
MaximumSize=10485760
EnableRemoteFolderThumbnail=false
```

#### Desktop Files
Created custom desktop files for better integration:
- `kitty.desktop` - Terminal emulator with proper MIME types
- `micro.desktop` - Text editor with terminal support

#### Nemo Actions
- `open-in-kitty.nemo_action` - Context menu to open terminal
- `edit-as-root.nemo_action` - Context menu to edit files as root with pkexec

#### Thumbnail Management
- `update-thumbnails` script - Regenerates thumbnail cache
- Systemd user service for automatic thumbnail updates
- dconf settings for thumbnail preferences

#### Theme Improvements

**Kitty Opacity/Blur**:
- `background_opacity = "0.85"`
- `background_blur = 20`

**Window Opacity** (Hyprland):
- Updated all window opacity rules to 0.85 to match kitty
- Added opacity rules for file managers (dolphin, nemo, nautilus)

#### dconf Settings
Added comprehensive settings for:
- Thumbnail generation preferences
- Nautilus/Nemo file manager settings
- Desktop interface preferences
- Recent files management

## File Manager Features

### Dolphin
✅ **Bookmarks**: Correctly ordered as requested  
✅ **Terminal Integration**: Opens kitty instead of xterm  
✅ **Thumbnails**: Enhanced support for webp, mp4, mkv files  
✅ **Theme**: Rose Pine with improved accessibility  
✅ **Opacity**: Matches kitty (0.85) with blur support  

### Nemo
✅ **Bookmarks**: GTK bookmarks in correct order  
✅ **Terminal Integration**: Context menu opens kitty  
✅ **Root Access**: "Edit as Root" works with pkexec  
✅ **Thumbnails**: Full thumbnail support enabled  
✅ **Theme**: Rose Pine GTK theme applied  

### Application Integration
✅ **File Selection Dialogs**: Now show all available applications  
✅ **Default Applications**: Proper MIME type associations  
✅ **Terminal**: kitty is default terminal everywhere  
✅ **Text Editor**: micro is default for all text files  

## Accessibility Improvements

### Rose Pine Colors
The Rose Pine color scheme has been configured with proper accessibility:
- **Base** (#191724): Primary background
- **Surface** (#1f1d2e): Secondary background
- **Text** (#e0def4): High contrast foreground
- **Subtle** (#908caa): Medium contrast foreground
- **Muted** (#6e6a86): Low contrast foreground

### Visual Consistency
- All file managers use consistent 0.85 opacity
- Blur effects match across applications
- Icon themes consistent (Papirus-Dark)
- Font consistency (Rounded Mplus 1c Medium)

## How to Apply

1. Rebuild your NixOS configuration:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config
   ```

2. Update thumbnails manually (first time):
   ```bash
   ~/.local/bin/update-thumbnails
   ```

3. Restart your desktop session to apply all changes

## Troubleshooting

### If thumbnails don't appear:
1. Run the thumbnail update script: `~/.local/bin/update-thumbnails`
2. Check if thumbnail generation packages are installed
3. Verify dconf settings with `dconf-editor`

### If terminal integration doesn't work:
1. Verify kitty is installed and in PATH
2. Check XDG MIME associations: `xdg-mime query default application/x-terminal-emulator`
3. Update desktop database: `update-desktop-database ~/.local/share/applications`

### If file selection shows no applications:
1. Update MIME database: `update-mime-database ~/.local/share/mime`
2. Check desktop files in `~/.local/share/applications`
3. Verify XDG_DATA_DIRS includes user directories

## Additional Notes

- The `syncthing-shared` directory is automatically created in the home directory
- Videos and Music directories are created at system level
- Thumbnail cache is automatically updated on login via systemd user service
- All configurations are declarative and will persist across rebuilds