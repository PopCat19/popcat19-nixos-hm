{ pkgs, ... }:

{
  # **DISPLAY STACK CONFIGURATION**
  # Defines X11, Wayland, Hyprland, and display manager settings.
  
  # **X11 SERVER**
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    desktopManager.runXdgAutostartIfNone = true;
  };

  # **HYPRLAND WAYLAND COMPOSITOR**
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.uwsm.enable = true;

  # **XDG PORTAL CONFIGURATION**
  xdg = {
    mime.enable = true;
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };

  # **DISPLAY MANAGER (SDDM)**
  services.displayManager.sddm = {
    enable = true;
    settings.Theme = {
      CursorTheme = "rose-pine-hyprcursor";
      CursorSize = "24";
    };
  };

  # **DCONF CONFIGURATION**
  programs.dconf.enable = true;
}