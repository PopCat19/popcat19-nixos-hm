# System Environment Configuration Module
#
# Purpose: Configure system-level environment variables and Nix settings
# Dependencies: None
# Related: home_modules/environment.nix, greeter.nix
#
# This module:
# - Configures Nix package manager settings and experimental features
# - Sets system environment variables for Wayland and desktop environment
# - Defines default applications and configuration paths
# - Manages garbage collection and trusted users
{
  userConfig,
  config,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "fetch-tree"
      "impure-derivations"
    ];
    accept-flake-config = true;
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    substituters = [
      "https://cache.nixos.org"
      "https://shimboot-systemd-nixos.cachix.org"
      "https://ezkea.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
    download-buffer-size = 67108864;
    trusted-users = ["root" userConfig.user.username];
  };

  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 3d";
  };

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_DESKTOP_PORTAL = "1";
    NIXOS_OZONE_WL = "1";

    XDG_ICON_THEME = "Papirus-Dark";

    TERMINAL = userConfig.defaultApps.terminal.command;
    EDITOR = userConfig.defaultApps.editor.command;
    VISUAL = userConfig.defaultApps.editor.command;
    BROWSER = userConfig.defaultApps.browser.command;
    FILECHOOSER = userConfig.defaultApps.fileManager.package;

    NIXOS_CONFIG_DIR = "${userConfig.directories.home}/nixos-config";
    NIXOS_FLAKE_HOSTNAME = userConfig.host.hostname;
  };
}
