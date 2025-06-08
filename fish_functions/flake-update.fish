# ~/nixos-config/fish_functions/flake-update.fish
function flake-update -d "🔄 Update Nix Flake inputs with backup and validation. Use 'flake-update help' for manual."
    if test "$argv[1]" = "help" -o "$argv[1]" = "h" -o "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        _flake_update_help
        return 0
    else if test "$argv[1]" = "manual" -o "$argv[1]" = "man" -o "$argv[1]" = "doc"
        _flake_update_manual
        return 0
    end
    
    if not test -f "$NIXOS_CONFIG_DIR/flake.nix"
        echo "❌ Error: flake.nix not found in $NIXOS_CONFIG_DIR"
        echo "💡 Ensure you're in a flake-enabled NixOS configuration"
        return 1
    end
    
    echo "🔄 Updating Flake inputs in $NIXOS_CONFIG_DIR..."
    
    # Backup current flake.lock
    if test -f "$NIXOS_CONFIG_DIR/flake.lock"
        cp "$NIXOS_CONFIG_DIR/flake.lock" "$NIXOS_CONFIG_DIR/flake.lock.bak"
        echo "💾 Backed up flake.lock to flake.lock.bak"
    end
    
    pushd $NIXOS_CONFIG_DIR
    if nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update $argv
        echo "✅ Flake inputs updated successfully."
        echo "📊 Changes made to flake.lock:"
        if command -q git
            git diff --no-index flake.lock.bak flake.lock 2>/dev/null || echo "   (Use git diff to see changes)"
        end
    else
        echo "❌ Flake update failed."
        if test -f "flake.lock.bak"
            echo "🔄 Restoring backup..."
            mv flake.lock.bak flake.lock
        end
        popd
        return 1
    end
    popd
    echo "💾 Remember to test with nixos-apply-config and commit the updated flake.lock"
end

function _flake_update_help -d "Show help for flake-update"
    echo "🔄 flake-update - Nix Flake Input Updater"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Safely updates all flake inputs with automatic backup and validation."
    echo ""
    echo "⚙️  USAGE:"
    echo "   flake-update [nix-flake-options]"
    echo "   flake-update help|manual"
    echo ""
    echo "💡 EXAMPLES:"
    echo "   flake-update                    # Update all inputs"
    echo "   flake-update nixpkgs           # Update specific input"
    echo "   flake-update --recreate-lock-file # Recreate entire lock file"
    echo ""
    echo "🔗 WORKFLOW:"
    echo "   1. Backs up current flake.lock"
    echo "   2. Updates flake inputs"
    echo "   3. Shows changes made"
    echo "   4. Restores backup on failure"
    echo ""
    echo "🎮 INTEGRATION:"
    echo "   • Used by nixos-upgrade function"
    echo "   • flup, flake-up abbreviations available"
end

function _flake_update_manual -d "Show detailed manual for flake-update"
    echo "📖 flake-update - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "   Manages Nix flake input updates with safety features and integration"
    echo "   into your NixOS configuration workflow."
    echo ""
    echo "🔄 UPDATE PROCESS:"
    echo "   1. Validates flake.nix exists"
    echo "   2. Creates backup of flake.lock"
    echo "   3. Runs nix flake update with provided options"
    echo "   4. Shows diff of changes"
    echo "   5. Restores backup if update fails"
    echo ""
    echo "🎯 UPDATE STRATEGIES:"
    echo ""
    echo "   📦 Full Update (recommended monthly):"
    echo "     flake-update"
    echo "     → Updates all inputs to latest versions"
    echo ""
    echo "   🎯 Selective Update (for specific issues):"
    echo "     flake-update nixpkgs"
    echo "     → Updates only specified input"
    echo ""
    echo "   🔄 Lock File Rebuild (for corruption):"
    echo "     flake-update --recreate-lock-file"
    echo "     → Completely recreates lock file"
    echo ""
    echo "⚠️  IMPORTANT CONSIDERATIONS:"
    echo "   • Updates can introduce breaking changes"
    echo "   • Always test with nixos-apply-config after updating"
    echo "   • Keep backup files until testing is complete"
    echo "   • Consider selective updates for production systems"
    echo ""
    echo "🔧 INTEGRATION WORKFLOW:"
    echo "   1. flake-update                 # Update inputs"
    echo "   2. nixos-apply-config          # Test rebuild"
    echo "   3. If successful: commit changes"
    echo "   4. If failed: restore from backup"
    echo ""
    echo "🆘 TROUBLESHOOTING:"
    echo "   • Build failures after update: Use --show-trace"
    echo "   • Restore backup: mv flake.lock.bak flake.lock"
    echo "   • Selective rollback: git checkout flake.lock"
end
