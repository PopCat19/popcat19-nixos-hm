# System packages configuration

{ pkgs, userConfig, ... }:

let
  # Import architecture-specific modules
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };
  aarch64Packages = import ./aarch64-packages.nix { inherit pkgs; };

  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";

  # Virtualization packages moved to system_modules/virtualisation.nix
  # See system_modules/virtualisation.nix for virtualization-related packages

in
{
  # Additional system packages
  environment.systemPackages = with pkgs; [
    # Network tools
    wireguard-tools

    # Hardware tools
    i2c-tools
    ddcutil
    usbutils
    util-linux
    e2fsprogs
    eza
    brightnessctl

    # GUI / launcher tools
    fuzzel

    # Development tools
    python313Packages.pip
    gh
    unzip
  ]
  ++ (if isX86_64 then x86_64Packages else [])
  ++ (if isAarch64 then aarch64Packages else []);
}
