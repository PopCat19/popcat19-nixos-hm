# ~/nixos-config/fish_functions/home-edit-rebuild.fish
function home-edit-rebuild -d "Edit home.nix, then apply (rebuild/switch/git/rollback)"
  homeconf-edit $argv[2..-1] && nixos-apply-config $argv[1]
end
