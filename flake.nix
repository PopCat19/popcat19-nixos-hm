# flake.nix
#
# Purpose: Main flake entry point for NixOS multi-host configuration
#
# This module:
# - Uses flake-parts for modular flake configuration
# - Imports flake modules from ./flake-modules/
# - Exposes NixOS configurations for all hosts
{
  description = "NixOS multi-host configuration with profile presets";

  inputs = {
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/jovian-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia-shell";

    niri.url = "github:sodiboo/niri-flake";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    pmd = {
      url = "github:popcat19/project-minimalist-design/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # libgbm is only available in unstable
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apollo = {
      url = "github:nil-andreas/apollo-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zrok = {
      url = "github:openziti/zrok/v1.1.10";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opentabletdriver = {
      url = "github:OpenTabletDriver/OpenTabletDriver";
      flake = false;
    };

    llama-cpp-src = {
      url = "github:ggml-org/llama.cpp/b8770";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    shimboot = {
      url = "path:/home/popcat19/nixos-shimboot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./flake-modules/nixos.nix
        ./flake-modules/formatter.nix
      ];
    };
}
