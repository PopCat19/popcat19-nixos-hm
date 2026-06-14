# images.nix
#
# Purpose: One-shot installer images with the flake source baked in
#
# This module:
# - Builds a single minimal x86_64 installer raw-EFI disk image that boots
#   into a bare NixOS with user, git, sing-box TUN, fish, SSH, and the flake
#   source pre-cloned at ~/popcat19-nixos-hm. From there you run
#   `nixos-rebuild switch --flake .#<host>` to install the real config.
# - Exposes the Klipper Pi SD card image (full closure, flake source baked in).
{
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  repoName = "popcat19-nixos-hm";

  flakeSource = inputs.self;

  overlaysFor = system: import ./overlays.nix { inherit inputs system; };

  # === Minimal installer config (one size fits all x86_64 hosts) ===

  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs { inherit system; };

  installerUserConfig = {
    inherit system;
    username = "popcat19";
    hostname = "popcat19-installer";
    directories = {
      home = "/home/popcat19";
      videos = "/home/popcat19/Videos";
      music = "/home/popcat19/Music";
    };
    user = {
      fullName = "PopCat19";
      email = "atsuo11111@gmail.com";
      shell = "fish";
      initialPassword = "popcat19";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "input"
        "docker"
      ];
    };
    env.NIXOS_CONFIG_DIR = "/home/popcat19/${repoName}";
  };

  installerNixosConfig = lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs;
      userConfig = installerUserConfig;
    };
    modules = [
      # Boot: systemd-boot, EFI
      ../configuration/base/system/boot.nix

      # Locale, timezone
      ../configuration/base/system/localization.nix

      # Nix config: flakes, experimental features, trusted-users
      ../configuration/nix-options.nix

      # User account + sudo
      ../configuration/system/modules/users.nix

      # NetworkManager + firewall
      ../configuration/system/modules/networking.nix

      # Fish shell
      ../configuration/system/modules/fish.nix

      # SSH server
      ../configuration/system/modules/ssh.nix

      # Basic packages (git, curl, micro, vim, wget)
      ../configuration/system/modules/core-packages.nix

      # Sing-box TUN proxy (togglable)
      ../configuration/system/modules/sing-box.nix

      { nixpkgs.overlays = overlaysFor system; }

      "${inputs.nixpkgs}/nixos/modules/image/images.nix"

      {
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

        boot.loader.systemd-boot.enable = lib.mkDefault true;
        boot.loader.grub.enable = lib.mkForce false;
        boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

        users.users.${installerUserConfig.username}.uid = 1000;
        users.groups.users.gid = lib.mkDefault 100;

        services.sing-box.enable = true;

        system.stateVersion = "25.05";
      }
    ];
  };

  rawEfi = installerNixosConfig.config.system.build.images.raw-efi;

  installerRaw = pkgs.stdenv.mkDerivation {
    name = "popcat19-installer-raw";
    dontUnpack = true;
    nativeBuildInputs = with pkgs; [
      e2fsprogs
      gptfdisk
      util-linux
      fakeroot
    ];
    NIXOS_FLAKE_SRC = "${flakeSource}";
    NIXOS_REPO_NAME = repoName;
    NIXOS_USERNAME = installerUserConfig.username;
    buildPhase = ''
      runHook preBuild

      rawImage=$(find ${rawEfi} -maxdepth 1 -name '*.img' -type f | head -n1)
      if [ -z "$rawImage" ]; then
        echo "ERROR: no .img file found in ${rawEfi}" >&2
        exit 1
      fi
      cp "$rawImage" ./disk.raw

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

        debugfs -R "rdump / $staging" "$img" 2>&1 | grep -v "Invalid argument while changing ownership" || true

        dest="$staging/home/$username/$repoName"
        rm -rf "$dest"
        mkdir -p "$(dirname "$dest")"
        cp -a "$src/." "$dest/"
        chown -R 1000:100 "$dest"

        imgSize=$(stat -c%s "$img")
        rm -f "$img"
        truncate -s "$imgSize" "$img"
        mkfs.ext4 -F -d "$staging" "$img" 2>&1 | tail -5
      ' -- "$staging" "$NIXOS_FLAKE_SRC" "$NIXOS_REPO_NAME" "$NIXOS_USERNAME" ./rootfs.img

      rm -rf "$staging"

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
      cp ./disk.raw "$out/popcat19-installer.img"
      runHook postInstall
    '';
  };

  installerZst = pkgs.runCommand "popcat19-installer-zst" { nativeBuildInputs = [ pkgs.zstd ]; } ''
    mkdir -p "$out"
    zstd -T0 -19 < ${installerRaw}/popcat19-installer.img > "$out/popcat19-installer.img.zst"
  '';
in
{
  flake.packages.x86_64-linux = {
    installer-raw = installerRaw;
    installer-zst = installerZst;
  };

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

            # Seed the user SSH key so agenix can decrypt secrets at first boot.
            # The key is read from the flake source at build time (not the store).
            ssh_dir=./files/home/popcat19/.ssh
            mkdir -p "$ssh_dir"
            cp ${builtins.path { path = /home/popcat19/.ssh/id_ed25519.pub; name = "id_ed25519.pub"; }} "$ssh_dir/id_ed25519.pub"
            cp ${builtins.path { path = /home/popcat19/.ssh/id_ed25519; name = "id_ed25519"; }} "$ssh_dir/id_ed25519"
            chown -R 1000:100 "$ssh_dir"
            chmod 700 "$ssh_dir"
            chmod 600 "$ssh_dir/id_ed25519"
            chmod 644 "$ssh_dir/id_ed25519.pub"
          '';
        }
      ]).config.system.build.sdImage;
  };
}
