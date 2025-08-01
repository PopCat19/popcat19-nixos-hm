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

      # Function to temporarily enable unfree and insecure packages for nix-shell
      function nix-shell-unfree
          set -lx NIXPKGS_ALLOW_UNFREE 1
          set -lx NIXPKGS_ALLOW_INSECURE 1
          if test (count $argv) -gt 0
              nix-shell $argv
          else
              echo "NIXPKGS_ALLOW_UNFREE and NIXPKGS_ALLOW_INSECURE are now set for this session."
              echo "You can now run nix-shell with packages that require these flags."
          end
      end

      # Function to list available fish functions and abbreviations
      function list-fish-helpers
          echo "🐟 Available Fish Functions:"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          functions | grep -v "^_" | grep -v "^fish_" | sort
          echo ""
          echo "🔤 Available Fish Abbreviations:"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          abbr --list | sort
          echo ""
          echo "💡 Use 'type <function_name>' to see function definition"
          echo "💡 Use 'abbr --show <abbr_name>' to see abbreviation expansion"
          echo ""
          echo "🔧 Quick Fix for corrupted fish history: fixhist"
      end

      # Custom greeting disabled - fastfetch removed
      function fish_greeting
          # Empty greeting
      end

      # NixOS commit, rebuild, and push function
      function nixos-commit-rebuild-push
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          # Parse arguments for distributed builds
          set -l commit_message ""
          set -l build_host ""
          set -l use_remote_build false
          
          # Parse arguments
          set -l i 1
          while test $i -le (count $argv)
              switch $argv[$i]
                  case "--build-host"
                      set i (math $i + 1)
                      if test $i -le (count $argv)
                          set build_host $argv[$i]
                          set use_remote_build true
                      else
                          echo "❌ --build-host requires a hostname"
                          cd $original_dir
                          return 1
                      end
                  case "--remote"
                      set build_host "popcat19@192.168.50.172"
                      set use_remote_build true
                  case "*"
                      if test -z "$commit_message"
                          set commit_message $argv[$i]
                      else
                          set commit_message "$commit_message $argv[$i]"
                      end
              end
              set i (math $i + 1)
          end
          
          # Ensure we have a commit message
          if test -z "$commit_message"
              echo "❌ Usage: nixos-commit-rebuild-push [--remote|--build-host <host>] '<commit-message>'"
              echo "💡 Examples:"
              echo "   nixos-commit-rebuild-push 'update config'"
              echo "   nixos-commit-rebuild-push --remote 'update config'"
              echo "   nixos-commit-rebuild-push --build-host user@host 'update config'"
              cd $original_dir
              return 1
          end
          
          # Store the current commit hash before making changes
          set -l pre_commit_hash (git rev-parse HEAD)
          
          git add .
          git commit -m "$commit_message"
          
          # Build command based on whether we're using remote builds
          if test "$use_remote_build" = "true"
              echo "🏗️  Building on remote host: $build_host"
              if sudo nixos-rebuild switch --flake . --build-host $build_host
                  # Try to push and handle potential conflicts
                  if git push 2>/dev/null
                      echo "✅ Remote build succeeded, changes pushed to remote"
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
                          echo "✅ Remote build succeeded, changes force-pushed to remote"
                      else
                          echo "⚠️  Remote build succeeded but changes not pushed to remote"
                          echo "💡 You can manually push later with: git push --force-with-lease"
                      end
                  end
              else
                  echo "❌ Remote build failed, changes not pushed"
                  echo ""
                  read -l -P "Do you want to rollback to the previous commit? [y/N]: " rollback_choice
                  
                  if test "$rollback_choice" = "y" -o "$rollback_choice" = "Y"
                      git reset --hard $pre_commit_hash
                      echo "🔄 Rolled back to commit: $pre_commit_hash"
                      echo "📝 Your changes have been reverted"
                  else
                      echo "⚠️  Changes kept in current commit. You can manually rollback with:"
                      echo "   git reset --hard $pre_commit_hash"
                  end
                  cd $original_dir
                  return 1
              end
          else
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
      
      # Distributed builds functions
      function nixos-remote-build
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          if test (count $argv) -eq 0
              echo "❌ Usage: nixos-remote-build <package-name>"
              echo "💡 Example: nixos-remote-build hello"
              echo "💡 Example: nixos-remote-build firefox"
              cd $original_dir
              return 1
          end
          
          set -l package $argv[1]
          echo "🏗️  Building $package on nixos0 (192.168.50.172)..."
          echo "⚡ Using R5 5500 (12 threads) for faster builds"
          
          if nix build "nixpkgs#$package" --builders "ssh://192.168.50.172 x86_64-linux" --max-jobs 0
              echo "✅ Remote build completed successfully"
              echo "📦 Package built: $package"
          else
              echo "❌ Remote build failed"
              cd $original_dir
              return 1
          end
          
          cd $original_dir
      end

      # Remote NixOS system rebuild function
      function nixos-remote-rebuild
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          
          set -l config "popcat19-surface0"
          set -l action "dry-run"
          
          # Parse arguments
          for arg in $argv
              switch $arg
                  case "switch" "boot" "test" "dry-run" "dry-activate"
                      set action $arg
                  case "surface0" "popcat19-surface0"
                      set config "popcat19-surface0"
                  case "nixos0" "popcat19-nixos0"
                      set config "popcat19-nixos0"
                  case "*"
                      set config $arg
              end
          end
          
          echo "🏗️  Building $config configuration on nixos0..."
          echo "⚡ Using R5 5500 (12 threads) for faster builds"
          echo "🎯 Action: $action"
          
          if nixos-rebuild --flake ".#$config" --build-host popcat19@192.168.50.172 --target-host localhost $action
              echo "✅ Remote rebuild completed successfully"
          else
              echo "❌ Remote rebuild failed"
              cd $original_dir
              return 1
          end
          
          cd $original_dir
      end

      # Test SSH connection to nixos0
      function test-nixos0-ssh
          echo "🔗 Testing SSH connection to nixos0..."
          if ssh -o ConnectTimeout=5 popcat19@192.168.50.172 "hostname && whoami && nix --version"
              echo "✅ SSH connection successful"
              echo "🏗️  Remote builder is ready"
          else
              echo "❌ SSH connection failed"
              echo "💡 Check network connectivity and SSH configuration"
              return 1
          end
      end

      # SSH to nixos0 function
      function ssh-nixos0
          echo "🔗 Connecting to nixos0 (192.168.50.172)..."
          ssh popcat19@192.168.50.172 $argv
      end

      # SSH to surface0 function (for use from nixos0)
      function ssh-surface0
          echo "🔗 Connecting to surface0..."
          # Try to determine surface IP dynamically or use common patterns
          set -l surface_ips "192.168.50.219" "192.168.50.171" "192.168.50.173" "192.168.50.174"
          
          for ip in $surface_ips
              if ping -c 1 -W 1 $ip >/dev/null 2>&1
                  echo "📍 Found surface0 at $ip"
                  ssh popcat19@$ip $argv
                  return
              end
          end
          
          echo "❌ Could not find surface0 on network"
          echo "💡 Try manually: ssh popcat19@<surface-ip>"
      end

      # Interactive SSH with hostname detection
      function ssh-other
          set -l current_host (hostname)
          
          if string match -q "*surface*" $current_host
              echo "📱 Currently on Surface, connecting to nixos0..."
              ssh-nixos0 $argv
          else if string match -q "*nixos0*" $current_host
              echo "🖥️  Currently on nixos0, connecting to surface0..."
              ssh-surface0 $argv
          else
              echo "❓ Unknown host: $current_host"
              echo "💡 Available options:"
              echo "   • ssh-nixos0    - Connect to nixos0"
              echo "   • ssh-surface0  - Connect to surface0"
          end
      end

      # Show distributed builds status
      function nixos-build-status
          echo "🏗️  Distributed Builds Status"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "📍 Current machine: $(hostname) ($(whoami))"
          echo "🎯 Remote builder: popcat19-nixos0 (192.168.50.172)"
          echo "⚡ Builder specs: R5 5500 (6c/12t), 32GB DDR4"
          echo ""
          
          # Test connectivity
          echo "🔗 Testing connection..."
          if ssh -o ConnectTimeout=3 popcat19@192.168.50.172 "echo 'Connection OK'" 2>/dev/null
              echo "✅ SSH connection: OK"
              
              # Get remote system info
              set -l remote_info (ssh popcat19@192.168.50.172 "uname -r && nix --version | head -1" 2>/dev/null)
              if test -n "$remote_info"
                  echo "🖥️  Remote kernel: $(echo $remote_info | head -1)"
                  echo "📦 Remote Nix: $(echo $remote_info | tail -1)"
              end
          else
              echo "❌ SSH connection: FAILED"
              echo "💡 Run 'test-nixos0-ssh' for detailed diagnostics"
          end
          
          echo ""
          echo "🛠️  Available commands:"
          echo "   • nixos-remote-build <package>  - Build package on nixos0"
          echo "   • nixos-remote-rebuild [action]  - Rebuild system on nixos0"
          echo "   • test-nixos0-ssh               - Test SSH connection"
          echo "   • rb <package>                  - Quick remote build"
          echo "   • rrb [action]                  - Quick remote rebuild"
          echo ""
          echo "🔗 SSH shortcuts:"
          echo "   • sn / nixos0                   - SSH to nixos0"
          echo "   • ss / surface0                 - SSH to surface0"
          echo "   • so                            - SSH to other machine (auto-detect)"
      end
      
      # Function to fix corrupted fish history
      function fix-fish-history
          echo "🔧 Fixing fish history corruption..."
          
          # Get the history file path
          set -l history_file (set -q XDG_DATA_HOME; and echo "$XDG_DATA_HOME/fish/fish_history"; or echo "$HOME/.local/share/fish/fish_history")
          
          # Check if history file exists
          if not test -f "$history_file"
              echo "⚠️  History file not found at: $history_file"
              return 1
          end
          
          # Create backup
          set -l backup_file "$history_file.bak"
          cp "$history_file" "$backup_file"
          echo "💾 Created backup at: $backup_file"
          
          # Try to fix the history file by removing corrupted entries
          echo "🔄 Attempting to repair history file..."
          
          # Use fish's built-in history merge to fix corruption
          history merge
          
          # If that doesn't work, try to truncate the file at the corruption point
          if test $status -ne 0
              echo "⚠️  Standard repair failed, attempting manual fix..."
              
              # Get the approximate corruption offset from the error message
              # This is a simplified approach - in a real scenario you might want more sophisticated parsing
              set -l offset 2800
              
              # Truncate the file before the corruption point
              head -n $offset "$history_file" > "$history_file.tmp"
              mv "$history_file.tmp" "$history_file"
              
              echo "✅ History file truncated before corruption point"
          else
              echo "✅ History file repaired successfully"
          end
          
          echo "💡 You may need to restart fish for changes to take full effect"
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
      
      # Remote distributed builds with nixos-commit-rebuild-push.
      nrbcr = "nixos-commit-rebuild-push --build-host popcat19@192.168.50.172";

      # Package Management with nix search.
      pkgs = "nix search nixpkgs";
      nsp = "nix-shell -p";

      # Git shortcuts.
      gac = "git add . && git commit -m $argv";
      greset = "git reset --hard && git clean -fd";
      dtm = "dev-to-main";

      # SillyTavern launcher.
      sillytavern = "begin; cd ~/SillyTavern-Launcher/SillyTavern; git pull origin staging 2>/dev/null || true; ./start.sh; cd -; end";

      # Fish history management.
      fixhist = "fix-fish-history";

      # Distributed builds shortcuts.
      rb = "nixos-remote-build";
      rrb = "nixos-remote-rebuild";
      buildstatus = "nixos-build-status";
      testssh = "test-nixos0-ssh";
      
      # Remote rebuild variations.
      rrbdry = "nixos-remote-rebuild dry-run";
      rrbswitch = "nixos-remote-rebuild switch";
      rrbtest = "nixos-remote-rebuild test";
      
      # SSH shortcuts for bi-directional access.
      sn = "ssh-nixos0";
      ss = "ssh-surface0";
      so = "ssh-other";
      nixos0 = "ssh-nixos0";
      surface0 = "ssh-surface0";
    };
  };

  # Fish configuration files
  home.file.".config/fish/themes" = {
    source = ../fish_themes;
    recursive = true;
  };
}