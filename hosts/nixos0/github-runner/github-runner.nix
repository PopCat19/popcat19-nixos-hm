{ config, pkgs, userConfig, lib, inputs, ... }:
{
  imports = [
    inputs.github-nix-ci.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  # Age configuration for agenix
  age.identityPaths = [ "/home/popcat19/.ssh/id_ed25519_builder" ];
  
  services.github-nix-ci = {
    # Secrets directory (use agenix for production)
    age.secretsDir = ./secrets;
    
    # Personal repository runners
    personalRunners = {
      "PopCat19/nixos-shimboot".num = 2;  # 2 concurrent runners for shimboot builds
      "PopCat19/popcat19-nixos-hm".num = 1; # 1 runner for personal config
    };
    
    # Optional: Organization runners
    # orgRunners = {
    #   "your-org".num = 5;
    # };
  };

  # Add Docker support (required for shimboot builds)
  virtualisation.docker.enable = true;
  
  # Ensure runner user is in docker group and has sudo access
  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
    extraGroups = [ "docker" "wheel" ];
  };
  
  users.groups.github-runner = {};

  # Keep normal behavior for other users
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true; # re-enable for your own user
    extraRules = [
      {
        users = [ "github-runner" ];
        commands = [ "ALL" ];
        options = [ "NOPASSWD" ];
      }
    ];
  };
}