# images.nix
#
# Purpose: One-shot installed-system images for hosts
#
# This module:
# - Builds raw-EFI disk images for x86_64 hosts that can be `dd`ed to a USB drive
#   or SSD and booted as the installed system (no separate install step).
# - Exposes the Klipper Pi SD card image as a flake package.
#
# dedede0 is intentionally excluded: it is a ChromeOS shimboot device and must
# use the custom shimboot image from nixos-shimboot, not a generic EFI disk image.
{
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  hostsDir = ../configuration/hosts;

  x86_64ImageHosts = [
    "popcat19-nixos0"
    "popcat19-surface0"
    "popcat19-thinkpad0"
  ];

  overlaysFor = system: import ./overlays.nix { inherit inputs system; };

  mkDiskImageConfig =
    hostName:
    let
      hostPath = hostsDir + "/${hostName}";
      userConfig = import (hostPath + "/user-config.nix") { inherit lib; };
      inherit (userConfig) system;
      pkgs = import inputs.nixpkgs { inherit system; };

      nixosConfig = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs userConfig;
        };
        modules = [
          # Full host config. The image builder overrides the target disk layout.
          (hostPath + "/configuration.nix")

          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default
          ../configuration/system/modules/agenix.nix

          { nixpkgs.overlays = overlaysFor system; }

          # Raw disk image builder (raw-efi = GPT with ESP + ext4 rootfs).
          "${inputs.nixpkgs}/nixos/modules/image/images.nix"

          {
            # Neutralise host-specific disk UUIDs and replace with the labels the
            # image builder creates. This makes the image portable across machines.
            fileSystems."/" = lib.mkImageMediaOverride {
              device = "/dev/disk/by-label/nixos";
              autoResize = true;
              fsType = "ext4";
            };
            fileSystems."/boot" = lib.mkImageMediaOverride {
              device = "/dev/disk/by-label/ESP";
              fsType = "vfat";
            };
            swapDevices = lib.mkImageMediaOverride [ ];

            # Keep systemd-boot but do not touch firmware variables during image build.
            boot.loader.systemd-boot.enable = lib.mkDefault true;
            boot.loader.grub.enable = lib.mkForce false;
            boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

            # Use the host's full home config (with host-specific files).
            home-manager.useGlobalPkgs = lib.mkForce false;
            home-manager.useUserPackages = lib.mkForce true;
            home-manager.sharedModules = lib.mkForce [
              inputs.nixcord.homeModules.nixcord
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = overlaysFor system;
              }
            ];
            home-manager.extraSpecialArgs = lib.mkForce {
              hostPlatform = system;
              inherit inputs userConfig;
            };
            home-manager.users.${userConfig.username} = lib.mkForce (import (hostPath + "/home.nix"));
          }
        ];
      };

      rawEfi = nixosConfig.config.system.build.images.raw-efi;

      compressed =
        pkgs.runCommand "disk-${hostName}-zst"
          {
            nativeBuildInputs = [ pkgs.zstd ];
          }
          ''
            mkdir -p "$out"
            img=$(find ${rawEfi} -maxdepth 1 -name '*.img' -type f | head -n1)
            if [ -z "$img" ]; then
              echo "ERROR: no .img file found in ${rawEfi}" >&2
              exit 1
            fi
            zstd -T0 -19 < "$img" > "$out/disk-${hostName}.img.zst"
          '';
    in
    {
      raw = rawEfi;
      inherit compressed;
    };
in
{
  flake.packages.x86_64-linux = lib.listToAttrs (
    lib.concatMap (
      hostName:
      let
        images = mkDiskImageConfig hostName;
      in
      [
        (lib.nameValuePair "disk-${hostName}" images.raw)
        (lib.nameValuePair "disk-${hostName}-zst" images.compressed)
      ]
    ) x86_64ImageHosts
  );

  flake.packages.aarch64-linux = {
    sd-popcat19-klipper0 =
      inputs.self.nixosConfigurations.popcat19-klipper0.config.system.build.sdImage;
  };
}
