# Global user configuration file
# Contains all user-configurable variables shared across NixOS hosts

{ hostname ? "popcat19-nixos0" }:

{
  # Host configuration
  host = {
    system = "x86_64-linux";
    inherit hostname;
  };

  # Architecture detection helpers
  arch = let
    current = "x86_64-linux";
  in rec {
    inherit current;
    
    # Architecture detection
    isX86_64 = current == "x86_64-linux";
    isAarch64 = current == "aarch64-linux";
    isArm = isAarch64;
    
    # Hardware capabilities
    supportsROCm = isX86_64;
    supportsVirtualization = true;
    supportsGaming = isX86_64;
    
    # Package preferences
    preferredVideoPlayer = "mpv";
    preferredTerminal = "kitty";
    
    # Helper functions
    onlyX86_64 = packages: if isX86_64 then packages else [];
    onlyAarch64 = packages: if isAarch64 then packages else [];
    
    selectByArch = { x86_64 ? null, aarch64 ? null, fallback ? null }:
      if isX86_64 && x86_64 != null then x86_64
      else if isAarch64 && aarch64 != null then aarch64
      else fallback;
  };

  # User credentials
  user = {
    username = "popcat19";
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
    ];
  };

  # Default applications
  defaultApps = {
    browser = {
      desktop = "zen-beta.desktop";
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
  directories = {
    home = "/home/popcat19";
    documents = "/home/popcat19/Documents";
    downloads = "/home/popcat19/Downloads";
    pictures = "/home/popcat19/Pictures";
    videos = "/home/popcat19/Videos";
    music = "/home/popcat19/Music";
    desktop = "/home/popcat19/Desktop";
    syncthing = "/home/popcat19/syncthing-shared";
  };

  # Network configuration
  network = {
    allowedTCPPorts = [
      22      # SSH
      53317   # Syncthing
      30071   # Custom port
    ];
    
    allowedUDPPorts = [
      53317   # Syncthing
    ];
    
    trustedInterfaces = [ "lo" ];
  };
}