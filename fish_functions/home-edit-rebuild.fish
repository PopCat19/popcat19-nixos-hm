function home-edit-rebuild -d " Edit home.nix, then 🚀 apply"
  homeconf-edit $argv[2..-1] && nixos-apply-config $argv[1]
end
