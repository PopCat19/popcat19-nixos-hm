# ~/nixos-config/fish_functions/nixos-apply-config.fish
function nixos-apply-config -d "Rebuild/switch NixOS, then git commit/push on success, or offer rollback on failure."
  echo "==> Attempting to rebuild and switch NixOS configuration..."
  # Pass any arguments to nixos-rebuild switch
  if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" $argv
    echo "✅ NixOS rebuild and switch successful."
    echo ""
    read -P "Enter commit message (or leave blank to skip git operations): " commit_message
    if test -n "$commit_message"
      nixos-git "$commit_message"
    else
      echo "--> Git operations skipped by user."
    end
    return 0 # Success
  else
    echo "❌ NixOS rebuild and switch FAILED."
    echo ""
    read -P "Rollback to the previously working configuration? (y/N): " rollback_choice
    set -l lower_rollback_choice (string lower "$rollback_choice")
    if test "$lower_rollback_choice" = "y" -o "$lower_rollback_choice" = "yes"
      echo "==> Attempting to rollback..."
      if sudo nixos-rebuild switch --rollback
        echo "✅ Rollback successful. Switched to previous configuration."
      else
        echo "❌ Rollback FAILED. You may need to manually select a previous generation at boot."
        echo "You can try 'sudo nixos-rebuild boot' to make the previous generation the default for next boot."
      end
    else
      echo "--> Rollback skipped by user."
    end
    return 1 # Failure
  end
end
