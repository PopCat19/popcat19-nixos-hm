# Greeter Configuration Module
#
# Purpose: Configure SDDM display manager for Wayland login sessions
# Dependencies: sddm, userConfig, papirus-icon-theme
# Related: wm.nix, xdg.nix, stylix.nix
#
# This module:
# - Enables SDDM Wayland display manager
# - Configures theme settings, cursor, and icon appearance
# - Sets Hyprland as default session
# - Enables automatic login for configured user
{
  userConfig,
  pkgs,
  ...
}:
{
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      settings.Theme = {
        CursorTheme = "rose-pine-hyprcursor";
        CursorSize = "24";
      };
    };

    defaultSession = "hyprland-uwsm";
    autoLogin = {
      enable = true;
      user = userConfig.user.username;
    };
  };

  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
  ];

  # Icon theme centralized in system_modules/environment.nix
  xdg.icons.enable = true;
}
