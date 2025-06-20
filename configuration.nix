# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # SYSTEM CONFIGURATION
  # ============================================================================
  
  system.stateVersion = "24.11"; # Did you read the comment?

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================
  
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "i2c-dev" ];
  };

  # ============================================================================
  # HARDWARE CONFIGURATION
  # ============================================================================
  
  hardware = {
    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    
    # Graphics Tablet
    opentabletdriver.enable = true;
    
    # I2C Support
    i2c = {
      enable = true;
      group = "i2c";
    };
  };

  # ============================================================================
  # NETWORKING CONFIGURATION
  # ============================================================================
  
  networking = {
    networkmanager.enable = true;
    
    # Firewall Configuration
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ];
      allowedTCPPorts = [ 53317 22000 ]; # Syncthing ports
      allowedUDPPorts = [ 53317 21027 ]; # Syncthing ports
    };
  };

  # ============================================================================
  # LOCALIZATION
  # ============================================================================
  
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ============================================================================
  # DISPLAY SERVER & DESKTOP ENVIRONMENT
  # ============================================================================
  
  # X11 Server (required for SDDM)
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  # Hyprland Wayland Compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Universal Wayland Session Manager
  programs.uwsm.enable = true;

  # XDG Portal Configuration
  xdg = {
    mime.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde
      ];
    };
  };

  # Display Manager
  services.displayManager.sddm.enable = true;

  # ============================================================================
  # AUDIO CONFIGURATION
  # ============================================================================
  
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
  
  security.rtkit.enable = true; # Real-time audio priorities

  # ============================================================================
  # INPUT DEVICES
  # ============================================================================
  
  services.libinput.enable = true; # Touchpad support

  # ============================================================================
  # USER CONFIGURATION
  # ============================================================================
  
  users.users.popcat19 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "i2c" ];
  };

  systemd.tmpfiles.rules = [
    "d /home/popcat19 0755 popcat19 users -"
  ];

  # ============================================================================
  # SYSTEM SERVICES
  # ============================================================================
  
  services = {
    # Storage & File Management
    udisks2.enable = true;
    flatpak.enable = true;
    
    # Hardware Control
    hardware.openrgb.enable = true;
    
    # File Synchronization
    syncthing = {
      enable = true;
      user = "popcat19";
      group = "users";
      openDefaultPorts = true;
      dataDir = "/home/popcat19/syncthing";
      configDir = "/home/popcat19/.config/syncthing";
      
      settings = {
        folders = {
          "keepass-vault" = {
            id = "keepass-vault";
            label = "KeePass Vault";
            path = "/home/popcat19/Passwords";
            devices = [ ];
            type = "sendreceive";
            rescanIntervalS = 60;
            ignorePerms = true;
          };
        };
      };
    };
  };

  # ============================================================================
  # UDEV RULES
  # ============================================================================
  
  services.udev.extraRules = ''
    # Rule for i2c devices
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    # Rule for Allwinner FEL mode to allow user access
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
  '';

  # ============================================================================
  # VIRTUALIZATION
  # ============================================================================
  
  virtualisation.waydroid.enable = true;

  # ============================================================================
  # PROGRAMS & APPLICATIONS
  # ============================================================================
  
  programs = {
    # Browsers
    firefox.enable = true;
    
    # Shells
    fish.enable = true;
    
    # Gaming
    gamemode.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    
    # Development
    java.enable = true;
  };

  # ============================================================================
  # PACKAGE MANAGEMENT
  # ============================================================================
  
  nixpkgs.config.allowUnfree = true;
  
  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ];
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================
  
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";           # Hint for Electron apps to use Wayland
    WLR_NO_HARDWARE_CURSORS = "1";  # Cursor compatibility
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  
  environment.systemPackages = with pkgs; [
    # -------------------------
    # Essential System Tools
    # -------------------------
    vim                             # Text editor
    micro                           # Modern text editor
    wget                            # File downloader
    curl                            # HTTP client
    git                             # Version control
    gh                              # GitHub CLI
    
    # -------------------------
    # File Management
    # -------------------------
    ranger                          # Terminal file manager
    superfile                       # Modern file manager
    xdg-utils                       # XDG utilities
    shared-mime-info                # MIME type database
    
    # -------------------------
    # Hardware Control
    # -------------------------
    i2c-tools                       # I2C device tools
    ddcutil                         # Display control utility
    usbutils                        # USB utilities
    
    # -------------------------
    # Development Tools
    # -------------------------
    nodejs                          # JavaScript runtime
    rocmPackages.rpp                # ROCm packages
  ];

  # ============================================================================
  # FONTS CONFIGURATION
  # ============================================================================
  
  fonts.packages = with pkgs; [
    noto-fonts                      # Google Noto fonts
    noto-fonts-cjk-sans            # CJK language support
    noto-fonts-emoji                # Emoji support
    font-awesome                    # Icon font
    nerd-fonts.jetbrains-mono       # Nerd Fonts variant
  ];
}
