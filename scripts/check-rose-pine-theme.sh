#!/usr/bin/env bash

# Rose Pine Theme Status Checker
# Simple script to verify Rose Pine theming is working correctly

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE} Rose Pine Theme Status${NC}"
    echo -e "${PURPLE}══════════════════════════${NC}"
    echo ""
}

check_environment() {
    echo -e "${BLUE} Environment Variables${NC}"

    if [[ "${QT_QPA_PLATFORMTHEME:-}" == "qt6ct" ]]; then
        echo -e "${GREEN} QT_QPA_PLATFORMTHEME: qt6ct${NC}"
    else
        echo -e "${RED} QT_QPA_PLATFORMTHEME: ${QT_QPA_PLATFORMTHEME:-unset} (should be 'qt6ct')${NC}"
    fi

    if [[ "${QT_STYLE_OVERRIDE:-}" == "kvantum" ]]; then
        echo -e "${GREEN} QT_STYLE_OVERRIDE: kvantum${NC}"
    else
        echo -e "${RED} QT_STYLE_OVERRIDE: ${QT_STYLE_OVERRIDE:-unset} (should be 'kvantum')${NC}"
    fi
    echo ""
}

check_theme_files() {
    echo -e "${BLUE} Theme Files${NC}"

    local rosepine_dir="$HOME/.config/Kvantum/RosePine"
    if [[ -d "$rosepine_dir" ]] || [[ -L "$rosepine_dir" ]]; then
        echo -e "${GREEN} Rose Pine theme directory found${NC}"
        if [[ -f "$rosepine_dir/rose-pine-rose.kvconfig" ]]; then
            echo -e "${GREEN} Rose Pine Kvantum config found${NC}"
        else
            echo -e "${YELLOW} Rose Pine Kvantum config missing${NC}"
        fi
    else
        echo -e "${RED} Rose Pine theme directory missing: $rosepine_dir${NC}"
    fi
    echo ""
}

check_configuration() {
    echo -e "${BLUE} Configuration Files${NC}"

    # Check kdeglobals
    if [[ -f "$HOME/.config/kdeglobals" ]]; then
        if grep -q "Name=RosePine" "$HOME/.config/kdeglobals" 2>/dev/null; then
            echo -e "${GREEN} kdeglobals: Rose Pine configured${NC}"
        else
            echo -e "${YELLOW} kdeglobals: exists but may not be Rose Pine${NC}"
        fi
    else
        echo -e "${RED} kdeglobals: missing${NC}"
    fi

    # Check Kvantum config
    if [[ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]]; then
        if grep -q "theme=rose-pine-rose" "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null; then
            echo -e "${GREEN} Kvantum: Rose Pine configured${NC}"
        else
            echo -e "${YELLOW} Kvantum: exists but theme may not be Rose Pine${NC}"
        fi
    else
        echo -e "${RED} Kvantum config: missing${NC}"
    fi

    # Check Qt6ct config
    if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
        if grep -q "style=kvantum" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null; then
            echo -e "${GREEN} Qt6ct: Kvantum style configured${NC}"
        else
            echo -e "${YELLOW} Qt6ct: exists but style may not be Kvantum${NC}"
        fi
    else
        echo -e "${RED} Qt6ct config: missing${NC}"
    fi
    echo ""
}

test_applications() {
    echo -e "${BLUE} Test Applications${NC}"

    if command -v dolphin &> /dev/null; then
        echo -e "${GREEN} Dolphin available${NC}"
        echo -e "${YELLOW}  Run 'dolphin' to test theming${NC}"
    else
        echo -e "${RED} Dolphin not found${NC}"
    fi

    if command -v kvantummanager &> /dev/null; then
        echo -e "${GREEN} Kvantum Manager available${NC}"
        echo -e "${YELLOW}  Run 'kvantummanager' for theme management${NC}"
    else
        echo -e "${YELLOW} Kvantum Manager not found${NC}"
    fi

    if command -v qt6ct &> /dev/null; then
        echo -e "${GREEN} Qt6ct available${NC}"
        echo -e "${YELLOW}  Run 'qt6ct' for Qt configuration${NC}"
    else
        echo -e "${YELLOW} Qt6ct not found${NC}"
    fi
    echo ""
}

show_troubleshooting() {
    echo -e "${BLUE} Troubleshooting Tips${NC}"
    echo ""
    echo -e "${YELLOW}If theming is not working:${NC}"
    echo "1. Restart KDE applications: pkill dolphin && dolphin &"
    echo "2. Logout and login to reload environment variables"
    echo "3. Restart Hyprland session"
    echo "4. Check Home Manager rebuild: home-manager switch"
    echo ""
    echo -e "${YELLOW}Manual theme tools:${NC}"
    echo " kvantummanager - Kvantum theme manager"
    echo " qt6ct - Qt6 configuration tool"
    echo " nwg-look - GTK theme configuration"
    echo ""
}

print_summary() {
    echo -e "${PURPLE} Summary${NC}"
    echo ""
    echo "Your system is configured for Rose Pine theming with:"
    echo " Rose Pine Kvantum theme for Qt applications"
    echo " KDE kdeglobals for Dolphin and KDE apps"
    echo " Qt6ct for Qt6 application theming"
    echo ""
    echo -e "${GREEN} Enjoy your Rose Pine themed desktop!${NC}"
}

main() {
    print_header
    check_environment
    check_theme_files
    check_configuration
    test_applications
    show_troubleshooting
    print_summary
}

main "$@"
