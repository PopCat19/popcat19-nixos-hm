function nixos-rebuild-switch -d "Rebuild and switch NixOS using Flake"
  echo "==> Rebuilding NixOS from flake: $NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME"
  # sudo is still required here to switch the system configuration
  if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" $argv
    echo "==> NixOS rebuild and switch successful."
  else
    echo "==> NixOS rebuild and switch failed."
    return 1
  end
end
