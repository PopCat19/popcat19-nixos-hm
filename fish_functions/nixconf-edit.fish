# ~/nixos-config/fish_functions/nixconf-edit.fish
function nixconf-edit -d "📝 Edit NixOS configuration.nix with your preferred editor. Use 'nixconf-edit help' for manual."
    if test "$argv[1]" = "help" -o "$argv[1]" = "h" -o "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        _nixconf_edit_help
        return 0
    else if test "$argv[1]" = "manual" -o "$argv[1]" = "man" -o "$argv[1]" = "doc"
        _nixconf_edit_manual
        return 0
    end
    
    if not test -f "$NIXOS_CONFIG_DIR/configuration.nix"
        echo "❌ Error: configuration.nix not found in $NIXOS_CONFIG_DIR"
        echo "💡 Ensure \$NIXOS_CONFIG_DIR is set correctly"
        return 1
    end
    
    echo "📝 Editing NixOS configuration: $NIXOS_CONFIG_DIR/configuration.nix"
    $EDITOR $NIXOS_CONFIG_DIR/configuration.nix $argv
end

function _nixconf_edit_help -d "Show help for nixconf-edit"
    echo "📝 nixconf-edit - NixOS System Configuration Editor"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Opens your system-wide NixOS configuration file for editing."
    echo ""
    echo "⚙️  USAGE:"
    echo "   nixconf-edit [editor-options]"
    echo "   nixconf-edit help|manual"
    echo ""
    echo "📂 FILE EDITED:"
    echo "   \$NIXOS_CONFIG_DIR/configuration.nix"
    echo ""
    echo "🔗 RELATED FUNCTIONS:"
    echo "   homeconf-edit      # Edit home.nix"
    echo "   flake-edit         # Edit flake.nix"
    echo "   nixos-edit-rebuild # Edit + rebuild"
    echo ""
    echo "🎮 ABBREVIATIONS:"
    echo "   nconf, nixos-ed = nixconf-edit"
    echo "   nerb = nixos-edit-rebuild"
end

function _nixconf_edit_manual -d "Show detailed manual for nixconf-edit"
    echo "📖 nixconf-edit - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 PURPOSE:"
    echo "   Quick access to edit your system-wide NixOS configuration file."
    echo "   Part of the configuration management workflow."
    echo ""
    echo "📂 FILE DETAILS:"
    echo "   • Location: \$NIXOS_CONFIG_DIR/configuration.nix"
    echo "   • Scope: System-wide settings and packages"
    echo "   • Content: Hardware config, services, system packages, users"
    echo ""
    echo "🔧 COMMON CONFIGURATION SECTIONS:"
    echo "   • imports: Include other configuration files"
    echo "   • boot: Boot loader and kernel settings"
    echo "   • networking: Network configuration"
    echo "   • services: System services (SSH, printing, etc.)"
    echo "   • environment.systemPackages: System-wide packages"
    echo "   • users: User account configuration"
    echo "   • programs: System-wide program settings"
    echo ""
    echo "💡 WORKFLOW INTEGRATION:"
    echo "   1. nixconf-edit              # Edit configuration"
    echo "   2. nixos-apply-config       # Test changes"
    echo "   3. nixos-git \"message\"      # Commit if successful"
    echo ""
    echo "   Or use nixos-edit-rebuild for edit + rebuild in one command."
end
