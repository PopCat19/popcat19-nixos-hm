NixOS Configuration Quick Reference
===================================

SYSTEM OPERATIONS
-----------------

Build & Switch:
$ sudo nixos-rebuild switch --flake .#<hostname>

Test Configuration:
$ sudo nixos-rebuild test --flake .#<hostname>

Boot Configuration:
$ sudo nixos-rebuild boot --flake .#<hostname>

Update Flake:
$ nix flake update

Show Configuration:
$ nixos-rebuild build --flake .#<hostname> --dry-run

MAINTENANCE
-----------

Garbage Collection:
$ nix-collect-garbage -d
$ sudo nix-collect-garbage -d

List Generations:
$ sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

Rollback:
$ sudo nixos-rebuild switch --rollback

Store Optimization:
$ nix store optimise

THEMING
-------

Apply GTK Theme:
$ nwg-look -a

Check Theme Status:
$ dconf read /org/gnome/desktop/interface/gtk-theme
$ fastfetch | grep -i theme

Reset Theme:
$ dconf reset /org/gnome/desktop/interface/gtk-theme

DEBUGGING
---------

Check Flake:
$ nix flake check

Show Flake Info:
$ nix flake show

Validate Configuration:
$ sudo nixos-rebuild dry-build --flake .#<hostname>

Check Logs:
$ journalctl -u nixos-rebuild
$ journalctl --user -u hyprland

DEVELOPMENT
-----------

Enter Development Shell:
$ nix develop

Format Nix Files:
$ nixpkgs-fmt *.nix

Check Syntax:
$ nix-instantiate --parse <file>.nix

DIRECTORIES
-----------

System:           /etc/nixos/
Nix Store:        /nix/store/
User Profile:     ~/.nix-profile/
Home Manager:     ~/.config/home-manager/
Themes:           ~/.local/share/themes/
Icons:            ~/.local/share/icons/

FILES
-----

Main Config:      flake.nix
System Config:    configuration.nix
User Config:      home.nix
Hardware:         hardware-configuration.nix
Lock File:        flake.lock

VARIABLES
---------

hostname = "popcat19-nixos0"
username = "popcat19"
system = "x86_64-linux"

Update these in flake.nix for new installations.

SHORTCUTS
---------

nixos-rebuild switch --flake .#<hostname>  → nrb
home-manager switch --flake .              → herb
nix flake update                           → flup
nix-collect-garbage -d                     → clean
