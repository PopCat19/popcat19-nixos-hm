# ~/nixos-config/fish_functions/home-edit-rebuild.fish
function home-edit-rebuild -d "Edit home.nix, then rebuild/switch NixOS"
  # Calls homeconf-edit (no sudo) and nixos-rebuild-switch (with sudo)
  homeconf-edit $argv[2..-1] && nixos-rebuild-switch $argv[1]
end
