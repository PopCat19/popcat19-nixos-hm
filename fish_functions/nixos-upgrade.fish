function nixos-upgrade -d "Update flake inputs, then rebuild/switch NixOS"
  echo "==> Starting NixOS system upgrade..."
  if flake-update $argv[2..-1] # No sudo
    if nixos-rebuild-switch $argv[1] # Has sudo
      echo "==> System upgrade complete!"
      echo "--> If successful, consider running 'nixos-git \"Update system and flakes\"' to commit changes."
    else
      echo "==> System upgrade failed during rebuild."
      return 1
    end
  else
    echo "==> System upgrade failed during flake update."
    return 1
  end
end
