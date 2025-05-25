function flake-update -d "Update Nix Flake inputs"
  echo "==> Changing to $NIXOS_CONFIG_DIR to update flakes..."
  pushd $NIXOS_CONFIG_DIR
  # No sudo needed to update flake.lock in user-owned directory
  if nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update $argv
    echo "==> Flake inputs updated successfully."
  else
    echo "==> Flake update failed."
    popd
    return 1
  end
  popd
  echo "--> Remember to commit the updated 'flake.lock' file."
end
