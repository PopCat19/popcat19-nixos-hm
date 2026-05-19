# nix-on-droid.nix
#
# Purpose: Minimal profile for nix-on-droid on Android
#
# This profile:
# - Core CLI: git, fish, helix, broot, starship, tmux, lazygit, micro, eza, ripgrep, fd, jq
# - Skips desktop modules (Hyprland, fonts, stylix, GUI apps)
# - Skips NixOS-only modules (systemd services, networking, hardware)
{ pkgs, ... }:
{
  system.stateVersion = "24.05";

  environment.packages = with pkgs; [
    eza
    fd
    fish
    gh
    git
    jq
    ripgrep
  ];

  home-manager = {
    useGlobalPkgs = true;
    config = {
      home.username = "nix-on-droid";
      home.homeDirectory = "/data/data/com.termux.nix/files/home";
      home.stateVersion = "24.05";

      home.packages = with pkgs; [
        broot
        helix
        lazygit
        micro
        starship
        tmux
      ];

      programs = {
        broot.enable = true;
        fish.enable = true;
        git = {
          enable = true;
          settings = {
            user.name = "PopCat19";
            user.email = "atsuo11111@gmail.com";
          };
        };
        helix.enable = true;
        lazygit.enable = true;
        micro.enable = true;
        starship.enable = true;
        tmux.enable = true;
      };
    };
  };

}
