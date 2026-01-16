# Key Bindings Configuration
#
# Purpose: Configure keyboard shortcuts and mouse bindings for Hyprland
# Dependencies: userConfig.defaultApps
# Related: window-rules.nix
#
# This module:
# - Defines modifier keys and application variables
# - Configures system and window management shortcuts
# - Sets up application launchers and utilities
# - Binds media, volume, and brightness controls
{userConfig, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$term" = userConfig.defaultApps.terminal.command;
    "$editor" = userConfig.defaultApps.editor.command;
    "$file" = userConfig.defaultApps.fileManager.command;
    "$browser" = userConfig.defaultApps.browser.command;
    "$menu" = "fuzzel --dmenu";
    "$launcher" = userConfig.defaultApps.launcher.command;

    # === WINDOW MANAGEMENT ===
    # cat: Window Management
    # desc: Close active window
    bind = [
      "$mainMod, Q, killactive"
      # desc: Close with Alt+F4
      "Alt, F4, killactive"
      # desc: Force kill window
      "$mainMod+Ctrl, Q, exec, hyprctl kill"
      # desc: Lock screen
      "$mainMod, Delete, exit"
      "$mainMod, L, exec, hyprlock"

      # desc: Toggle floating mode
      "$mainMod, W, togglefloating"
      # desc: Toggle group
      "$mainMod, G, togglegroup"
      # desc: Toggle fullscreen
      "Alt, Return, fullscreen"
      # desc: Toggle split
      "$mainMod, J, togglesplit"

      # === APPLICATION LAUNCHERS ===
      # cat: Applications
      # desc: Launch terminal
      "$mainMod, T, exec, $term"
      # desc: Launch file manager
      "$mainMod, E, exec, $file"
      # desc: Launch editor
      "$mainMod, C, exec, $editor"
      # desc: Launch browser
      "$mainMod, F, exec, $browser"
      # desc: Open Vicinae
      "$mainMod, A, exec, vicinae open"
      # desc: Open application launcher
      "$mainMod+Shift, A, exec, fuzzel"
      # desc: Pick color
      "$mainMod+Shift, C, exec, hyprpicker -a"
      # desc: Open clipboard history
      "$mainMod, V, exec, vicinae vicinae://extensions/vicinae/clipboard/history"
      # desc: Select and paste clipboard
      "$mainMod+Shift, V, exec, bash -lc \"cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy && sleep 0.05 && wtype -M ctrl -k v\""
      # desc: Restart HyprPanel
      "Ctrl+Alt, W, exec, systemctl --user restart hyprpanel.service"

      # desc: Full screenshot
      "$mainMod, P, exec, ~/.local/bin/screenshot monitor"
      # desc: Full screenshot with shader
      "$mainMod+Ctrl, P, exec, ~/.local/bin/screenshot monitor --keep-shader"
      # desc: Region screenshot
      "$mainMod+Shift, P, exec, ~/.local/bin/screenshot region"
      # desc: Region screenshot with shader
      "$mainMod+Shift+Ctrl, P, exec, ~/.local/bin/screenshot region --keep-shader"

      # === MEDIA KEYS ===
      # cat: Media
      # desc: Toggle play/pause
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioPause, exec, playerctl play-pause"
      # desc: Next track
      ",XF86AudioNext, exec, playerctl next"
      # desc: Previous track
      ",XF86AudioPrev, exec, playerctl previous"
      # desc: Stop playback
      ",XF86AudioStop, exec, playerctl stop"
      # desc: Toggle play (Alt+F8)
      "Alt, F8, exec, playerctl play-pause"
      # desc: Previous (Alt+F6)
      "Alt, F6, exec, playerctl previous"
      # desc: Next (Alt+F7)
      "Alt, F7, exec, playerctl next"

      # === FOCUS NAVIGATION ===
      # cat: Focus
      # desc: Focus left
      "$mainMod, Left, movefocus, l"
      # desc: Focus right
      "$mainMod, Right, movefocus, r"
      # desc: Focus up
      "$mainMod, Up, movefocus, u"
      # desc: Focus down
      "$mainMod, Down, movefocus, d"
      # desc: Focus next window
      "Alt, Tab, movefocus, d"

      # === GROUP NAVIGATION ===
      # cat: Groups
      # desc: Previous in group
      "$mainMod+Ctrl, H, changegroupactive, b"
      # desc: Next in group
      "$mainMod+Ctrl, L, changegroupactive, f"

      # === WORKSPACE SWITCHING ===
      # cat: Workspaces
      # desc: Switch to workspace 1
      "$mainMod, 1, workspace, 1"
      # desc: Switch to workspace 2
      "$mainMod, 2, workspace, 2"
      # desc: Switch to workspace 3
      "$mainMod, 3, workspace, 3"
      # desc: Switch to workspace 4
      "$mainMod, 4, workspace, 4"
      # desc: Switch to workspace 5
      "$mainMod, 5, workspace, 5"
      # desc: Switch to workspace 6
      "$mainMod, 6, workspace, 6"
      # desc: Switch to workspace 7
      "$mainMod, 7, workspace, 7"
      # desc: Switch to workspace 8
      "$mainMod, 8, workspace, 8"
      # desc: Switch to workspace 9
      "$mainMod, 9, workspace, 9"
      # desc: Switch to workspace 10
      "$mainMod, 0, workspace, 10"

      # desc: Next workspace
      "$mainMod+Ctrl, Right, workspace, r+1"
      # desc: Previous workspace
      "$mainMod+Ctrl, Left, workspace, r-1"
      # desc: Empty workspace
      "$mainMod+Ctrl, Down, workspace, empty"

      # === MOVE WINDOW TO WORKSPACE ===
      # cat: Workspaces
      # desc: Move to workspace 1
      "$mainMod+Shift, 1, movetoworkspace, 1"
      # desc: Move to workspace 2
      "$mainMod+Shift, 2, movetoworkspace, 2"
      # desc: Move to workspace 3
      "$mainMod+Shift, 3, movetoworkspace, 3"
      # desc: Move to workspace 4
      "$mainMod+Shift, 4, movetoworkspace, 4"
      # desc: Move to workspace 5
      "$mainMod+Shift, 5, movetoworkspace, 5"
      # desc: Move to workspace 6
      "$mainMod+Shift, 6, movetoworkspace, 6"
      # desc: Move to workspace 7
      "$mainMod+Shift, 7, movetoworkspace, 7"
      # desc: Move to workspace 8
      "$mainMod+Shift, 8, movetoworkspace, 8"
      # desc: Move to workspace 9
      "$mainMod+Shift, 9, movetoworkspace, 9"
      # desc: Move to workspace 10
      "$mainMod+Shift, 0, movetoworkspace, 10"

      # desc: Move to next workspace
      "$mainMod+Ctrl+Alt, Right, movetoworkspace, r+1"
      # desc: Move to previous workspace
      "$mainMod+Ctrl+Alt, Left, movetoworkspace, r-1"

      # === SILENT MOVE TO WORKSPACE ===
      # cat: Workspaces
      # desc: Silent move to workspace 1
      "$mainMod+Alt, 1, movetoworkspacesilent, 1"
      # desc: Silent move to workspace 2
      "$mainMod+Alt, 2, movetoworkspacesilent, 2"
      # desc: Silent move to workspace 3
      "$mainMod+Alt, 3, movetoworkspacesilent, 3"
      # desc: Silent move to workspace 4
      "$mainMod+Alt, 4, movetoworkspacesilent, 4"
      # desc: Silent move to workspace 5
      "$mainMod+Alt, 5, movetoworkspacesilent, 5"
      # desc: Silent move to workspace 6
      "$mainMod+Alt, 6, movetoworkspacesilent, 6"
      # desc: Silent move to workspace 7
      "$mainMod+Alt, 7, movetoworkspacesilent, 7"
      # desc: Silent move to workspace 8
      "$mainMod+Alt, 8, movetoworkspacesilent, 8"
      # desc: Silent move to workspace 9
      "$mainMod+Alt, 9, movetoworkspacesilent, 9"
      # desc: Silent move to workspace 10
      "$mainMod+Alt, 0, movetoworkspacesilent, 10"

      # === RESIZE WINDOW ===
      # cat: Window Management
      # desc: Resize window left
      "$mainMod+Shift+Ctrl, Left, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive -30 0; else hyprctl dispatch movewindow l; fi'"
      # desc: Resize window right
      "$mainMod+Shift+Ctrl, Right, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 30 0; else hyprctl dispatch movewindow r; fi'"
      # desc: Resize window up
      "$mainMod+Shift+Ctrl, Up, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 0 -30; else hyprctl dispatch movewindow u; fi'"
      # desc: Resize window down
      "$mainMod+Shift+Ctrl, Down, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 0 30; else hyprctl dispatch movewindow d; fi'"

      # === SCROLL WORKSPACES ===
      # cat: Workspaces
      # desc: Scroll to next workspace
      "$mainMod, mouse_down, workspace, e+1"
      # desc: Scroll to previous workspace
      "$mainMod, mouse_up, workspace, e-1"

      # === SPECIAL WORKSPACE ===
      # cat: Workspaces
      # desc: Move to special workspace
      "$mainMod+Alt, S, movetoworkspacesilent, special"
      # desc: Toggle special workspace
      "$mainMod, S, togglespecialworkspace"

      # desc: Debug layer output
      "$mainMod+Shift, N, exec, sh -c 'hyprctl layers > ~/hyprctl-layer-out.txt && $term $editor ~/hyprctl-layer-out.txt'"
    ];

    # === RESIZE ON HOLD ===
    # desc: Resize right (hold)
    binde = [
      "$mainMod+Shift, Right, resizeactive, 30 0"
      # desc: Resize left (hold)
      "$mainMod+Shift, Left, resizeactive, -30 0"
      # desc: Resize up (hold)
      "$mainMod+Shift, Up, resizeactive, 0 -30"
      # desc: Resize down (hold)
      "$mainMod+Shift, Down, resizeactive, 0 30"
    ];

    # === LOCK DISPLAY KEYS ===
    # cat: Hardware
    # desc: Volume up
    bindel = [
      ",F12, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
      # desc: Volume down
      ",F11, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
      # desc: Toggle mute
      ",F10, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      # desc: Volume up (XF86)
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
      # desc: Volume down (XF86)
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
      # desc: Toggle mute (XF86)
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      # desc: Toggle mic mute
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      # desc: Brightness up
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      # desc: Brightness down
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    # === MOUSE BINDINGS ===
    # cat: Window Management
    # desc: Drag window
    bindm = [
      "$mainMod, mouse:272, movewindow"
      # desc: Resize window
      "$mainMod, mouse:273, resizewindow"
      # desc: Move with Z key
      "$mainMod, Z, movewindow"
      # desc: Resize with X key
      "$mainMod, X, resizewindow"
    ];
  };
}
