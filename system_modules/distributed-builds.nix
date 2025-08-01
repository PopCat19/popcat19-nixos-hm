{ config, pkgs, lib, ... }:

{
  # **DISTRIBUTED BUILDS CONFIGURATION**
  # Enables using remote machines for building packages
  
  # Enable distributed builds
  nix.distributedBuilds = true;
  
  # Configure build machines
  nix.buildMachines = [
    {
      hostName = "192.168.50.172";
      systems = [ "x86_64-linux" ];
      maxJobs = 12;  # R5 5500 has 6c/12t, use all threads
      speedFactor = 3;  # R5 5500 with 32GB RAM is significantly faster than Surface
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
      sshUser = "popcat19";
      sshKey = "/home/popcat19/.ssh/id_ed25519";
    }
  ];

  # SSH configuration for distributed builds
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    # Ensure Nix is available in SSH sessions
    extraConfig = ''
      SetEnv PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    '';
  };

  # Open SSH port in firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Configure Nix for remote building
  nix.settings = {
    # Trust the build user for remote builds
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
  };

  # User configuration for SSH keys
  users.users.popcat19 = {
    openssh.authorizedKeys.keys = [
      # This will be populated with the public key from nixos0
      # For now, we'll add our own public key to allow self-connection testing
    ];
  };

  # Environment packages needed for distributed builds
  environment.systemPackages = with pkgs; [
    openssh
    git  # Needed for flake operations
  ];
}