{userConfig, ...}: {
  # System environment configuration
  # User-specific environment variables are in home_modules/environment.nix
  # System packages are in core-packages.nix and packages.nix

  # Nix configuration
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
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

  nix.extraOptions = ''
    experimental-features = fetch-tree impure-derivations ca-derivations
  '';

  # System environment variables
  environment.sessionVariables = {
    # Wayland support
    # QT/Kvantum theme support
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
    GDK_PIXBUF_MODULE_FILE = "/run/current-system/sw/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

    # Default applications
    TERMINAL = userConfig.defaultApps.terminal.command;
    EDITOR = userConfig.defaultApps.editor.command;
    VISUAL = userConfig.defaultApps.editor.command;
    BROWSER = userConfig.defaultApps.browser.command;
    FILECHOOSER = userConfig.defaultApps.fileManager.package;

    # NixOS configuration paths
    NIXOS_CONFIG_DIR = "${userConfig.directories.home}/nixos-config";
    NIXOS_FLAKE_HOSTNAME = userConfig.host.hostname;
  };
}
