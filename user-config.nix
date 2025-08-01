# Global User Configuration File
# This file contains all user-configurable variables shared across all NixOS hosts.
# Host-specific overrides can be applied in individual host configurations.

{ hostname ? "popcat19-nixos0" }:

{
  # **HOST CONFIGURATION**
  # Basic system parameters
  host = {
    # System architecture (x86_64-linux, aarch64-linux, etc.)
    system = "x86_64-linux";
    
    # Hostname for the system (can be overridden by hosts)
    inherit hostname;
  };

  # **ARCHITECTURE DETECTION HELPERS**
  # Helper functions for architecture-specific configurations
  # Note: These functions use the host.system value defined above
  arch = let
    # Current system architecture (references host.system)
    current = "x86_64-linux"; # This will be dynamically set by the flake
  in rec {
    inherit current;
    
    # Architecture detection functions
    isX86_64 = current == "x86_64-linux";
    isAarch64 = current == "aarch64-linux";
    isArm = isAarch64; # Alias for ARM64
    
    # Hardware capability detection
    supportsROCm = isX86_64; # ROCm is primarily x86_64
    supportsVirtualization = true; # Both architectures support virtualization
    supportsGaming = isX86_64; # Most gaming software is x86_64 only
    
    # Architecture-specific package preferences
    preferredVideoPlayer = if isX86_64 then "mpv" else "mpv"; # Both work well
    preferredTerminal = "kitty"; # Works on both architectures
    
    # Helper function to conditionally include packages based on architecture
    onlyX86_64 = packages: if isX86_64 then packages else [];
    onlyAarch64 = packages: if isAarch64 then packages else [];
    
    # Helper function to select package based on architecture
    selectByArch = { x86_64 ? null, aarch64 ? null, fallback ? null }:
      if isX86_64 && x86_64 != null then x86_64
      else if isAarch64 && aarch64 != null then aarch64
      else fallback;
  };

  # **USER CREDENTIALS**
  # User account and personal information
  user = {
    # Primary username
    username = "popcat19";
    
    # User's full name for Git and other applications
    fullName = "PopCat19";
    
    # User's email address
    email = "atsuo11111@gmail.com";
    
    # User's shell (will be resolved to package in users.nix)
    shell = "fish";
    
    # Additional user groups
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

  # **DEFAULT APPLICATIONS**
  # MIME type associations and default applications
  defaultApps = {
    # Web browser
    browser = {
      desktop = "zen-beta.desktop";
      package = "zen-browser"; # Package name for installation
    };
    
    # Terminal emulator
    terminal = {
      desktop = "kitty.desktop";
      package = "kitty";
      command = "kitty"; # Command to run terminal
    };
    
    # Text editor
    editor = {
      desktop = "micro.desktop";
      package = "micro";
      command = "micro";
    };
    
    # File manager
    fileManager = {
      desktop = "org.kde.dolphin.desktop";
      package = "kdePackages.dolphin";
    };
    
    # Image viewer
    imageViewer = {
      desktop = "org.kde.gwenview.desktop";
      package = "kdePackages.gwenview";
    };
    
    # Video player
    videoPlayer = {
      desktop = "mpv.desktop";
      package = "mpv";
    };
    
    # Archive manager
    archiveManager = {
      desktop = "org.kde.ark.desktop";
      package = "kdePackages.ark";
    };
    
    # PDF viewer
    pdfViewer = {
      desktop = "org.kde.okular.desktop";
      package = "kdePackages.okular";
    };
  };

  # **SYSTEM DIRECTORIES**
  # Common directory paths that may be referenced
  directories = {
    # User home directory (derived from username)
    home = "/home/popcat19";
    
    # Common user directories
    documents = "/home/popcat19/Documents";
    downloads = "/home/popcat19/Downloads";
    pictures = "/home/popcat19/Pictures";
    videos = "/home/popcat19/Videos";
    music = "/home/popcat19/Music";
    desktop = "/home/popcat19/Desktop";
    syncthing = "/home/popcat19/syncthing-shared";
  };

  # **NETWORK CONFIGURATION**
  # Network-related settings
  network = {
    # Firewall ports to open
    allowedTCPPorts = [
      53317  # Syncthing
      30071  # Custom port
    ];
    
    allowedUDPPorts = [
      53317  # Syncthing
    ];
    
    # Trusted network interfaces
    trustedInterfaces = [ "lo" ];
  };

  # **GIT CONFIGURATION**
  # Git-specific settings
  git = {
    # Git user name (can be different from system username)
    userName = "PopCat19";
    
    # Git email
    userEmail = "atsuo11111@gmail.com";
    
    # Additional git configuration can be added here
    extraConfig = {
      # Example: init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}