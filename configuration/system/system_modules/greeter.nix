# Greeter Configuration Module
#
# Purpose: Configure SDDM display manager for Wayland login sessions
# Dependencies: sddm, userConfig
# Related: wm.nix, xdg.nix
#
# This module:
# - Enables SDDM Wayland display manager
# - Configures theme settings and cursor appearance
# - Sets Hyprland as default session
# - Enables automatic login for configured user
{
  userConfig,
  ...
}: {
  # SDDM (Wayland) with Hyprland default session and autologin
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      settings.Theme = {
        CursorTheme = "rose-pine-hyprcursor";
        CursorSize = "24";
      };
    };

    # Ensure Hyprland session is selected on login/autologin
    defaultSession = "hyprland-uwsm";

    # Autologin configuration
    autoLogin = {
      enable = true;
      user = userConfig.user.username;
    };
  };
}