# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  vaultDir = "/home/popcat19/Passwords";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = ["i2c-dev"];
    services.udev.extraRules = ''
      # Rule for i2c devices
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
      # Rule for Allwinner FEL mode to allow user access
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a", ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
    '';

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # HYPRLAND_NOTE: Sound setup with Pipewire, recommended for Wayland.
  # This replaces the previous commented pulseaudio and simpler pipewire config.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # For 32-bit applications
    pulse.enable = true;      # Provides PulseAudio compatibility
    # jack.enable = true;     # Enable if you need JACK support
  };
  security.rtkit.enable = true; # Recommended for Pipewire real-time priorities

  # waydroid
  virtualisation.waydroid.enable = true;

  # xdg
  xdg.mime.enable = true;

  # HYPRLAND_NOTE: Hyprland Wayland compositor and related XDG portal setup.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Enable XWayland for X11 applications
    # nvidiaPatches = true; # HYPRLAND_NOTE: Uncomment if you have an NVIDIA GPU
  };

  # Enable XDG Desktop Portal for Hyprland and other desktop integration.
  # This is crucial for features like screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk # For GTK apps
      kdePackages.xdg-desktop-portal-kde # HYPRLAND_NOTE: Uncomment if you use many KDE/Qt apps
    ];
  };

  # HYPRLAND_NOTE: Session variables for Wayland environment.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";         # Hint for Electron apps to use Wayland
    WLR_NO_HARDWARE_CURSORS = "1"; # Optional: if you have cursor issues, try "0" or remove
    # HYPRLAND_NOTE: For NVIDIA, you might need these if not using nvidiaPatches or if issues persist:
    # LIBVA_DRIVER_NAME = "nvidia";
    # XDG_SESSION_TYPE = "wayland";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # HYPRLAND_NOTE: Disable the main Xserver if Hyprland is your primary session.
  # Hyprland (via xwayland.enable = true above) will handle X11 apps.
  # If you want a separate X11 session option via a display manager,
  # you'd configure the display manager to offer both.
  # For a pure Hyprland setup, set this to false. SDDM requires this though.
  services.xserver.enable = true;

  # Configure keymap in X11
  # HYPRLAND_NOTE: This xkb.layout setting is for Xorg sessions.
  # Hyprland's keyboard layout is configured in its own ~/.config/hypr/hyprland.conf
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true; # HYPRLAND_NOTE: Replaced by the services.pipewire block above.
  # OR
  # services.pipewire = { # HYPRLAND_NOTE: This simpler block is replaced by the more complete one above.
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ];
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
users.users.popcat19 = {
  isNormalUser = true;
  extraGroups = [ "wheel" "video" "audio" "networkmanager" "i2c" ];
};

  programs.firefox.enable = true;
  programs.hyprland.withUWSM = true;
  programs.uwsm.enable = true;
  programs.fish.enable = true;
  programs.gamemode.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.java.enable = true; 


  nixpkgs.config.allowUnfree = true;

  # services.blueman.enable = true;
  services.flatpak.enable = true;
  services.hardware.openrgb.enable = true;

  services.syncthing = {
    enable = true;
    # user = "popcat19";
    openDefaultPorts = true;
    
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
  
  hardware.i2c.enable = true;
  hardware.i2c.group = "i2c";
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    micro
    ranger
    superfile
    git
    gh # HYPRLAND_NOTE: GitHub CLI, useful for managing your config repo
    # HYPRLAND_NOTE: Essential fonts for a graphical environment
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome # For icons in waybar, etc.
    nerd-fonts.jetbrains-mono
    # Add any other system-wide utilities you need
    i2c-tools
    ddcutil
    xdg-utils
    shared-mime-info
    nodejs
    rocmPackages.rpp
    usbutils
  ];

  # HYPRLAND_NOTE: Explicit font configuration for better discovery by applications.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
    # Add any other fonts you like and want to be system-discoverable
  ];

  # steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # HYPRLAND_NOTE: Optional: Display Manager (Graphical Login)
  # If you want to log in graphically and select Hyprland.
  # Otherwise, you can log in on a TTY and type `Hyprland`.
  # Make sure only one display manager is enabled if you use one.
  services.displayManager.sddm.enable = true; # Example: ensure others are off
  # services.displayManager.lightdm.enable = false; # Example: ensure others are off

  # Example with greetd (a lightweight greeter often used with tiling WMs)
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.hyprland}/bin/Hyprland";
  #       # HYPRLAND_NOTE: Make sure this user matches your actual username
  #       user = config.users.users.popcat19.name;
  #     };
  #   };
  #   # You can use various greeters with greetd, e.g., tuigreet (console) or wlgreet (Wayland)
  #   # package = pkgs.greetd.tuigreet; # For a TTY-like greeter
  #   # package = pkgs.wlgreet; # For a graphical Wayland greeter (needs wlgreet in systemPackages too)
  # };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.openssh.settings.PasswordAuthentication = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false; # HYPRLAND_NOTE: Enabling basic firewall below.
  # HYPRLAND_NOTE: Basic firewall, allowing all localhost traffic.
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "lo" ];
    allowedTCPPorts = [ 53317 22000 ]; # Add ports for specific services if needed
    allowedUDPPorts = [ 53317 21027 ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
