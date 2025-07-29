{ pkgs, userConfig, ... }:

{
  # Fish Shell Configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME ${userConfig.host.hostname}
      set -Ux EDITOR ${userConfig.defaultApps.editor.command}
      set -g fish_greeting "" # Disable default fish greeting.

      # Custom greeting disabled - fastfetch removed
      function fish_greeting
          # Empty greeting
      end

      # NixOS commit, rebuild, and push function
      function nixos-commit-rebuild-push
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          # Store the current commit hash before making changes
          set -l pre_commit_hash (git rev-parse HEAD)
          
          git add .
          git commit -m "$argv"
          
          if sudo nixos-rebuild switch --flake .
              # Try to push and handle potential conflicts
              if git push 2>/dev/null
                  echo "✅ Build succeeded, changes pushed to remote"
              else
                  echo ""
                  echo "⚠️  Normal push failed - likely due to diverged history"
                  echo "💡 This can happen after rollbacks or when remote is ahead"
                  echo ""
                  
                  # 5 second countdown for force push
                  echo "🚨 Force push required to update remote branch"
                  for i in (seq 5 -1 1)
                      printf "\r⏰ Force push in %d seconds... (Ctrl+C to cancel)" $i
                      sleep 1
                  end
                  echo ""
                  
                  read -l -P "Proceed with force push? [y/N]: " force_push_choice
                  
                  if test "$force_push_choice" = "y" -o "$force_push_choice" = "Y"
                      git push --force-with-lease
                      echo "✅ Build succeeded, changes force-pushed to remote"
                  else
                      echo "⚠️  Build succeeded but changes not pushed to remote"
                      echo "💡 You can manually push later with: git push --force-with-lease"
                  end
              end
          else
              echo "❌ Build failed, changes not pushed"
              echo ""
              read -l -P "Do you want to rollback to the previous commit? [y/N]: " rollback_choice
              
              if test "$rollback_choice" = "y" -o "$rollback_choice" = "Y"
                  git reset --hard $pre_commit_hash
                  echo "🔄 Rolled back to commit: $pre_commit_hash"
                  echo "📝 Your changes have been reverted"
                  echo ""
                  echo "⚠️  Note: If you had pushed this commit before, you may need to force push"
                  echo "   after your next successful commit to sync the remote branch"
              else
                  echo "⚠️  Changes kept in current commit. You can manually rollback with:"
                  echo "   git reset --hard $pre_commit_hash"
                  echo ""
                  echo "💡 If you rollback later and then push, you may need --force-with-lease"
              end
          end
          cd $original_dir
      end

      # Basic NixOS rebuild function (no commit/push)
      function nixos-rebuild-basic
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          echo "🔄 Running NixOS rebuild..."
          if sudo nixos-rebuild switch --flake .
              echo "✅ Build succeeded"
          else
              echo "❌ Build failed"
              cd $original_dir
              return 1
          end
          cd $original_dir
      end

      # Smart dev to main merge function
      function dev-to-main
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          # Check if we're on dev branch
          set -l current_branch (git branch --show-current)
          if test "$current_branch" != "dev"
              echo "❌ Not on dev branch. Currently on: $current_branch"
              echo "💡 Switch to dev branch first: git checkout dev"
              cd $original_dir
              return 1
          end
          
          # Check for uncommitted changes
          if not git diff --quiet; or not git diff --cached --quiet
              echo "❌ You have uncommitted changes on dev branch"
              echo "💡 Commit or stash your changes first"
              git status --short
              cd $original_dir
              return 1
          end
          
          # Fetch latest changes
          echo "🔄 Fetching latest changes..."
          git fetch origin
          
          # Check if dev is behind origin/dev
          set -l dev_behind (git rev-list --count HEAD..origin/dev 2>/dev/null || echo "0")
          if test "$dev_behind" -gt 0
              echo "❌ Your dev branch is $dev_behind commits behind origin/dev"
              echo "💡 Pull latest changes first: git pull origin dev"
              cd $original_dir
              return 1
          end
          
          # Check if dev is ahead of origin/dev (unpushed commits)
          set -l dev_ahead (git rev-list --count origin/dev..HEAD 2>/dev/null || echo "0")
          if test "$dev_ahead" -gt 0
              echo "❌ You have $dev_ahead unpushed commits on dev"
              echo "💡 Push your dev changes first: git push origin dev"
              cd $original_dir
              return 1
          end
          
          # Switch to main and check for conflicts
          echo "🔄 Switching to main branch..."
          git checkout main
          
          # Check if main is behind origin/main
          set -l main_behind (git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
          if test "$main_behind" -gt 0
              echo "🔄 Pulling latest main changes..."
              git pull origin main
          end
          
          # Check for potential merge conflicts
          echo "🔍 Checking for potential merge conflicts..."
          if not git merge --no-commit --no-ff dev >/dev/null 2>&1
              git merge --abort 2>/dev/null
              echo "❌ Merge conflicts detected between dev and main"
              echo "💡 Resolve conflicts manually or use a different merge strategy"
              git checkout dev
              cd $original_dir
              return 1
          end
          
          # Abort the test merge
          git merge --abort 2>/dev/null
          
          # Perform the actual merge
          echo "✅ No conflicts detected. Merging dev into main..."
          git merge dev --no-ff -m "Merge dev into main"
          
          # Push to main
          echo "🚀 Pushing to main..."
          git push origin main
          
          # Switch back to dev
          echo "🔄 Switching back to dev branch..."
          git checkout dev
          
          echo "✅ Successfully merged dev into main and pushed to remote"
          cd $original_dir
      end

      # Enhanced flake update function with feedback and diff
      function nixos-flake-update
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          echo "🔄 Updating NixOS flake inputs..."
          echo ""
          
          # Create backup of current flake.lock
          if test -f flake.lock
              cp flake.lock flake.lock.bak
              echo "💾 Backup created: flake.lock.bak"
          else
              echo "⚠️  No existing flake.lock found"
          end
          
          # Store current flake.lock content for comparison
          set -l old_lock_content ""
          if test -f flake.lock
              set old_lock_content (cat flake.lock)
          end
          
          # Perform flake update
          echo "📦 Running nix flake update..."
          if nix flake update
              echo "✅ Flake update completed successfully"
              echo ""
              
              # Check if anything actually changed
              if test -f flake.lock
                  set -l new_lock_content (cat flake.lock)
                  
                  if test "$old_lock_content" = "$new_lock_content"
                      echo "ℹ️  No changes detected - all inputs were already up to date"
                  else
                      echo "📊 Changes detected in flake.lock:"
                      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                      
                      # Show diff if available
                      if command -v diff >/dev/null
                          diff --unified=3 --color=always flake.lock.bak flake.lock 2>/dev/null || begin
                              echo "📝 Detailed diff:"
                              diff --unified=3 flake.lock.bak flake.lock 2>/dev/null || echo "   (diff command failed, but changes were detected)"
                          end
                      else
                          echo "📝 Changes detected but diff command not available"
                      end
                      
                      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                      echo ""
                      
                      # Show summary of what inputs were updated
                      echo "🔍 Analyzing updated inputs..."
                      if command -v jq >/dev/null
                          # Extract input names that changed
                          set -l updated_inputs (jq -r '.nodes | to_entries[] | select(.value.locked) | .key' flake.lock 2>/dev/null | head -10)
                          if test -n "$updated_inputs"
                              echo "📋 Updated inputs:"
                              for input in $updated_inputs
                                  echo "   • $input"
                              end
                          end
                      else
                          echo "   (jq not available for detailed analysis)"
                      end
                      
                      echo ""
                      echo "💡 Next steps:"
                      echo "   • Test your configuration: nixos-rebuild dry-run --flake ."
                      echo "   • Apply changes: nixos-commit-rebuild-push 'flake update'"
                      echo "   • Restore backup if needed: mv flake.lock.bak flake.lock"
                  end
              else
                  echo "⚠️  flake.lock not found after update"
              end
          else
              echo "❌ Flake update failed"
              
              # Restore backup if update failed
              if test -f flake.lock.bak
                  echo "🔄 Restoring backup..."
                  mv flake.lock.bak flake.lock
                  echo "✅ Backup restored"
              end
              
              cd $original_dir
              return 1
          end
          
          cd $original_dir
      end
      fish_add_path $HOME/bin # Add user's bin directory to PATH.
      fish_add_path $HOME/.npm-global/bin # Add npm global packages to PATH.
      if status is-interactive
          starship init fish | source # Initialize Starship prompt.
      end
    '';
    # Custom shell abbreviations for convenience.
    shellAbbrs = {
      # Navigation shortcuts.
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";

      # File Operations using eza.
      mkdir = "mkdir -p";
      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";

      # NixOS Configuration Management.
      nconf = "$EDITOR $NIXOS_CONFIG_DIR/configuration.nix";
      hconf = "$EDITOR $NIXOS_CONFIG_DIR/home.nix";
      flconf = "$EDITOR $NIXOS_CONFIG_DIR/flake.nix";
      flup = "nixos-flake-update";
      ngit = "begin; cd $NIXOS_CONFIG_DIR; git $argv; cd -; end";
      cdh = "cd $NIXOS_CONFIG_DIR";

      # NixOS Build and Switch operations.
      nrb = "nixos-rebuild-basic";
      nrbc = "nixos-commit-rebuild-push";

      # Package Management with nix search.
      pkgs = "nix search nixpkgs";
      nsp = "nix-shell -p";

      # Git shortcuts.
      gac = "git add . && git commit -m $argv";
      greset = "git reset --hard && git clean -fd";
      dtm = "dev-to-main";

      # SillyTavern launcher.
      sillytavern = "begin; cd ~/SillyTavern-Launcher/SillyTavern; git pull origin staging 2>/dev/null || true; ./start.sh; cd -; end";
    };
  };

  # Fish configuration files
  home.file.".config/fish/themes" = {
    source = ../fish_themes;
    recursive = true;
  };
}