# greeter.nix
#
# Purpose: Configure SDDM display manager for Wayland login sessions
#
# This module:
# - Enables SDDM Wayland display manager
# - Configures theme settings and cursor appearance
# - Sets Hyprland as default session
# - Enables automatic login for configured user
{
  pkgs,
  userConfig,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme
    papirus-icon-theme
  ];

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = userConfig.username;
    };
    defaultSession = "hyprland-uwsm";
    sddm = {
      enable = true;
      settings.Theme = {
        CursorSize = "24";
        CursorTheme = "rose-pine-hyprcursor";
      };
      wayland.enable = true;
    };
  };

  xdg.icons.enable = true;
}
