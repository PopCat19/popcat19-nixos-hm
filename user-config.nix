# Global user configuration file
# Contains all user-configurable variables shared across NixOS hosts

{ hostname ? null, system ? "x86_64-linux", username ? "popcat19", machine ? "nixos0" }:

rec {
  # Host configuration
  host = {
    inherit system;
    hostname = if hostname == null then "${username}-${machine}" else hostname;
  };

  # Hosts metadata and helpers
  hosts = rec {
    # Machines defined under ./hosts/
    machines = [ "nixos0" "surface0" "thinkpad0" ];
    owner = username;
    defaultMachine = "nixos0";
    mk = m: "${owner}-${m}";
    isValid = m: builtins.elem m machines;
    # Selected machine (argument 'machine' may be overridden by callers)
    selectedMachine =
      if isValid machine then machine else defaultMachine;
    # Derived hostname for the selected machine
    derivedHostname = mk selectedMachine;
  };

  # Architecture detection helpers
  arch = let
    current = system;
  in rec {
    inherit current;

    # Architecture detection
    isX86_64 = current == "x86_64-linux";

    # Hardware capabilities
    supportsROCm = isX86_64;
    supportsVirtualization = isX86_64;
    supportsGaming = isX86_64;

    # Package preferences
    preferredVideoPlayer = "mpv";
    preferredTerminal = "kitty";

    # Helper functions
    onlyX86_64 = packages: if isX86_64 then packages else [];
  };

  # User credentials
  user = {
    inherit username;
    fullName = "PopCat19";
    email = "atsuo11111@gmail.com";
    shell = "fish";
    
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "i2c"
      "input"
      "libvirtd"
    ] ++ (if host.hostname == "${username}-surface0" then [ "surface-control" ] else []);
  };

  # Default applications
  defaultApps = {
    browser = {
      desktop = "zen-twilight.desktop";
      package = "zen-browser";
    };
    
    terminal = {
      desktop = "kitty.desktop";
      package = "kitty";
      command = "kitty";
    };
    
    editor = {
      desktop = "micro.desktop";
      package = "micro";
      command = "micro";
    };
    
    fileManager = {
      desktop = "org.kde.dolphin.desktop";
      package = "kdePackages.dolphin";
    };
    
    imageViewer = {
      desktop = "org.kde.gwenview.desktop";
      package = "kdePackages.gwenview";
    };
    
    videoPlayer = {
      desktop = "mpv.desktop";
      package = "mpv";
    };
    
    archiveManager = {
      desktop = "org.kde.ark.desktop";
      package = "kdePackages.ark";
    };
    
    pdfViewer = {
      desktop = "org.kde.okular.desktop";
      package = "kdePackages.okular";
    };
  };

  # System directories
  directories = let
    home = "/home/${username}";
  in {
    inherit home;
    documents = "${home}/Documents";
    downloads = "${home}/Downloads";
    pictures = "${home}/Pictures";
    videos = "${home}/Videos";
    music = "${home}/Music";
    desktop = "${home}/Desktop";
    syncthing = "${home}/syncthing-shared";
  };

  # Git configuration (used by home_modules/git.nix)
  git = {
    userName = user.fullName;
    userEmail = user.email;
    extraConfig = { };
  };

  # Network configuration moved to system_modules/networking.nix
  # Host-specific overrides may still set `network` in userConfig if needed.

}
