function nixos-edit-rebuild -d "Edit configuration.nix, then rebuild/switch NixOS"
  # Calls the updated nixconf-edit (no sudo) and nixos-rebuild-switch (with sudo)
  nixconf-edit $argv[2..-1] && nixos-rebuild-switch $argv[1]
end
