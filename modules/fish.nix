{ pkgs, ... }:

{
  # Fish Shell Configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0
      set -Ux EDITOR micro
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
              git push
              echo "✅ Build succeeded, changes pushed to remote"
          else
              echo "❌ Build failed, changes not pushed"
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
      flup = "begin; cd $NIXOS_CONFIG_DIR; cp flake.lock flake.lock.bak; nix flake update; cd -; end";
      ngit = "begin; cd $NIXOS_CONFIG_DIR; git $argv; cd -; end";
      cdh = "cd $NIXOS_CONFIG_DIR";

      # NixOS Build and Switch operations.
      nrb = "begin; cd $NIXOS_CONFIG_DIR; git add .; sudo nixos-rebuild switch --flake .; cd -; end";
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