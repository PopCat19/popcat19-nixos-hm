# Home Manager package configuration

{
  pkgs,
  inputs,
  system,
  userConfig,
}:

let
  # Import architecture-specific modules
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };
  aarch64Packages = import ./aarch64-packages.nix { inherit pkgs; };

  # Architecture detection
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";

  # Select appropriate packages based on architecture
  archSpecificPackages = if isX86_64 then x86_64Packages else aarch64Packages;

  # Import categorized package modules
  terminalPackages = import ../packages/home/terminal.nix { inherit pkgs; };
  browserPackages = import ../packages/home/browsers.nix { inherit pkgs; };
  mediaPackages = import ../packages/home/media.nix { inherit pkgs; };
  hyprlandPackages = import ../packages/home/hyprland.nix { inherit pkgs; };
  communicationPackages = import ../packages/home/communication.nix { inherit pkgs; };
  monitoringPackages = import ../packages/home/monitoring.nix { inherit pkgs; };
  utilityPackages = import ../packages/home/utilities.nix { inherit pkgs; };
  notificationPackages = import ../packages/home/notifications.nix { inherit pkgs; };
  editorPackages = import ../packages/home/editors.nix { inherit pkgs; };
  developmentPackages = import ../packages/home/development.nix { inherit pkgs; };
in
terminalPackages ++
browserPackages ++
mediaPackages ++
hyprlandPackages ++
communicationPackages ++
archSpecificPackages ++
monitoringPackages ++
utilityPackages ++
notificationPackages ++
editorPackages ++
developmentPackages
