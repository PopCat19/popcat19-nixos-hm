{ pkgs, userConfig, ... }: {
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

  programs.dconf.enable = true;
}
