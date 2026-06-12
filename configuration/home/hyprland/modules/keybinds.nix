# keybinds.nix
#
# Purpose: Configure keyboard shortcuts and mouse bindings for Hyprland
#
# This module:
# - Defines modifier keys and application variables
# - Configures system and window management shortcuts
# - Sets up application launchers and utilities
# - Binds media, volume, and brightness controls
{ userConfig, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$term" = userConfig.defaultApps.terminal.command;
    "$editor" = userConfig.defaultApps.editor.command;
    "$file" = userConfig.defaultApps.fileManager.command;
    "$browser" = userConfig.defaultApps.browser.command;
    "$menu" = "fuzzel --dmenu";
    "$launcher" = userConfig.defaultApps.launcher.command;

    bind = [
      # === Window Management ===
      # cat: Window
      # desc: Close active window
      "$mainMod, Q, killactive"
      # desc: Close window (Windows style)
      "Alt, F4, killactive"
      # desc: Kill all windows in group
      "$mainMod+Ctrl, Q, exec, hyprctl kill"
      # desc: Exit Hyprland
      "$mainMod, Delete, exit"
      # desc: Lock screen
      "$mainMod+Ctrl, L, exec, hyprlock"
      # desc: Toggle floating mode
      "$mainMod, W, togglefloating"
      # desc: Toggle window group
      "$mainMod, G, togglegroup"
      # desc: Toggle fullscreen
      "Alt, Return, fullscreen"
      # desc: Toggle split layout
      "$mainMod, J, exec, $HYPRLAND_CONFIG_DIR/scripts/togglesplit.sh"

      # === Applications ===
      # cat: Apps
      # desc: Open terminal
      "$mainMod, T, exec, $term"
      # desc: Open file manager
      "$mainMod, E, exec, $file"
      # desc: Open editor
      "$mainMod, C, exec, $editor"
      # desc: Open browser
      "$mainMod, F, exec, $browser"
      # desc: Open app launcher (fuzzel)
      "$mainMod, A, exec, fuzzel"
      # desc: Color picker
      "$mainMod+Shift, C, exec, hyprpicker -a"
      # desc: Clipboard history
      "$mainMod, V, exec, bash -lc \"cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy && sleep 0.05 && wtype -M ctrl -k v\""
      # desc: Restart panel
      "Ctrl+Alt, W, exec, systemctl --user restart hyprpanel.service"
      # desc: Restart shell
      "$mainMod+Ctrl, N, exec, systemctl --user restart noctalia.service"

      # === Screenshots ===
      # cat: Screenshots
      # desc: Screenshot region
      "$mainMod, P, exec, ~/.local/bin/screenshot region"
      # desc: Screenshot monitor
      "$mainMod+Shift, P, exec, ~/.local/bin/screenshot monitor"

      # === Media Controls ===
      # cat: Media
      # desc: Play/pause
      ",XF86AudioPlay, exec, playerctl play-pause"
      # desc: Play/pause
      ",XF86AudioPause, exec, playerctl play-pause"
      # desc: Next track
      ",XF86AudioNext, exec, playerctl next"
      # desc: Previous track
      ",XF86AudioPrev, exec, playerctl previous"
      # desc: Stop playback
      ",XF86AudioStop, exec, playerctl stop"
      # desc: Play/pause (keyboard)
      "Alt, F8, exec, playerctl play-pause"
      # desc: Previous track (keyboard)
      "Alt, F6, exec, playerctl previous"
      # desc: Next track (keyboard)
      "Alt, F7, exec, playerctl next"

      # === Focus Navigation ===
      # cat: Focus
      # desc: Focus left
      "$mainMod, Left, movefocus, l"
      # desc: Focus right
      "$mainMod, Right, movefocus, r"
      # desc: Focus up
      "$mainMod, Up, movefocus, u"
      # desc: Focus down
      "$mainMod, Down, movefocus, d"
      # desc: Focus left (vim)
      "$mainMod, h, movefocus, l"
      # desc: Focus right (vim)
      "$mainMod, l, movefocus, r"
      # desc: Focus up (vim)
      "$mainMod, k, movefocus, u"
      # desc: Focus down (vim)
      "$mainMod, j, movefocus, d"
      # desc: Cycle focus
      "Alt, Tab, movefocus, d"
      # desc: Cycle group active
      "$mainMod+Ctrl, L, changegroupactive, f"

      # === Workspace Switch ===
      # cat: Workspaces
      # desc: Go to workspace 1
      "$mainMod, 1, workspace, 1"
      # desc: Go to workspace 2
      "$mainMod, 2, workspace, 2"
      # desc: Go to workspace 3
      "$mainMod, 3, workspace, 3"
      # desc: Go to workspace 4
      "$mainMod, 4, workspace, 4"
      # desc: Go to workspace 5
      "$mainMod, 5, workspace, 5"
      # desc: Go to workspace 6
      "$mainMod, 6, workspace, 6"
      # desc: Go to workspace 7
      "$mainMod, 7, workspace, 7"
      # desc: Go to workspace 8
      "$mainMod, 8, workspace, 8"
      # desc: Go to workspace 9
      "$mainMod, 9, workspace, 9"
      # desc: Go to workspace 10
      "$mainMod, 0, workspace, 10"
      # desc: Next workspace
      "$mainMod+Ctrl, Right, workspace, r+1"
      # desc: Previous workspace
      "$mainMod+Ctrl, Left, workspace, r-1"
      # desc: Empty workspace
      "$mainMod+Ctrl, Down, workspace, empty"

      # === Move to Workspace ===
      # cat: Move Window
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

      # === Silent Move (no switch) ===
      # cat: Move Silent
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

      # === Window Movement ===
      # cat: Move Position
      # desc: Move window left
      "$mainMod+Shift+Ctrl, Left, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive -30 0; else hyprctl dispatch movewindow l; fi'"
      # desc: Move window right
      "$mainMod+Shift+Ctrl, Right, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 30 0; else hyprctl dispatch movewindow r; fi'"
      # desc: Move window up
      "$mainMod+Shift+Ctrl, Up, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 0 -30; else hyprctl dispatch movewindow u; fi'"
      # desc: Move window down
      "$mainMod+Shift+Ctrl, Down, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 0 30; else hyprctl dispatch movewindow d; fi'"

      # === Mouse Workspace ===
      # cat: Mouse
      # desc: Scroll workspace next
      "$mainMod, mouse_down, workspace, e+1"
      # desc: Scroll workspace prev
      "$mainMod, mouse_up, workspace, e-1"

      # === Special Workspace ===
      # cat: Special
      # desc: Silent move to special
      "$mainMod+Alt, S, movetoworkspacesilent, special"
      # desc: Toggle special workspace
      "$mainMod, S, togglespecialworkspace"

      # === Debug ===
      # desc: Debug layers output
      "$mainMod+Shift, N, exec, sh -c 'hyprctl layers > ~/hyprctl-layer-out.txt && $term $editor ~/hyprctl-layer-out.txt'"
    ];

    binde = [
      # === Window Resize ===
      # cat: Resize
      # desc: Grow width
      "$mainMod+Shift, Right, resizeactive, 30 0"
      # desc: Shrink width
      "$mainMod+Shift, Left, resizeactive, -30 0"
      # desc: Shrink height
      "$mainMod+Shift, Up, resizeactive, 0 -30"
      # desc: Grow height
      "$mainMod+Shift, Down, resizeactive, 0 30"
    ];

    bindel = [
      # === Volume ===
      # cat: Volume
      # desc: Volume up (Fn+F12)
      ",F12, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
      # desc: Volume down (Fn+F11)
      ",F11, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
      # desc: Mute (Fn+F10)
      ",F10, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      # desc: Volume up (media key)
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
      # desc: Volume down (media key)
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
      # desc: Mute (media key)
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      # desc: Mic mute toggle
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      # === Brightness ===
      # cat: Brightness
      # desc: Brightness up
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      # desc: Brightness down
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    bindl = [
      # === Laptop ===
      # cat: Laptop
      # desc: Lid close -> DPMS off
      ", switch:on:Lid Switch, exec, hyprctl dispatch dpms off"
    ];

    bindm = [
      # === Mouse Bindings ===
      # cat: Mouse
      # desc: Move window (left click)
      "$mainMod, mouse:272, movewindow"
      # desc: Resize window (right click)
      "$mainMod, mouse:273, resizewindow"
      # desc: Move window (Z key)
      "$mainMod, Z, movewindow"
      # desc: Resize window (X key)
      "$mainMod, X, resizewindow"
    ];
  };
}
