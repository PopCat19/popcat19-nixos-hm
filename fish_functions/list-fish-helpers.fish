#!/usr/bin/env fish

# List Fish Helpers Function
#
# Purpose: Display all available Fish functions and abbreviations
# Dependencies: fish, functions, abbr, awk, grep
# Related: fish.nix, fish-greeting.fish
#
# This function:
# - Lists all custom Fish functions
# - Shows all Fish abbreviations
# - Provides usage tips for discovery
# - Formats output for readability

function list-fish-helpers
    set_color blue; echo "[FISH] Fish Helpers & Shortcuts"; set_color normal
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # List custom functions (filter for our specific functions)
    set_color green; echo "[INFO] Custom Functions:"; set_color normal
    functions | grep -E "(nix-shell-unfree|fish-greeting|list-fish-helpers|nixos-commit-rebuild-push|nixos-rebuild-basic|dev-to-main|nixos-flake-update|fix-fish-history|cnup|sillytavern|show-shortcuts)" | sort | awk '{print "   • " $0}'

    echo ""
    set_color green; echo "[INFO] All Abbreviations:"; set_color normal
    abbr --list | sort | awk '{print "   • " $0}'

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color cyan; echo "[INFO] Tips:"; set_color normal
    echo "   Type 'type <name>' to see definition"
    echo "   Type 'fixhist' to repair corrupt history"
    echo "   Run this function: list-fish-helpers"
end
