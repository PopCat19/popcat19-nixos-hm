{ config, pkgs, lib, ... }:

{
  # **DISTRIBUTED BUILDS SERVER CONFIGURATION**
  # Configures nixos0 to act as a build server for other machines
  
  # SSH server configuration for accepting build requests
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      # Allow multiple concurrent connections for parallel builds
      MaxSessions = 20;
      MaxStartups = "20:30:100";
    };
    # Ensure Nix is available in SSH sessions
    extraConfig = ''
      SetEnv PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    '';
  };

  # Open SSH port in firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Configure Nix for serving as a build machine
  nix.settings = {
    # Trust users that can perform builds
    trusted-users = [ "root" "popcat19" ];
    
    # Enable experimental features needed for flakes and distributed builds
    experimental-features = [ "nix-command" "flakes" ];
    
    # Configure substituters and trusted public keys
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    
    # Optimize for build server performance
    max-jobs = 12;  # R5 5500 6c/12t
    cores = 6;      # Physical cores
    
    # Allow building for other architectures if needed
    extra-platforms = [ "i686-linux" ];
  };

  # User configuration for SSH keys
  users.users.popcat19 = {
    openssh.authorizedKeys.keys = [
      # Public key from surface0 for distributed builds
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXoyiQly9JMgho/x4EWrLMYvnR7Az0lQNLFwsPyMNWP popcat19@surface0-for-nixos0"
    ];
  };

  # Environment packages needed for distributed builds
  environment.systemPackages = with pkgs; [
    openssh
    git  # Needed for flake operations
    # Additional build tools
    gcc
    binutils
    pkg-config
  ];

  # Optimize system for build performance
  boot.kernel.sysctl = {
    # Increase file descriptor limits for parallel builds
    "fs.file-max" = 2097152;
    # Optimize memory management for builds
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
  };

  # Increase user limits for build processes
  security.pam.loginLimits = [
    {
      domain = "popcat19";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "popcat19";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];
}