function nixos-edit-rebuild -d " Edit configuration.nix, then 🚀 apply"
  nixconf-edit $argv[2..-1] && nixos-apply-config $argv[1]
end
