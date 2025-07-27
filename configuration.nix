# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

{
  ################################
  # IMPORTS / STATE VERSION
  ################################
  imports = [ ./hardware-configuration.nix ];

  # WARNING: DO NOT CHANGE AFTER INITIAL INSTALL.
  system.stateVersion = "24.11";

  ################################
  # BOOT & KERNEL
  ################################
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "i2c-dev" ];
  };

  ################################
  # HARDWARE
  ################################
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    opentabletdriver.enable = true;
    i2c = {
      enable = true;
      group = "i2c";
    };
  };

  ################################
  # NETWORKING & FIREWALL
  ################################
  networking = {
    hostName = "popcat19-nixos0";
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ];
      allowedTCPPorts = [
        53317
        22000
        8384
        30071
      ]; # 22000=Syncthing
      allowedUDPPorts = [
        53317
        22000
        21027
      ]; # 22xxx/21027=Syncthing
      checkReversePath = false;
    };
  };

  ################################
  # LOCALIZATION & CLOCK
  ################################
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  ################################
  # JOURNALD
  ################################
  services.journald.extraConfig = ''
    # Rotate after 3 days
    MaxRetentionSec=3day
    # Size & free-space limits
    SystemMaxUse=500M
    SystemKeepFree=100M
    Compress=yes
    # Do not forward
    ForwardToSyslog=no
    ForwardToWall=no
  '';

  ################################
  # DISPLAY STACK
  ################################
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  security.polkit.enable = true;

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
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };

  services.displayManager.sddm = {
    enable = true;
    settings.Theme = {
      CursorTheme = "rose-pine-hyprcursor";
      CursorSize = "24";
    };
  };

  services.dbus.enable = true;
  programs.dconf.enable = true;

  ################################
  # AUDIO
  ################################
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  ################################
  # INPUT
  ################################
  services.libinput.enable = true;

  ################################
  # USERS & TMPFILES
  ################################
  users.users.popcat19 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "i2c"
      "input"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  systemd.tmpfiles.rules = [
    "d /home/popcat19            0755 popcat19 users -"
    "d /home/popcat19/Videos     0755 popcat19 users -"
    "d /home/popcat19/Music      0755 popcat19 users -"
  ];

  ################################
  # SERVICES
  ################################
  services = {
    # Storage / Packaging
    udisks2.enable = true;
    flatpak.enable = true;

    # Hardware
    hardware.openrgb.enable = true;

    # Game streaming
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings.output_name = "1";
    };

    # Sync
    syncthing = {
      enable = true;
      user = "popcat19";
      group = "users";
      openDefaultPorts = true;
      dataDir = "/home/popcat19/.local/share/syncthing";
      configDir = "/home/popcat19/.config/syncthing";
      settings = {
        devices = {
          "remote-device" = {
            id = "QP7SCT2-7XQTOK3-WTTSZ5T-T6BH4EZ-IA7VEIQ-RUQO5UV-FWWRF5L-LDQXTAS";
            name = "Remote Device";
            addresses = [ "dynamic" ];
          };
        };
        folders = {
          keepass-vault = {
            id = "keepass-vault";
            label = "KeePass Vault";
            path = "/home/popcat19/Passwords";
            devices = [ "remote-device" ];
            type = "sendreceive";
            rescanIntervalS = 60;
            ignorePerms = true;
          };
          syncthing-shared = {
            id = "syncthing-shared";
            label = "Syncthing Shared";
            path = "/home/popcat19/syncthing-shared";
            devices = [ "remote-device" ];
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

  ################################
  # UDEV RULES
  ################################
  services.udev.extraRules = ''
    # i2c devices
    KERNEL=="i2c-[0-9]*"             , GROUP="i2c",   MODE="0660"
    # Allwinner FEL
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a" , ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
    # Game controllers for Sunshine
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0664"
    KERNEL=="js*"     , SUBSYSTEM=="input", GROUP="input", MODE="0664"
  '';

  ################################
  # VIRTUALISATION
  ################################
  virtualisation = {
    waydroid.enable = true;
    docker.enable = true;
    libvirtd.enable = true;
    libvirtd.qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  ################################
  # PROGRAMS
  ################################
  programs = {
    fish = {
      enable = true;
      shellInit = ''
        set -g fish_greeting ""
        function fish_greeting; end
      '';
      interactiveShellInit = ''
        starship init fish | source
      '';
    };

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
          conflicted = "✗";
          ahead = "↑";
          behind = "↓";
          untracked = "?";
          modified = "!";
          staged = "+";
          deleted = "-";
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
          symbol = "";
          style = "bold iris";
          impure_msg = "";
          pure_msg = "pure";
        };
      };
    };

    gamemode.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  ################################
  # PACKAGE/MANAGEMENT/ENVIRONMENT
  ################################
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ];
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
    GDK_PIXBUF_MODULE_FILE = "/run/current-system/sw/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

    TERMINAL = "kitty";
    EDITOR = "micro";
    VISUAL = "micro";
    BROWSER = "zen-beta";
    FILECHOOSER = "dolphin";

    NIXOS_CONFIG_DIR = "/home/popcat19/nixos-config";
    NIXOS_FLAKE_HOSTNAME = "popcat19-nixos0";
  };

  environment.systemPackages = with pkgs; [
    vim
    micro
    wget
    curl
    git
    flatpak-builder
    protonvpn-gui
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    i2c-tools
    python313Packages.pip
    xdg-utils
    rocmPackages.rpp
    quickgui
    gh
    fuse
    libvirt
    qemu
    shared-mime-info
    wireguard-tools
    starship
    quickemu
    ddcutil
    usbutils
  ];

  ################################
  # FONTS
  ################################
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    noto-fonts-extra
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [
        "Rounded Mplus 1c Medium"
        "Noto Serif"
      ];
      sansSerif = [
        "Rounded Mplus 1c Medium"
        "Noto Sans"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
