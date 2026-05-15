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

  nixConfig = {
    extra-substituters = [
      "https://popcat19-shared.cachix.org"
      "https://shimboot-systemd-nixos.cachix.org"
      "https://numtide.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
      "numtide.cachix.org-1:2ps1kLBUWnLAnBIRTV6l6hEQuv59S++4Nux7496Z6tw="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-gaming.url = "github:fufexan/nix-gaming";

    pmd = {
      url = "github:popcat19/project-minimalist-design/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    shimboot = {
      url = "github:PopCat19/nixos-shimboot/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lm-modal = {
      url = "github:PopCat19/lm-modal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
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
