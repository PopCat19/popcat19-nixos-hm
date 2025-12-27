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

  # System-wide icon theme for SDDM and other applications
  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    # Fallback icon themes for missing icons
    adwaita-icon-theme
    hicolor-icon-theme
  ];

  # Set global icon theme
  environment.sessionVariables = {
    XDG_ICON_THEME = "Papirus-Dark";
  };

  # XDG icon theme configuration
  xdg.icons.enable = true;
}