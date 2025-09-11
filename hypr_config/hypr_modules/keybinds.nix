# Key Bindings for Hyprland
# ==========================
{userConfig, ...}: {
  wayland.windowManager.hyprland.settings = {
    # Main modifier key
    "$mainMod" = "SUPER";

    # Application Variables
    "$term" = userConfig.defaultApps.terminal.command;
    "$editor" = userConfig.defaultApps.editor.command;
    "$file" = userConfig.defaultApps.fileManager.command;
    "$browser" = userConfig.defaultApps.browser.command;
    "$menu" = "${userConfig.defaultApps.launcher.command} --dmenu";
    "$launcher" = userConfig.defaultApps.launcher.command;

    # Key bindings
    bind = [
      # System Actions
      "$mainMod, Q, killactive"
      "Alt, F4, killactive"
      "$mainMod+Ctrl, Q, exec, hyprctl kill"
      "$mainMod, Delete, exit"
      "$mainMod, L, exec, swaylock"

      # Window Management
      "$mainMod, W, togglefloating"
      "$mainMod, G, togglegroup"
      "Alt, Return, fullscreen"
      "$mainMod, J, togglesplit"

      # Application Shortcuts
      "$mainMod, T, exec, $term"
      "$mainMod, E, exec, $file"
      "$mainMod, C, exec, $editor"
      "$mainMod, F, exec, $browser"
      "$mainMod, A, exec, $launcher"

      # Utilities
      "$mainMod+Shift, C, exec, hyprpicker -a"
      # Clipboard: open picker to choose entry, then paste
      "$mainMod, V, exec, bash -lc \"cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy && sleep 0.05 && wtype -M ctrl -k v\""
      # Clipboard: quick-paste latest entry (no menu)
      "$mainMod+Shift, V, exec, bash -lc 'cliphist list | head -n1 | cliphist decode | wl-copy && sleep 0.05 && wtype -M ctrl -k v'"
      "Ctrl+Alt, W, exec, systemctl --user restart hyprpanel.service"

      # Screenshots - Clipboard screenshots (primary keybindings)
      "$mainMod, P, exec, ~/.local/bin/screenshot region"

      # Screenshots - Save to file screenshots (secondary keybindings)
      "$mainMod+Shift, P, exec, ~/.local/bin/screenshot monitor"

      # Media playback
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioPause, exec, playerctl play-pause"
      ",XF86AudioNext, exec, playerctl next"
      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86AudioStop, exec, playerctl stop"
      # Custom media keys
      "Alt, F8, exec, playerctl play-pause"
      "Alt, F6, exec, playerctl previous"
      "Alt, F7, exec, playerctl next"

      # Window Focus
      "$mainMod, Left, movefocus, l"
      "$mainMod, Right, movefocus, r"
      "$mainMod, Up, movefocus, u"
      "$mainMod, Down, movefocus, d"
      "Alt, Tab, movefocus, d"

      # Group Management
      "$mainMod+Ctrl, H, changegroupactive, b"
      "$mainMod+Ctrl, L, changegroupactive, f"

      # Direct workspace switching
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Relative workspace switching
      "$mainMod+Ctrl, Right, workspace, r+1"
      "$mainMod+Ctrl, Left, workspace, r-1"
      "$mainMod+Ctrl, Down, workspace, empty"

      # Move to specific workspaces
      "$mainMod+Shift, 1, movetoworkspace, 1"
      "$mainMod+Shift, 2, movetoworkspace, 2"
      "$mainMod+Shift, 3, movetoworkspace, 3"
      "$mainMod+Shift, 4, movetoworkspace, 4"
      "$mainMod+Shift, 5, movetoworkspace, 5"
      "$mainMod+Shift, 6, movetoworkspace, 6"
      "$mainMod+Shift, 7, movetoworkspace, 7"
      "$mainMod+Shift, 8, movetoworkspace, 8"
      "$mainMod+Shift, 9, movetoworkspace, 9"
      "$mainMod+Shift, 0, movetoworkspace, 10"

      # Move to relative workspaces
      "$mainMod+Ctrl+Alt, Right, movetoworkspace, r+1"
      "$mainMod+Ctrl+Alt, Left, movetoworkspace, r-1"

      # Move to workspaces silently
      "$mainMod+Alt, 1, movetoworkspacesilent, 1"
      "$mainMod+Alt, 2, movetoworkspacesilent, 2"
      "$mainMod+Alt, 3, movetoworkspacesilent, 3"
      "$mainMod+Alt, 4, movetoworkspacesilent, 4"
      "$mainMod+Alt, 5, movetoworkspacesilent, 5"
      "$mainMod+Alt, 6, movetoworkspacesilent, 6"
      "$mainMod+Alt, 7, movetoworkspacesilent, 7"
      "$mainMod+Alt, 8, movetoworkspacesilent, 8"
      "$mainMod+Alt, 9, movetoworkspacesilent, 9"
      "$mainMod+Alt, 0, movetoworkspacesilent, 10"

      # Window Position Adjustment
      "$mainMod+Shift+Ctrl, Left, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive -30 0; else hyprctl dispatch movewindow l; fi'"
      "$mainMod+Shift+Ctrl, Right, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 30 0; else hyprctl dispatch movewindow r; fi'"
      "$mainMod+Shift+Ctrl, Up, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 0 -30; else hyprctl dispatch movewindow u; fi'"
      "$mainMod+Shift+Ctrl, Down, exec, bash -c 'if grep -q \"true\" <<< $(hyprctl activewindow -j | jq -r .floating); then hyprctl dispatch moveactive 0 30; else hyprctl dispatch movewindow d; fi'"

      # Mouse Controls
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"

      # Special Workspace (Scratchpad)
      "$mainMod+Alt, S, movetoworkspacesilent, special"
      "$mainMod, S, togglespecialworkspace"

      # Debug & Development
      "$mainMod+Shift, N, exec, sh -c 'hyprctl layers > ~/hyprctl-layer-out.txt && $term $editor ~/hyprctl-layer-out.txt'"
    ];

    # Repeating key bindings
    binde = [
      # Window Resizing
      "$mainMod+Shift, Right, resizeactive, 30 0"
      "$mainMod+Shift, Left, resizeactive, -30 0"
      "$mainMod+Shift, Up, resizeactive, 0 -30"
      "$mainMod+Shift, Down, resizeactive, 0 30"
    ];

    # Volume and brightness controls
    bindel = [
      # Volume control
      ",F12, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
      ",F11, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
      ",F10, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      # Brightness control
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    # Mouse bindings
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
      "$mainMod, Z, movewindow"
      "$mainMod, X, resizewindow"
    ];
  };
}
