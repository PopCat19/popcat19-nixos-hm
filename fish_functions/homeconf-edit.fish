# ~/nixos-config/fish_functions/homeconf-edit.fish
function homeconf-edit -d "Edit Home Manager home.nix"
  $EDITOR $NIXOS_CONFIG_DIR/home.nix $argv
end
