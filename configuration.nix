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

    # Kernel parameters for optimized network performance (Syncthing UDP buffers).
    kernel.sysctl = {
      "net.core.rmem_max" = 7340032;  # Maximum receive buffer size (7MB)
      "net.core.wmem_max" = 7340032;  # Maximum send buffer size (7MB)
      "net.core.rmem_default" = 262144; # Default receive buffer size (256KB)
      "net.core.wmem_default" = 262144; # Default send buffer size (256KB)

      # MT7921E driver stabilization parameters
      "net.ipv4.tcp_keepalive_time" = 600;  # Faster keepalive for stability
      "net.ipv4.tcp_keepalive_intvl" = 30;  # More frequent keepalive checks
      "net.ipv4.tcp_keepalive_probes" = 8;  # More probes before giving up

      # Disable power management for MT7921E
      "net.core.default_qdisc" = "fq";  # Fair queuing for better stability
    };

    # Kernel boot parameters for MT7921E stability
    kernelParams = [
      "pcie_aspm=off"           # Disable PCIe Active State Power Management
      "mt7921e.disable_aspm=1"  # Disable ASPM for MT7921E specifically
      "iwlwifi.power_save=0"    # Disable WiFi power saving (fallback)
    ];
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
    hostName = "popcat19-nixos0"; # Set hostname to match flake.nix
    networkmanager = {
      enable = true; # Enable NetworkManager for network control.
      wifi.powersave = false;  # Disable WiFi power saving for stability
      wifi.backend = "wpa_supplicant";  # Ensure wpa_supplicant backend
    };

    # Firewall configuration.
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ]; # Trust the loopback interface.
      allowedTCPPorts = [ 53317 22000 8384 30071 ]; # Syncthing TCP ports.
      allowedUDPPorts = [ 53317 22000 21027 ]; # Syncthing UDP ports.
      checkReversePath = false;
    };
  };

  # **LOCALIZATION**
  # Sets timezone and default locale.
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # **JOURNALD CONFIGURATION**
  # Configure systemd-journald for 3-day log retention
  services.journald.extraConfig = ''
    # Automatically rotate logs after 3 days
    MaxRetentionSec=3day

    # Limit journal size to prevent excessive disk usage
    SystemMaxUse=500M
    SystemKeepFree=100M

    # Compress archived journals
    Compress=yes

    # Forward to syslog (disabled to reduce duplication)
    ForwardToSyslog=no
    ForwardToWall=no
  '';

  # **DISPLAY SERVER & DESKTOP ENVIRONMENT**
  # Configures graphical server and Wayland compositor.
  # X11 Server (required for SDDM).
  services.xserver = {
    enable = true;
    xkb.layout = "us"; # Set keyboard layout to US.
  };

  # Allow XDG autostart if no desktop manager is selected (kept for compatibility with SDDM/Hyprland)
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  # Polkit for authentication and theme support
  security.polkit.enable = true;

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
  services.displayManager.sddm = {
    enable = true;
    settings = {
      Theme = {
        CursorTheme = "rose-pine-hyprcursor";
        CursorSize = "24";
      };
    };
  };

  # Additional services for theme support
  services.dbus.enable = true;
  programs.dconf.enable = true;

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
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "i2c" "input" "libvirtd" ]; # Add user to necessary groups.
    shell = pkgs.fish; # Set Fish as default shell.
  };

  systemd.tmpfiles.rules = [
    "d /home/popcat19 0755 popcat19 users -" # Ensure user home directory exists with correct permissions.
    "d /home/popcat19/Videos 0755 popcat19 users -" # Create Videos directory
    "d /home/popcat19/Music 0755 popcat19 users -" # Create Music directory
  ];

  # **SYSTEM SERVICES**
  # Manages various background services.
  services = {
    # Storage & File Management.
    udisks2.enable = true; # Disk management.
    flatpak.enable = true; # Flatpak package manager support.

    # Hardware Control.
    hardware.openrgb.enable = true; # OpenRGB for controlling RGB lighting.

    # Game Streaming.
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # Required for Wayland support
      openFirewall = true; # Automatically open required firewall ports
      settings = {
        output_name = "1"; # Select MSI monitor (Monitor 1 from KMS list)
      };
    };

    # OpenVPN Configuration.
    openvpn.servers = {
      vpngateJapan = {
        config = '' config /root/nixos/openvpn/vpngate-japan-udp.conf '';
        updateResolvConf = true;
      };
    };

    # File Synchronization.
    syncthing = {
      enable = true;
      user = "popcat19";
      group = "users";
      openDefaultPorts = true; # Open firewall ports for Syncthing.
      dataDir = "/home/popcat19/.local/share/syncthing"; # Data directory for Syncthing.
      configDir = "/home/popcat19/.config/syncthing"; # Configuration directory.

      # Syncthing folder and device configurations.
      settings = {
        devices = {
          "remote-device" = {
            id = "QP7SCT2-7XQTOK3-WTTSZ5T-T6BH4EZ-IA7VEIQ-RUQO5UV-FWWRF5L-LDQXTAS";
            name = "Remote Device";
            addresses = [ "dynamic" ];
          };
        };
        folders = {
          "keepass-vault" = {
            id = "keepass-vault";
            label = "KeePass Vault";
            path = "/home/popcat19/Passwords";
            devices = [ "remote-device" ]; # Share with the remote device.
            type = "sendreceive";
            rescanIntervalS = 60;
            ignorePerms = true; # Ignore file permissions during sync.
          };
          "syncthing-shared" = {
            id = "syncthing-shared";
            label = "Syncthing Shared";
            path = "/home/popcat19/syncthing-shared";
            devices = [ "remote-device" ]; # Share with the remote device.
            type = "sendreceive";
            rescanIntervalS = 300;
            ignorePerms = true;
          };
        };
        options = {
          globalAnnounceEnabled = true;
          localAnnounceEnabled = true;
          relaysEnabled = true;
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
    # Game controller rules for Sunshine
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0664"
    KERNEL=="js*", SUBSYSTEM=="input", GROUP="input", MODE="0664"
    # PlayStation controllers
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", GROUP="input", MODE="0664"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", GROUP="input", MODE="0664"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", GROUP="input", MODE="0664"
  '';

  # **VIRTUALIZATION**
  # Enables virtualization technologies.
  virtualisation = {
    waydroid.enable = true; # Waydroid for Android containerization.
    docker.enable = true;

    # Add KVM/QEMU support
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # **PROGRAMS & APPLICATIONS**
  # Enables and configures various applications and program settings.
  programs = {
    # Browsers moved to user-level (home-manager)
    # firefox.enable = true;

    # Shells (must stay system-level for login shell)
    fish = {
      enable = true;
      shellInit = ''
        set -g fish_greeting "" # Disable default fish greeting.

        # Custom greeting disabled - fastfetch removed
        function fish_greeting
            # Empty greeting
        end
      '';
      interactiveShellInit = ''
        # Initialize Starship prompt for interactive shells
        starship init fish | source
      '';
    };

    # Starship prompt configuration (system-wide for all users)
    starship = {
      enable = true;
      settings = {
        format = "$all$character";
        palette = "rose_pine";

        palettes.rose_pine = {
          base = "#191724";
          surface = "#1f1d2e";
          overlay = "#26233a";
          muted = "#6e6a86";
          subtle = "#908caa";
          text = "#e0def4";
          love = "#eb6f92";
          gold = "#f6c177";
          rose = "#ebbcba";
          pine = "#31748f";
          foam = "#9ccfd8";
          iris = "#c4a7e7";
        };

        character = {
          success_symbol = "[❯](bold foam)";
          error_symbol = "[❯](bold love)";
          vimcmd_symbol = "[❮](bold iris)";
        };

        directory = {
          style = "bold iris";
          truncation_length = 3;
          format = "[$path]($style)[$read_only]($read_only_style) ";
          read_only = " 󰌾";
          read_only_style = "love";
        };

        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = " ";
          style = "bold pine";
        };

        git_status = {
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
          style = "bold rose";
          conflicted = "=";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          untracked = "?\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          deleted = "✘\${count}";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          style = "bold gold";
          min_time = 2000;
        };

        username = {
          show_always = false;
          format = "[$user]($style)@";
          style_user = "bold text";
          style_root = "bold love";
        };

        nix_shell = {
          format = "[$symbol$state]($style) ";
          symbol = " ";
          style = "bold iris";
        };
      };
    };

    # Gaming related programs (system-level for hardware access)
    gamemode.enable = true; # GameMode for performance optimization.
    steam = {
      enable = true;
      gamescopeSession.enable = true; # Enable Gamescope session for Steam.
      remotePlay.openFirewall = true; # Open ports for Steam Remote Play.
      dedicatedServer.openFirewall = true; # Open ports for dedicated game servers.
      localNetworkGameTransfers.openFirewall = true; # Open ports for local game transfers.
    };

    # Development tools moved to user-level (home-packages.nix)
    # java.enable = true;
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
    # Thumbnail generation support
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
    # GTK thumbnail support
    GDK_PIXBUF_MODULE_FILE = "/run/current-system/sw/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    # Default applications
    TERMINAL = "kitty";
    EDITOR = "micro";
    VISUAL = "micro";
    BROWSER = "zen-beta";
    # Fish and NixOS configuration
    NIXOS_CONFIG_DIR = "/home/popcat19/nixos-config";
    NIXOS_FLAKE_HOSTNAME = "popcat19-nixos0";
  };

  # **SYSTEM PACKAGES**
  # List of packages installed globally on the system.
  environment.systemPackages = with pkgs; [
    # Core system tools (must stay system-level)
    vim
    micro
    wget
    curl
    git
    gh                                 # GitHub CLI (needed for git operations)
    xdg-utils
    shared-mime-info

    # Shell tools (needed for system-wide access)
    starship                           # Shell prompt (available for root)

    # Hardware tools (require system-level access)
    i2c-tools
    ddcutil
    usbutils
    rocmPackages.rpp

    # virtualisation
    qemu                               # Virtualization
    libvirt                            # Virtualization platform
    virt-manager                       # Virtual machine manager
    virt-viewer                        # VM display viewer
    spice-gtk                          # SPICE client
    win-virtio                         # Windows VirtIO drivers
    win-spice                          # Windows SPICE guest tools
    quickemu                           # Quick virtualization
    quickgui                           # Quick virtualization GUI

    # VPNs
    wireguard-tools
    protonvpn-gui

    fuse
    python313Packages.pip
    docker
    flatpak-builder

    # User applications moved to home-packages.nix:
    # - ranger, superfile (file managers)
    # - nodejs (development tool)
    # - grim, slurp, wl-clipboard (screenshot tools)
  ];

  # **FISH CONFIGURATION**
  # Fish is configured at system level for basic functionality
  # Functions and abbreviations are handled by home-manager

  # **FONTS CONFIGURATION**
  # Installs system-wide fonts with comprehensive CJK support.
  fonts.packages = with pkgs; [
    # Core Noto fonts family
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    noto-fonts-extra

    # Google Fonts moved to user-level (home-theme.nix) for testing
    # google-fonts

    # Essential fonts moved to user-level (home-theme.nix)
    # font-awesome - now in home-theme.nix
    # nerd-fonts.jetbrains-mono - now in home-theme.nix
  ];

  # **FONTS FONTCONFIG**
  # Configure default system fonts with Rounded Mplus 1c as primary
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Rounded Mplus 1c Medium" "Noto Serif" ];
      sansSerif = [ "Rounded Mplus 1c Medium" "Noto Sans" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };


}
