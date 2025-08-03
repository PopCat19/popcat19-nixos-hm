#!/usr/bin/env bash

set -euo pipefail

SCRIPT_VERSION="2.0.0"
CONFIG_DIR="$HOME/.config"
NIXOS_CONFIG_DIR="$HOME/nixos-config"
VERBOSE=false
SHOW_FIX_SUGGESTIONS=false

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;37m'
readonly NC='\033[0m'

readonly CHECK_MARK="✓"
readonly CROSS_MARK="✗"
readonly WARNING="⚠"
readonly INFO="ℹ"

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

print_header() {
    local title="$1"
    echo ""
    echo -e "${PURPLE}🌹 ${title}${NC}"
    echo -e "${PURPLE}$(printf '═%.0s' $(seq 1 ${#title}))${NC}"
}

print_section() {
    local title="$1"
    echo ""
    echo -e "${BLUE}$title${NC}"
}

print_check() {
    local status="$1"
    local message="$2"
    local details="$3"

    ((TOTAL_CHECKS++))

    case "$status" in
        "PASS")
            echo -e "${GREEN}${CHECK_MARK} ${message}${NC}"
            if [ -n "$details" ]; then
                echo -e "    ${GRAY}${details}${NC}"
            fi
            ((PASSED_CHECKS++))
            ;;
        "FAIL")
            echo -e "${RED}${CROSS_MARK} ${message}${NC}"
            if [ -n "$details" ]; then
                echo -e "    ${RED}${details}${NC}"
            fi
            ((FAILED_CHECKS++))
            ;;
        "WARN")
            echo -e "${YELLOW}${WARNING} ${message}${NC}"
            if [ -n "$details" ]; then
                echo -e "    ${YELLOW}${details}${NC}"
            fi
            ((WARNING_CHECKS++))
            ;;
        "INFO")
            echo -e "${CYAN}${INFO} ${message}${NC}"
            if [ -n "$details" ]; then
                echo -e "    ${CYAN}${details}${NC}"
            fi
            ;;
    esac
}

check_environment_variables() {
    print_section "Environment Variables"

    if [[ "${QT_QPA_PLATFORMTHEME:-}" == "qt6ct" ]]; then
        print_check "PASS" "QT_QPA_PLATFORMTHEME correctly set" "qt6ct"
    else
        print_check "FAIL" "QT_QPA_PLATFORMTHEME incorrect" "Expected: qt6ct, Got: ${QT_QPA_PLATFORMTHEME:-unset}"
    fi

    if [[ "${QT_STYLE_OVERRIDE:-}" == "kvantum" ]]; then
        print_check "PASS" "QT_STYLE_OVERRIDE correctly set" "kvantum"
    else
        print_check "FAIL" "QT_STYLE_OVERRIDE incorrect" "Expected: kvantum, Got: ${QT_STYLE_OVERRIDE:-unset}"
    fi

    if [[ "${GTK_THEME:-}" == "Rose-Pine-Main-BL" ]]; then
        print_check "PASS" "GTK_THEME correctly set" "Rose-Pine-Main-BL"
    else
        print_check "WARN" "GTK_THEME incorrect" "Expected: Rose-Pine-Main-BL, Got: ${GTK_THEME:-unset}"
    fi

    if [[ "${XCURSOR_THEME:-}" == "rose-pine-hyprcursor" ]]; then
        print_check "PASS" "XCURSOR_THEME correctly set" "rose-pine-hyprcursor"
    else
        print_check "WARN" "XCURSOR_THEME incorrect" "Expected: rose-pine-hyprcursor, Got: ${XCURSOR_THEME:-unset}"
    fi
}

check_packages() {
    print_section "Package Availability"

    for pkg in kitty fuzzel micro dolphin qt6ct kvantummanager nwg-look; do
        if command -v "$pkg" &> /dev/null; then
            print_check "PASS" "$pkg available"
        else
            print_check "FAIL" "$pkg not found"
        fi
    done
}

check_theme_files() {
    print_section "Theme Files and Configuration"

    if [[ -d "$HOME/.config/Kvantum/RosePine" ]]; then
        print_check "PASS" "Kvantum Rose Pine theme directory found"
        if [[ -f "$HOME/.config/Kvantum/RosePine/rose-pine-rose.kvconfig" ]]; then
            print_check "PASS" "Rose Pine Kvantum config found"
        else
            print_check "WARN" "Rose Pine Kvantum config missing"
        fi
    else
        print_check "FAIL" "Kvantum Rose Pine theme directory missing" "$HOME/.config/Kvantum/RosePine"
    fi

    if [[ -f "$HOME/.config/kdeglobals" ]]; then
        if grep -q "ColorScheme=Rose-Pine-Main-BL" "$HOME/.config/kdeglobals" 2>/dev/null; then
            print_check "PASS" "kdeglobals Rose Pine configured"
        else
            print_check "WARN" "kdeglobals exists but may not be Rose Pine"
        fi
    else
        print_check "FAIL" "kdeglobals missing"
    fi

    if [[ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]]; then
        if grep -q "theme=rose-pine-rose" "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null; then
            print_check "PASS" "Kvantum Rose Pine theme configured"
        else
            print_check "WARN" "Kvantum config exists but theme may not be Rose Pine"
        fi
    else
        print_check "FAIL" "Kvantum config missing"
    fi

    if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
        if grep -q "style=kvantum" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null; then
            print_check "PASS" "Qt6ct Kvantum style configured"
        else
            print_check "WARN" "Qt6ct exists but style may not be Kvantum"
        fi
    else
        print_check "FAIL" "Qt6ct config missing"
    fi
}

