# ~/nixos-config/fish_functions/homeconf-edit.fish
function homeconf-edit -d "📝 Edit Home Manager home.nix with your preferred editor. Use 'homeconf-edit help' for manual."
    if test "$argv[1]" = "help" -o "$argv[1]" = "h" -o "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        _homeconf_edit_help
        return 0
    else if test "$argv[1]" = "manual" -o "$argv[1]" = "man" -o "$argv[1]" = "doc"
        _homeconf_edit_manual
        return 0
    end
    
    if not test -f "$NIXOS_CONFIG_DIR/home.nix"
        echo "❌ Error: home.nix not found in $NIXOS_CONFIG_DIR"
        echo "💡 Ensure \$NIXOS_CONFIG_DIR is set correctly"
        return 1
    end
    
    echo "📝 Editing Home Manager configuration: $NIXOS_CONFIG_DIR/home.nix"
    $EDITOR $NIXOS_CONFIG_DIR/home.nix $argv
end

function _homeconf_edit_help -d "Show help for homeconf-edit"
    echo "📝 homeconf-edit - Home Manager Configuration Editor"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Opens your Home Manager configuration file for editing."
    echo ""
    echo "⚙️  USAGE:"
    echo "   homeconf-edit [editor-options]"
    echo "   homeconf-edit help|manual"
    echo ""
    echo "📂 FILE EDITED:"
    echo "   \$NIXOS_CONFIG_DIR/home.nix"
    echo ""
    echo "🔗 RELATED FUNCTIONS:"
    echo "   nixconf-edit       # Edit configuration.nix"
    echo "   flake-edit         # Edit flake.nix"
    echo "   home-edit-rebuild  # Edit + rebuild"
    echo ""
    echo "🎮 ABBREVIATIONS:"
    echo "   hconf, home-ed = homeconf-edit"
    echo "   herb = home-edit-rebuild"
end

function _homeconf_edit_manual -d "Show detailed manual for homeconf-edit"
    echo "📖 homeconf-edit - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 PURPOSE:"
    echo "   Quick access to edit your Home Manager configuration file."
    echo "   Part of the user configuration management workflow."
    echo ""
    echo "📂 FILE DETAILS:"
    echo "   • Location: \$NIXOS_CONFIG_DIR/home.nix"
    echo "   • Scope: User-specific settings and packages"
    echo "   • Content: User packages, services, dotfiles, programs"
    echo ""
    echo "🔧 COMMON CONFIGURATION SECTIONS:"
    echo "   • home.packages: User-specific packages"
    echo "   • programs: Program-specific configurations"
    echo "   • services: User services (not system services)"
    echo "   • home.file: Dotfile management"
    echo "   • xdg: XDG directory and application management"
    echo ""
    echo "💡 WORKFLOW INTEGRATION:"
    echo "   1. homeconf-edit             # Edit home configuration"
    echo "   2. nixos-apply-config        # Test changes (full rebuild)"
    echo "   3. nixos-git \"message\"       # Commit if successful"
    echo ""
    echo "   Or use home-edit-rebuild for edit + rebuild in one command."
end
