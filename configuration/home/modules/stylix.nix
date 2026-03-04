# stylix.nix
#
# Purpose: Configure comprehensive theming using Stylix framework
#
# This module:
# - Sets up Rose Pine Base16 color scheme via Stylix
# - Configures fonts and font sizes
# - Manages GTK, Qt, and desktop environment theming
{
  pkgs,
  inputs,
  userConfig,
  ...
}:
{
  imports = [
    inputs.pmd.homeManagerModules.pmd
    inputs.stylix.homeModules.stylix
  ];

  home.file.".config/kdeglobals".text = ''
    [Icons]
    Theme=Papirus-Dark

    [UiSettings]
    ColorScheme=Stylix
  '';

  home.packages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme
    kdePackages.qt6ct
    papirus-icon-theme
  ];

  stylix = {
    autoEnable = true;
    enable = true;
    opacity.applications = 1.0;
    polarity = "dark";

    cursor = {
      name = "rose-pine-hyprcursor";
      package = pkgs.rose-pine-hyprcursor;
      size = 24;
    };

    fonts = {
      emoji = {
        package = pkgs.${userConfig.fonts.emoji.packageName};
        inherit (userConfig.fonts.emoji) name;
      };

      monospace = {
        package = pkgs.nerd-fonts.${userConfig.fonts.monospace.packageName};
        inherit (userConfig.fonts.monospace) name;
      };

      sansSerif = {
        package = pkgs.${userConfig.fonts.sansSerif.packageName};
        inherit (userConfig.fonts.sansSerif) name;
      };

      serif = {
        package = pkgs.${userConfig.fonts.serif.packageName};
        inherit (userConfig.fonts.serif) name;
      };

      sizes = {
        applications = userConfig.fonts.monospace.size;
        desktop = userConfig.fonts.monospace.size;
        popups = userConfig.fonts.monospace.size;
        terminal = userConfig.fonts.monospace.size;
      };
    };

    icons = {
      dark = "Papirus-Dark";
      enable = true;
      package = pkgs.papirus-icon-theme;
    };

    pmd = {
      enable = true;
      inherit (userConfig.theme) hue variant;
      wallpaper.enable = false;
    };

    targets = {
      helix.enable = true;
      nixcord.enable = true;
      vencord.enable = true;
      vesktop.enable = true;
      vscode.enable = true;
      zed.enable = true;
      zen-browser = {
        enable = true;
        profileNames = [ "default" ];
      };
    };
  };
}
