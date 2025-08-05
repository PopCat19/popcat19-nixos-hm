{
  # Core Nixpkgs repository
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  # System extensions
  chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

  quickshell = {
    url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    # Mismatched system dependencies will lead to crashes
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Gaming-specific inputs
  aagl = {
    url = "github:ezKEa/aagl-gtk-on-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Application-specific inputs
  zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
    # to have it up-to-date or simply don't specify the nixpkgs input
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Home management
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Hardware-specific configurations
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  # Theming inputs
  rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
  catppuccin-nix = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}