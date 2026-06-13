# images.nix
#
# Purpose: One-shot installed-system images with the flake source baked in
#
# This module:
# - Builds raw-EFI disk images for x86_64 hosts that can be `dd`ed to a USB drive
#   or SSD and booted as the installed system (no separate install step).
# - Injects the flake source into /home/<user>/popcat19-nixos-hm on the image so
#   `nixos-rebuild switch --flake .` works immediately after first boot.
# - Exposes the Klipper Pi SD card image with the flake source baked in.
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
  repoName = "popcat19-nixos-hm";

  x86_64ImageHosts = [
    "popcat19-nixos0"
    "popcat19-surface0"
    "popcat19-thinkpad0"
  ];

  overlaysFor = system: import ./overlays.nix { inherit inputs system; };

  # Files to inject into /home/<user>/<repoName>/ on the target image.
  flakeSource = inputs.self;

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

            # Pin the user UID/GID so files injected at build time match ownership.
            users.users.${userConfig.username}.uid = 1000;
            users.groups.users.gid = lib.mkDefault 100;

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

      # Post-process the raw disk image to inject the flake source into the
      # user's home directory. We use debugfs + fakeroot (no loop mount) so the
      # operation stays inside a Nix derivation without root privileges.
      withFlakeSource = pkgs.stdenv.mkDerivation {
        name = "disk-${hostName}-with-flake";
        dontUnpack = true;
        nativeBuildInputs = with pkgs; [
          e2fsprogs
          gptfdisk
          util-linux
          fakeroot
        ];
        NIXOS_FLAKE_SRC = "${flakeSource}";
        NIXOS_REPO_NAME = repoName;
        NIXOS_USERNAME = userConfig.username;
        buildPhase = ''
          runHook preBuild

          rawImage=$(find ${rawEfi} -maxdepth 1 -name '*.img' -type f | head -n1)
          if [ -z "$rawImage" ]; then
            echo "ERROR: no .img file found in ${rawEfi}" >&2
            exit 1
          fi
          cp "$rawImage" ./disk.raw

          # Find the rootfs partition (last ext4 partition, type 3CB8E202-...)
          rootPart=$(sgdisk -p ./disk.raw 2>/dev/null | awk '/3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC/ {print $1}' | tail -n1)
          if [ -z "$rootPart" ]; then
            echo "ERROR: could not find rootfs partition in GPT" >&2
            sgdisk -p ./disk.raw >&2
            exit 1
          fi

          partInfo=$(sgdisk -i "$rootPart" ./disk.raw 2>/dev/null)
          startSec=$(echo "$partInfo" | grep "First sector" | awk '{print $3}')
          endSec=$(echo "$partInfo" | grep "Last sector" | awk '{print $3}')
          sectorSize=$(echo "$partInfo" | grep "Sector size" | awk '{print $4}' | sed 's/[^0-9]//g')
          sectorSize=''${sectorSize:-512}
          rootSectors=$((endSec - startSec + 1))

          dd if=./disk.raw of=./rootfs.img bs=512 skip="$startSec" count="$rootSectors" status=none

          echo "Injecting flake source into /home/$NIXOS_USERNAME/$NIXOS_REPO_NAME"
          staging="$PWD/rootfs-staging"
          rm -rf "$staging"
          mkdir -p "$staging"

          fakeroot -- bash -c '
            set -euo pipefail
            staging="$1"
            src="$2"
            repoName="$3"
            username="$4"
            img="$5"

            echo "Extracting rootfs with debugfs rdump..."
            debugfs -R "rdump / $staging" "$img" 2>&1 | grep -v "Invalid argument while changing ownership" || true

            dest="$staging/home/$username/$repoName"
            rm -rf "$dest"
            mkdir -p "$(dirname "$dest")"
            cp -a "$src/." "$dest/"

            # Match uid/gid declared in the image config (1000:100)
            chown -R 1000:100 "$dest"
            chmod -R u+rwX "$dest"

            # Rebuild ext4 rootfs from staging
            imgSize=$(stat -c%s "$img")
            rm -f "$img"
            truncate -s "$imgSize" "$img"
            mkfs.ext4 -F -d "$staging" "$img" 2>&1 | tail -5
          ' -- "$staging" "$NIXOS_FLAKE_SRC" "$NIXOS_REPO_NAME" "$NIXOS_USERNAME" ./rootfs.img

          rm -rf "$staging"

          # Grow rootfs to fill partition so first boot resize is safe
          resize2fs -M ./rootfs.img 2>/dev/null || true
          rootBytes=$(stat -c%s ./rootfs.img)
          partBytes=$((rootSectors * sectorSize))
          if [ "$rootBytes" -gt "$partBytes" ]; then
            echo "ERROR: rebuilt rootfs is larger than partition" >&2
            exit 1
          fi
          truncate -s "$partBytes" ./rootfs_resized.img
          dd if=./rootfs.img of=./rootfs_resized.img bs=1M conv=notrunc,fsync status=none 2>/dev/null || true
          truncate -s "$partBytes" ./rootfs_resized.img
          resize2fs ./rootfs_resized.img 2>/dev/null || true

          dd if=./rootfs_resized.img of=./disk.raw bs=512 seek="$startSec" count="$rootSectors" conv=notrunc status=none

          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p "$out"
          cp ./disk.raw "$out/disk-${hostName}.img"
          runHook postInstall
        '';
      };

      compressed =
        pkgs.runCommand "disk-${hostName}-zst"
          {
            nativeBuildInputs = [ pkgs.zstd ];
          }
          ''
            mkdir -p "$out"
            zstd -T0 -19 < ${withFlakeSource}/disk-${hostName}.img > "$out/disk-${hostName}.img.zst"
          '';
    in
    {
      raw = withFlakeSource;
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
      (inputs.self.lib.mkKlipperConfig [
        {
          users.users.popcat19.uid = 1000;
          users.groups.users.gid = lib.mkDefault 100;

          sdImage.populateRootCommands = ''
            dest=./files/home/popcat19/${repoName}
            rm -rf "$dest"
            mkdir -p "$dest"
            cp -a "${flakeSource}/." "$dest/"
            chown -R 1000:100 "$dest"
            chmod -R u+rwX "$dest"
          '';
        }
      ]).config.system.build.sdImage;
  };
}
