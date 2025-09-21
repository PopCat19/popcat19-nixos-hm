# Aggregated Home Manager modules to simplify per-host imports
{ }:
[
  # Shared home modules
  ./theme.nix
  ./screenshot.nix
  ./mangohud.nix
  ./zen-browser.nix

  ./environment.nix
  ./services.nix
  ./home-files.nix
  ./systemd-services.nix

  ./kde-apps.nix
  ./qt-gtk-config.nix
  ./fuzzel-config.nix
  ./kitty.nix
  ./fish.nix
  ./starship.nix
  ./micro.nix
  ./fcitx5.nix
  ./privacy.nix

  # Cross-repo home configs
  ../quickshell_config/quickshell.nix
  ../syncthing_config/home.nix
]