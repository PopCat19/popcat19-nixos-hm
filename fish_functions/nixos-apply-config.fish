function nixos-apply-config -d "🚀 Apply NixOS config (rebuild/git/rollback)"
  echo "🚀 Attempting to apply NixOS configuration..."
  if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" $argv
    echo "✅ NixOS rebuild and switch successful."
    echo ""
    read -P "💬 Enter commit message (or leave blank to skip git operations): " commit_message
    if test -n "$commit_message"
      nixos-git "$commit_message"
    else
      echo "ℹ️ Git operations skipped by user."
    end
    return 0
  else
    echo "❌ NixOS rebuild and switch FAILED."
    echo ""
    read -P "󰕌 Rollback to previously working configuration? (y/N): " rollback_choice
    set -l lower_rollback_choice (string lower "$rollback_choice")
    if test "$lower_rollback_choice" = "y" -o "$lower_rollback_choice" = "yes"
      echo "󰕌 Attempting to rollback..."
      if sudo nixos-rebuild switch --rollback
        echo "✅ Rollback successful. Switched to previous configuration."
      else
        echo "❌ Rollback FAILED. You may need to manually select a previous generation at boot."
        echo "ℹ️ You can try 'sudo nixos-rebuild boot' to make the previous generation the default for next boot."
      end
    else
      echo "ℹ️ Rollback skipped by user."
    end
    return 1
  end
end
