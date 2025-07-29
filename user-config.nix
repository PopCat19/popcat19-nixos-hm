# User Configuration File
# This file contains all user-configurable variables for the NixOS system.
# Modify these values to customize your system without editing multiple files.

{
  # **HOST CONFIGURATION**
  # Basic system parameters
  host = {
    # System architecture (x86_64-linux, aarch64-linux, etc.)
    system = "x86_64-linux";
    
    # Hostname for the system
    hostname = "popcat19-nixos0";
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
    };
  };
}