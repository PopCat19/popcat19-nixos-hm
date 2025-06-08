# ~/nixos-config/fish_functions/home-edit-rebuild.fish
function home-edit-rebuild -d "📝 Edit home.nix, then 🚀 apply via full system rebuild"
    if test "$argv[1]" = "help" -o "$argv[1]" = "h" -o "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        _home_edit_rebuild_help
        return 0
    else if test "$argv[1]" = "manual" -o "$argv[1]" = "man" -o "$argv[1]" = "doc"
        _home_edit_rebuild_manual
        return 0
    end
    
    echo "📝 Opening home.nix for editing..."
    homeconf-edit $argv[2..-1]
    
    if test $status -eq 0
        echo "🚀 Applying changes via full system rebuild (includes Home Manager)..."
        nixos-apply-config $argv[1]
    else
        echo "❌ Edit was cancelled or failed."
        return 1
    end
end

function _home_edit_rebuild_help -d "Show help for home-edit-rebuild"
    echo "📝 home-edit-rebuild - Home Configuration Editor & Rebuilder"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Edit home.nix and then rebuild the entire NixOS system (which includes"
    echo "   Home Manager when using the NixOS module integration)."
    echo ""
    echo "⚙️  USAGE:"
    echo "   home-edit-rebuild [nixos-rebuild-options]"
    echo "   home-edit-rebuild help|manual"
    echo ""
    echo "🔄 WORKFLOW:"
    echo "   1. Opens home.nix in your \$EDITOR"
    echo "   2. After editing, calls nixos-apply-config"
    echo "   3. Rebuilds entire system (NixOS + Home Manager)"
    echo ""
    echo "💡 EXAMPLES:"
    echo "   home-edit-rebuild                    # Edit and rebuild"
    echo "   home-edit-rebuild --show-trace       # Edit and rebuild with trace"
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "   This does a FULL SYSTEM rebuild, not just 'home-manager switch'."
    echo "   This is correct when using Home Manager as a NixOS module."
    echo ""
    echo "🎮 ABBREVIATIONS:"
    echo "   herb, home-sw = home-edit-rebuild"
end

function _home_edit_rebuild_manual -d "Show detailed manual for home-edit-rebuild"
    echo "📖 home-edit-rebuild - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "   Streamlined workflow for editing Home Manager configuration and applying"
    echo "   changes via full NixOS system rebuild (required for NixOS module integration)."
    echo ""
    echo "🏗️ ARCHITECTURE UNDERSTANDING:"
    echo ""
    echo "   📦 NixOS Module Integration (your setup):"
    echo "     • Home Manager is integrated into your NixOS flake"
    echo "     • home.nix is processed during NixOS rebuild"
    echo "     • Requires 'nixos-rebuild switch' NOT 'home-manager switch'"
    echo "     • All user configurations are system-managed"
    echo ""
    echo "   🆚 Standalone Home Manager (NOT your setup):"
    echo "     • Home Manager runs independently"
    echo "     • Uses 'home-manager switch' command"
    echo "     • Separate from NixOS rebuild cycle"
    echo ""
    echo "🔄 DETAILED WORKFLOW:"
    echo "   1. Calls homeconf-edit to open \$NIXOS_CONFIG_DIR/home.nix"
    echo "   2. Waits for editor to close (edit completion)"
    echo "   3. Calls nixos-apply-config with provided arguments"
    echo "   4. Full system rebuild processes both NixOS and Home Manager configs"
    echo ""
    echo "⚠️  WHY FULL REBUILD IS NECESSARY:"
    echo "   • Your flake.nix integrates Home Manager as a NixOS module"
    echo "   • Changes to home.nix require NixOS to reprocess the module"
    echo "   • Direct 'home-manager switch' would bypass this integration"
    echo "   • System-level dependencies might be affected by home config changes"
    echo ""
    echo "🔧 INTEGRATION BENEFITS:"
    echo "   • Atomic updates (system + home changes together)"
    echo "   • Consistent rollback capability"
    echo "   • Shared package deduplication"
    echo "   • Unified generation management"
    echo ""
    echo "💡 TROUBLESHOOTING:"
    echo "   • If changes don't apply: Ensure you're not running 'home-manager switch'"
    echo "   • If fish functions don't load: Full rebuild is required for function updates"
    echo "   • If packages missing: Check both home.packages and environment.systemPackages"
end
