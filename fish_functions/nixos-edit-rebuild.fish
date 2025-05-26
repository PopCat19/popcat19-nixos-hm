# ~/nixos-config/fish_functions/nixos-edit-rebuild.fish
function nixos-edit-rebuild -d "Edit configuration.nix, then apply (rebuild/switch/git/rollback)"
  nixconf-edit $argv[2..-1] && nixos-apply-config $argv[1]
end
