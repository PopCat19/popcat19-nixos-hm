# HyprPanel Configuration Workaround

## Overview

This directory contains a temporary workaround for HyprPanel configuration due to issues with the Home Manager module. The HyprPanel Home Manager module currently has compatibility issues with newer versions of Home Manager (see: https://github.com/Jas-SinghFSU/HyprPanel/issues/724).

## Files

- `config.json` - HyprPanel configuration in JSON format
- `start_hyprpanel.sh` - Startup script that manages HyprPanel execution
- `README.md` - This documentation file (you are here)

## How It Works

1. **Package Installation**: HyprPanel is installed as a regular package via `home-packages.nix` instead of using the broken Home Manager module.

2. **Configuration**: The `config.json` file contains all your HyprPanel settings converted from the previous Home Manager format to the JSON format expected by HyprPanel.

3. **Startup**: The `start_hyprpanel.sh` script:
   - Copies the latest configuration to `~/.config/hypr/hyprpanel/config.json`
   - Kills any existing HyprPanel instances
   - Starts HyprPanel with the configuration

4. **Autostart**: HyprPanel is automatically started via Hyprland's `exec-once` in `hyprland.conf`

## Key Bindings

- `Ctrl+Alt+W` - Restart HyprPanel (useful for testing configuration changes)

## Configuration Changes

To modify HyprPanel settings:

1. Edit `config.json` in this directory
2. Either restart Hyprland or press `Ctrl+Alt+W` to reload HyprPanel
3. The startup script will automatically copy your changes to the runtime location

## Rose Pine Theme

The configuration includes Rose Pine theme settings that match your overall system theme:

- Theme name: `rose_pine`
- Font: Noto Sans
- Bar opacity: 40%
- Border radius: 1.2em
- Custom color scheme integration

## Layout

The panel layout is configured as:
- **Left**: Dashboard, Workspaces, Media
- **Middle**: (empty)
- **Right**: Network, Bluetooth, Volume, System Tray, Clock, Notifications

## Weather Integration

Weather is enabled for Suffolk with metric units. If you need to change the location or API key, edit the following in `config.json`:

```json
"menus.clock.weather.location": "Your City",
"menus.clock.weather.key": "your-api-key"
```

## Future Migration

Once the HyprPanel Home Manager module is fixed, you can:

1. Re-enable `./home-hyprpanel.nix` in `home.nix`
2. Remove `hyprpanel` from `home-packages.nix`  
3. Remove the autostart line from `hyprland.conf`
4. Update the key binding to use the Home Manager service

## Troubleshooting

**HyprPanel not starting:**
- Check if the package is installed: `which hyprpanel`
- Run the script manually: `~/.config/hypr/hyprpanel/start_hyprpanel.sh`
- Check Hyprland logs for errors

**Configuration not applying:**
- Verify `config.json` syntax with a JSON validator
- Check file permissions on the startup script
- Ensure the config directory exists: `~/.config/hypr/hyprpanel/`

**Panel looks wrong:**
- Verify Rose Pine theme is available in HyprPanel
- Check font availability: `fc-list | grep "Noto Sans"`
- Try resetting to default theme temporarily

## Notes

- This is a temporary solution until the upstream Home Manager module is fixed
- The configuration format matches HyprPanel's expected JSON structure
- All your previous settings have been preserved and converted
- The startup script ensures configuration stays in sync with your NixOS config