check_fonts() {
    print_section "Font Installation"

    if command -v fc-list &> /dev/null; then
        print_check "PASS" "fontconfig available" "$(fc-list | wc -l) fonts detected"

        if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
            print_check "PASS" "JetBrainsMono Nerd Font installed"
        else
            print_check "FAIL" "JetBrainsMono Nerd Font not found" "Required from nerd-fonts.jetbrains-mono package"
        fi

        if fc-list | grep -qi "Rounded Mplus 1c"; then
            print_check "PASS" "Rounded Mplus 1c font installed"
        else
            print_check "FAIL" "Rounded Mplus 1c font not found" "Required from pkgs.google-fonts (system-level dependency)"
        fi

        if fc-list | grep -qi "Noto Sans"; then
            print_check "PASS" "Noto Sans fonts installed"
        else
            print_check "FAIL" "Noto Sans fonts not found" "Required from noto-fonts packages"
        fi

        if fc-list | grep -qi "Font Awesome"; then
            print_check "PASS" "Font Awesome icons installed"
        else
            print_check "WARN" "Font Awesome icons not found" "May affect UI icon display"
        fi
    else
        print_check "FAIL" "fontconfig not available"
    fi
}

show_troubleshooting() {
    print_section "Troubleshooting Tips"

    echo -e "${YELLOW}If theming is not working:${NC}"
    echo "1. Run kvantummanager and select Rose Pine theme"
    echo "2. Restart KDE applications: pkill dolphin && dolphin &"
    echo "3. Logout and login to reload environment variables"
    echo "4. Check Home Manager rebuild: home-manager switch"
    echo ""
    echo -e "${YELLOW}Font troubleshooting:${NC}"
    echo "• TESTING: google-fonts moved to user-level (home-theme.nix)"
    echo "• JetBrainsMono requires nerd-fonts.jetbrains-mono in home-theme.nix"
    echo "• Run 'fc-list | grep -i \"mplus\"' to verify font installation"
    echo "• Check both home-theme.nix and /etc/nixos/configuration.nix for fonts"
    echo ""
    echo -e "${YELLOW}Manual theme tools:${NC}"
    echo " kvantummanager - Kvantum theme manager"
    echo " qt6ct - Qt6 configuration tool"
    echo " nwg-look - GTK theme manager"
    echo ""
}

print_summary() {
    print_header "Diagnostic Summary"

    local pass_percent=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        pass_percent=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi

    echo -e "${WHITE}Total Checks: $TOTAL_CHECKS${NC}"
    echo -e "${GREEN}Passed: $PASSED_CHECKS ($pass_percent%)${NC}"
    echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo ""

    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All critical checks passed! Your Rose Pine theme setup looks good.${NC}"
    elif [[ $FAILED_CHECKS -lt 5 ]]; then
        echo -e "${YELLOW}⚠️  Minor issues detected. Review failed checks above.${NC}"
    else
        echo -e "${RED}❌ Multiple issues detected. Consider running manual fixes.${NC}"
    fi
    echo ""
}

main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --fix-suggestions|-f)
                SHOW_FIX_SUGGESTIONS=true
                shift
                ;;
            --version)
                echo "Rose Pine Theme Diagnostic Tool v$SCRIPT_VERSION"
                exit 0
                ;;
            --help|-h)
                echo "Usage: check-rose-pine-theme [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --verbose, -v           Show detailed output"
                echo "  --fix-suggestions, -f   Show fix suggestions for issues"
                echo "  --version              Show version information"
                echo "  --help, -h             Show this help message"
                echo ""
                echo "This script performs comprehensive checks of your Rose Pine theme setup."
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done

    print_header "Rose Pine Theme Diagnostic Tool"
    echo -e "${CYAN}Version: $SCRIPT_VERSION${NC}"
    echo -e "${CYAN}Checking Rose Pine theme integration...${NC}"

    check_environment_variables
    check_packages
    check_theme_files
    check_fonts

    if [[ $FAILED_CHECKS -gt 0 ]] || [[ $WARNING_CHECKS -gt 3 ]]; then
        show_troubleshooting
    fi

    print_summary

    if [[ $FAILED_CHECKS -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"