# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # **IMPORTS**
  # Imports other NixOS configuration files.
  imports = [
    ./hardware-configuration.nix
  ];

  # **SYSTEM CONFIGURATION**
  # Defines the state version for system configuration.
  system.stateVersion = "24.11"; # Did you read the comment?

  # **BOOT CONFIGURATION**
  # Manages bootloader, filesystem support, and kernel.
  boot = {
    # Systemd-boot as the bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true; # Allow managing EFI variables.
    };
    supportedFilesystems = [ "ntfs" ]; # Add NTFS filesystem support.
    kernelPackages = pkgs.linuxPackages_zen; # Use the Zen kernel.
    kernelModules = [ "i2c-dev" ]; # Load the I2C development module.
  };

  # **HARDWARE CONFIGURATION**
  # Configures various hardware components.
  hardware = {
    # Bluetooth setup.
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Graphics tablet support.
    opentabletdriver.enable = true;

    # I2C bus support.
    i2c = {
      enable = true;
      group = "i2c"; # Assign I2C devices to the 'i2c' group.
    };
  };

  # **NETWORKING CONFIGURATION**
  # Manages network setup and firewall rules.
  networking = {
    networkmanager.enable = true; # Enable NetworkManager for network control.

    # Firewall configuration.
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ]; # Trust the loopback interface.
      allowedTCPPorts = [ 53317 22000 ]; # Syncthing TCP ports.
      allowedUDPPorts = [ 53317 21027 ]; # Syncthing UDP ports.
    };
  };

  # **LOCALIZATION**
  # Sets timezone and default locale.
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # **DISPLAY SERVER & DESKTOP ENVIRONMENT**
  # Configures graphical server and Wayland compositor.
  # X11 Server (required for SDDM).
  services.xserver = {
    enable = true;
    xkb.layout = "us"; # Set keyboard layout to US.
  };

  # Hyprland Wayland Compositor.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Enable XWayland for X11 compatibility.
    withUWSM = true; # Integrate with Universal Wayland Session Manager.
  };

  # Universal Wayland Session Manager.
  programs.uwsm.enable = true;

  # XDG Portal Configuration for Wayland applications.
  xdg = {
    mime.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland # Hyprland specific portal.
        xdg-desktop-portal-gtk # GTK applications portal.
        kdePackages.xdg-desktop-portal-kde # KDE applications portal.
      ];
    };
  };

  # Display Manager: SDDM for graphical login.
  services.displayManager.sddm.enable = true;

  # **AUDIO CONFIGURATION**
  # Sets up audio server and real-time priorities.
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true; # Enable 32-bit ALSA support.
    };
    pulse.enable = true; # Enable PulseAudio compatibility layer.
  };

  security.rtkit.enable = true; # Enable RTKit for real-time audio priorities.

  # **INPUT DEVICES**
  # Configures input device handling.
  services.libinput.enable = true; # Enable Libinput for touchpad and other input devices.

  # **USER CONFIGURATION**
  # Defines system users and their groups.
  users.users.popcat19 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "i2c" ]; # Add user to necessary groups.
  };

  systemd.tmpfiles.rules = [
    "d /home/popcat19 0755 popcat19 users -" # Ensure user home directory exists with correct permissions.
  ];

  # **SYSTEM SERVICES**
  # Manages various background services.
  services = {
    # Storage & File Management.
    udisks2.enable = true; # Disk management.
    flatpak.enable = true; # Flatpak package manager support.

    # Hardware Control.
    hardware.openrgb.enable = true; # OpenRGB for controlling RGB lighting.

    # File Synchronization.
    syncthing = {
      enable = true;
      user = "popcat19";
      group = "users";
      openDefaultPorts = true; # Open firewall ports for Syncthing.
      dataDir = "/home/popcat19/syncthing"; # Data directory for Syncthing.
      configDir = "/home/popcat19/.config/syncthing"; # Configuration directory.

      # Syncthing folder configurations.
      settings = {
        folders = {
          "keepass-vault" = {
            id = "keepass-vault";
            label = "KeePass Vault";
            path = "/home/popcat19/Passwords";
            devices = [ ]; # Devices to sync with (empty means no specific devices here).
            type = "sendreceive";
            rescanIntervalS = 60;
            ignorePerms = true; # Ignore file permissions during sync.
          };
        };
      };
    };
  };

  # **UDEV RULES**
  # Custom udev rules for device permissions.
  services.udev.extraRules = ''
    # Rule for i2c devices: assign to 'i2c' group with read/write permissions.
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    # Rule for Allwinner FEL mode: allow user access for flashing devices.
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
  '';

  # **VIRTUALIZATION**
  # Enables virtualization technologies.
  virtualisation.waydroid.enable = true; # Waydroid for Android containerization.

  # **PROGRAMS & APPLICATIONS**
  # Enables and configures various applications and program settings.
  programs = {
    # Browsers.
    firefox.enable = true;

    # Shells.
    fish.enable = true;

    # Gaming related programs.
    gamemode.enable = true; # GameMode for performance optimization.
    steam = {
      enable = true;
      gamescopeSession.enable = true; # Enable Gamescope session for Steam.
      remotePlay.openFirewall = true; # Open ports for Steam Remote Play.
      dedicatedServer.openFirewall = true; # Open ports for dedicated game servers.
      localNetworkGameTransfers.openFirewall = true; # Open ports for local game transfers.
    };

    # Development tools.
    java.enable = true; # Java runtime environment.
  };

  # **PACKAGE MANAGEMENT**
  # Nixpkgs configuration and Nix settings.
  nixpkgs.config.allowUnfree = true; # Allow installation of unfree packages.

  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ]; # Add Cachix binary cache.
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ]; # Public key for Cachix.
  };

  # **ENVIRONMENT VARIABLES**
  # Global session environment variables.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";           # Hint for Electron apps to use Wayland.
    WLR_NO_HARDWARE_CURSORS = "1";  # Cursor compatibility for Wayland compositors.
  };

  # **SYSTEM PACKAGES**
  # List of packages installed globally on the system.
  environment.systemPackages = with pkgs; [
    # -------------------------
    # Essential System Tools
    # -------------------------
    vim                             # Terminal text editor.
    micro                           # Modern terminal text editor.
    wget                            # Command-line file downloader.
    curl                            # Tool for transferring data with URLs.
    git                             # Distributed version control system.
    gh                              # GitHub CLI.

    # -------------------------
    # File Management
    # -------------------------
    ranger                          # Terminal file manager.
    superfile                       # Modern terminal file manager.
    xdg-utils                       # XDG desktop utilities.
    shared-mime-info                # Shared MIME type database.

    # -------------------------
    # Hardware Control
    # -------------------------
    i2c-tools                       # Utilities for I2C bus.
    ddcutil                         # Control display settings via DDC/CI.
    usbutils                        # USB utilities (lsusb, etc.).

    # -------------------------
    # Development Tools
    # -------------------------
    nodejs                          # JavaScript runtime.
    rocmPackages.rpp                # ROCm packages for AMD GPUs.
  ];

  # **FONTS CONFIGURATION**
  # Installs system-wide fonts.
  fonts.packages = with pkgs; [
    noto-fonts                      # Google Noto fonts.
    noto-fonts-cjk-sans             # CJK language support for Noto fonts.
    noto-fonts-emoji                # Emoji support for Noto fonts.
    font-awesome                    # Iconic font and CSS toolkit.
    nerd-fonts.jetbrains-mono       # JetBrains Mono font patched with Nerd Fonts.
  ];
}
