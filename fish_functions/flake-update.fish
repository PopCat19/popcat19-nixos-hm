function flake-update -d "󰚰 Update Nix Flake inputs"
  echo "󰚰 Updating Flake inputs in $NIXOS_CONFIG_DIR..."
  pushd $NIXOS_CONFIG_DIR
  if nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update $argv
    echo "✅ Flake inputs updated successfully."
  else
    echo "❌ Flake update failed."
    popd
    return 1
  end
  popd
  echo "💾 Remember to commit the updated 'flake.lock' file."
end
