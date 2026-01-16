# Stylix Theme Module
#
# Purpose: Configure comprehensive theming using Stylix framework with Rose Pine color scheme
# Dependencies: stylix, base16-schemes, nerd-fonts, google-fonts, papirus-icon-theme
# Related: fonts.nix, display.nix, greeter.nix
#
# This module:
# - Sets up Rose Pine Base16 color scheme via Stylix
# - Configures fonts: Rounded Mplus 1c + FiraCode Nerd Font + Noto Color Emoji
# - Manages GTK, Qt, and desktop environment theming comprehensively
# - Provides cursor and icon theme integration
# - Handles browser theming targets (Firefox-based browsers)
# - Applies system-wide theming across all applications
{
  pkgs,
  inputs,
  userConfig,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
    inputs.pmd.homeManagerModules.pmd
  ];

  # Enable Stylix with auto-enable for better compatibility
  stylix.enable = true;
  stylix.autoEnable = true;
  stylix.polarity = "dark";

  # PMD Theme Configuration
  # Uses centralized theme configuration from userConfig
  stylix.pmd = {
    enable = true;
    inherit (userConfig.theme) hue;
    inherit (userConfig.theme) variant;

    # DISABLE PMD Wallpaper generation here
    wallpaper.enable = false;
  };

  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

  # Enhanced font configuration using centralized userConfig
  stylix.fonts = {
    serif = {
      package = pkgs.${userConfig.fonts.serif.packageName};
      inherit (userConfig.fonts.serif) name;
    };

    sansSerif = {
      package = pkgs.${userConfig.fonts.sansSerif.packageName};
      inherit (userConfig.fonts.sansSerif) name;
    };

    monospace = {
      package = pkgs.nerd-fonts.${userConfig.fonts.monospace.packageName};
      inherit (userConfig.fonts.monospace) name;
    };

    emoji = {
      package = pkgs.${userConfig.fonts.emoji.packageName};
      inherit (userConfig.fonts.emoji) name;
    };
  };

  # Font sizes for specific contexts
  stylix.fonts.sizes = {
    applications = userConfig.fonts.monospace.size; # For applications like fuzzel
    terminal = userConfig.fonts.monospace.size; # For terminal applications like kitty
    popups = userConfig.fonts.monospace.size; # For popup dialogs
    desktop = userConfig.fonts.monospace.size; # For desktop applications
  };

  # Optional: Align Stylix targets with PMD Effects System
  # PMD recommends no shadows/gradients, focus on borders
  # Note: 1rem at 16px base = 16px
  stylix.opacity.applications = 1.0;

  # Enable theming targets for comprehensive coverage
  stylix.targets.zen-browser.enable = true;
  stylix.targets.zen-browser.profileNames = ["default"];
  stylix.targets.vesktop.enable = true;
  stylix.targets.vencord.enable = true;
  stylix.targets.nixcord.enable = true;
  stylix.targets.zed.enable = true;
  stylix.targets.vscode.enable = true;

  # Cursor theme configuration using Stylix native option
  stylix.cursor = {
    name = "rose-pine-hyprcursor";
    package = pkgs.rose-pine-hyprcursor;
    size = 24;
  };

  # Icon theme configuration using Stylix native option
  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
  };

  # Additional packages for comprehensive theming coverage
  home.packages = with pkgs; [
    papirus-icon-theme
    # Fallback icon themes for missing icons
    adwaita-icon-theme
    hicolor-icon-theme
    # Qt styling tools for platform theme support
    kdePackages.qt6ct
  ];

  # KDE global configuration for icon theme
  home.file.".config/kdeglobals".text = ''
    [Icons]
    Theme=Papirus-Dark
  '';
}
