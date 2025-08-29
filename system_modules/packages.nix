# System packages configuration

{ pkgs, userConfig, ... }:

let
  # Import architecture-specific modules
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";

  # Virtualization packages moved to system_modules/virtualisation.nix
  # See system_modules/virtualisation.nix for virtualization-related packages

  # Import categorized package modules
  networkPackages = import ../packages/system/network.nix { inherit pkgs; };
  hardwarePackages = import ../packages/system/hardware.nix { inherit pkgs; };
  guiPackages = import ../packages/system/gui.nix { inherit pkgs; };
  developmentPackages = import ../packages/system/development.nix { inherit pkgs; };
in
{
  # All packages are now organized in categorized modules
  environment.systemPackages = networkPackages
  ++ hardwarePackages
  ++ guiPackages
  ++ developmentPackages
  ++ x86_64Packages;
}
