{ config, pkgs, lib, ... }:

{
  # Distributed builds configuration
  
  nix.distributedBuilds = true;
  
  # Configure build machines
  nix.buildMachines = [
    {
      hostName = "192.168.50.172";
      systems = [ "x86_64-linux" ];
      maxJobs = 12;
      speedFactor = 3;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
      sshUser = "popcat19";
      sshKey = "/home/popcat19/.ssh/id_ed25519";
    }
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    extraConfig = ''
      SetEnv PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    '';
  };

  # Open SSH port in firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Configure Nix for remote building
  nix.settings = {
    trusted-users = [ "root" "popcat19" ];
    experimental-features = [ "nix-command" "flakes" ];
    
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
      # Populated with public key from nixos0
    ];
  };

  # Environment packages
  environment.systemPackages = with pkgs; [
    openssh
    git
  ];
}