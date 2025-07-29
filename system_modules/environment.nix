{ pkgs, ... }:

{
  # **SYSTEM ENVIRONMENT CONFIGURATION**
  # Defines system-level environment variables and packages.
  # Note: User-specific environment variables are configured in home_modules/environment.nix
  
  # **NIX CONFIGURATION**
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ];
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
    download-buffer-size = 67108864;
  };

  # **SYSTEM ENVIRONMENT VARIABLES**
  environment.sessionVariables = {
    # Wayland support
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
    GDK_PIXBUF_MODULE_FILE = "/run/current-system/sw/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

    # Default applications (also defined in home_modules for user-specific overrides)
    TERMINAL = "kitty";
    EDITOR = "micro";
    VISUAL = "micro";
    BROWSER = "zen-beta";
    FILECHOOSER = "dolphin";

    # NixOS configuration paths
    NIXOS_CONFIG_DIR = "/home/popcat19/nixos-config";
    NIXOS_FLAKE_HOSTNAME = "popcat19-nixos0";
  };

  # **SYSTEM PACKAGES**
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    micro
    wget
    curl
    git
    
    # Package management
    flatpak-builder
    
    # Network tools
    protonvpn-gui
    wireguard-tools
    
    # Virtualization
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    libvirt
    qemu
    
    # Hardware tools
    i2c-tools
    ddcutil
    usbutils
    
    # Development tools
    python313Packages.pip
    gh
    
    # System utilities
    xdg-utils
    shared-mime-info
    fuse
    
    # Gaming/Graphics
    rocmPackages.rpp
    
    # Quick tools
    quickgui
    quickemu
    
    # Shell
    starship
  ];
}