{pkgs, ...}: {
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    desktopManager.runXdgAutostartIfNone = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.uwsm.enable = true;

  xdg = {
    mime.enable = true;
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    };
  };

  services.displayManager.sddm = {
    enable = true;
    settings.Theme = {
      CursorTheme = "rose-pine-hyprcursor";
      CursorSize = "24";
    };
  };

  programs.dconf.enable = true;
}
