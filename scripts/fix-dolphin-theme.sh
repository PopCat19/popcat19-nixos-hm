#!/usr/bin/env bash

# Simple Rose Pine Dolphin Theming Fix
# Focuses on making Dolphin respect Rose Pine theme in Hyprland
# Uses kdeglobals approach which is most reliable for Dolphin

set -euo pipefail

KDEGLOBALS_FILE="$HOME/.config/kdeglobals"
KVANTUM_CONFIG="$HOME/.config/Kvantum/kvantum.kvconfig"
QT6CT_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🌹 Rose Pine Dolphin Theme Fix${NC}"
    echo -e "${BLUE}═══════════════════════════════${NC}"
    echo ""
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backed up: $file${NC}"
    fi
}

create_rose_pine_kdeglobals() {
    echo -e "${YELLOW}Creating Rose Pine kdeglobals...${NC}"

    backup_file "$KDEGLOBALS_FILE"

    mkdir -p "$(dirname "$KDEGLOBALS_FILE")"

    cat > "$KDEGLOBALS_FILE" << 'EOF'
[ColorScheme]
Name=RosePine

[Colors:Button]
BackgroundAlternate=49,46,77
BackgroundNormal=49,46,77
DecorationFocus=156,207,216
DecorationHover=156,207,216
ForegroundActive=224,222,244
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Complementary]
BackgroundAlternate=49,46,77
BackgroundNormal=25,23,36
DecorationFocus=156,207,216
DecorationHover=156,207,216
ForegroundActive=224,222,244
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Selection]
BackgroundAlternate=156,207,216
BackgroundNormal=156,207,216
DecorationFocus=156,207,216
DecorationHover=156,207,216
ForegroundActive=25,23,36
ForegroundInactive=25,23,36
ForegroundLink=25,23,36
ForegroundNegative=25,23,36
ForegroundNeutral=25,23,36
ForegroundNormal=25,23,36
ForegroundPositive=25,23,36
ForegroundVisited=25,23,36

[Colors:Tooltip]
BackgroundAlternate=49,46,77
BackgroundNormal=49,46,77
DecorationFocus=156,207,216
DecorationHover=156,207,216
ForegroundActive=224,222,244
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:View]
BackgroundAlternate=31,29,46
BackgroundNormal=25,23,36
DecorationFocus=156,207,216
DecorationHover=156,207,216
ForegroundActive=224,222,244
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Window]
BackgroundAlternate=49,46,77
BackgroundNormal=25,23,36
DecorationFocus=156,207,216
DecorationHover=156,207,216
ForegroundActive=224,222,244
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[General]
ColorScheme=RosePine
Name=Rose Pine
shadeSortColumn=true

[KDE]
contrast=4
widgetStyle=kvantum

[WM]
activeBackground=49,46,77
activeForeground=224,222,244
inactiveBackground=25,23,36
inactiveForeground=144,140,170
activeBlend=156,207,216
inactiveBlend=110,106,134

[Icons]
Theme=Papirus-Dark
EOF

    echo -e "${GREEN}✓ Rose Pine kdeglobals created${NC}"
}

ensure_kvantum_config() {
    echo -e "${YELLOW}Ensuring Kvantum configuration...${NC}"

    mkdir -p "$(dirname "$KVANTUM_CONFIG")"

    if [[ ! -f "$KVANTUM_CONFIG" ]] || ! grep -q "RosePine" "$KVANTUM_CONFIG"; then
        backup_file "$KVANTUM_CONFIG"

        cat > "$KVANTUM_CONFIG" << 'EOF'
[General]
theme=RosePine

[Applications]
dolphin=RosePine
ark=RosePine
gwenview=RosePine
systemsettings=RosePine
kate=RosePine
kwrite=RosePine
konsole=RosePine
EOF
        echo -e "${GREEN}✓ Kvantum config updated${NC}"
    else
        echo -e "${GREEN}✓ Kvantum config already correct${NC}"
    fi
}

ensure_qt6ct_config() {
    echo -e "${YELLOW}Ensuring Qt6ct configuration...${NC}"

    mkdir -p "$(dirname "$QT6CT_CONFIG")"

    backup_file "$QT6CT_CONFIG"

    cat > "$QT6CT_CONFIG" << 'EOF'
[Appearance]
color_scheme_path=/home/popcat19/.config/Kvantum/RosePine/RosePine.kvconfig
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed="CaskaydiaCove Nerd Font,11,-1,5,50,0,0,0,0,0"
general="CaskaydiaCove Nerd Font,11,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

    echo -e "${GREEN}✓ Qt6ct config updated${NC}"
}

restart_kde_apps() {
    echo -e "${YELLOW}Restarting KDE applications...${NC}"

    # Kill KDE applications to force theme reload
    pkill -f dolphin 2>/dev/null || true
    pkill -f ark 2>/dev/null || true
    pkill -f gwenview 2>/dev/null || true
    pkill -f systemsettings 2>/dev/null || true
    pkill -f kate 2>/dev/null || true
    pkill -f kwrite 2>/dev/null || true

    # Wait for processes to terminate
    sleep 2

    echo -e "${GREEN}✓ KDE applications restarted${NC}"
}

check_environment() {
    echo -e "${YELLOW}Checking environment variables...${NC}"

    local env_ok=true

    if [[ "${QT_QPA_PLATFORMTHEME:-}" != "qt6ct" ]]; then
        echo -e "${RED}✗ QT_QPA_PLATFORMTHEME should be 'qt6ct' (current: ${QT_QPA_PLATFORMTHEME:-unset})${NC}"
        env_ok=false
    else
        echo -e "${GREEN}✓ QT_QPA_PLATFORMTHEME is correct${NC}"
    fi

    if [[ "${QT_STYLE_OVERRIDE:-}" != "kvantum" ]]; then
        echo -e "${RED}✗ QT_STYLE_OVERRIDE should be 'kvantum' (current: ${QT_STYLE_OVERRIDE:-unset})${NC}"
        env_ok=false
    else
        echo -e "${GREEN}✓ QT_STYLE_OVERRIDE is correct${NC}"
    fi

    if [[ "$env_ok" == false ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  Environment variables are not correctly set${NC}"
        echo -e "${YELLOW}   Make sure your NixOS configuration sets:${NC}"
        echo -e "${YELLOW}   - QT_QPA_PLATFORMTHEME = \"qt6ct\";${NC}"
        echo -e "${YELLOW}   - QT_STYLE_OVERRIDE = \"kvantum\";${NC}"
        echo ""
    fi

    return $([[ "$env_ok" == true ]] && echo 0 || echo 1)
}

check_theme_dirs() {
    echo -e "${YELLOW}Checking theme directories...${NC}"

    local rosepine_dir="$HOME/.config/Kvantum/RosePine"

    if [[ -d "$rosepine_dir" ]]; then
        echo -e "${GREEN}✓ Rose Pine theme directory found${NC}"
        return 0
    else
        echo -e "${RED}✗ Rose Pine theme directory not found at: $rosepine_dir${NC}"
        echo -e "${YELLOW}   Please ensure rose-pine-kvantum is installed via Home Manager${NC}"
        return 1
    fi
}

test_dolphin() {
    echo -e "${YELLOW}Testing Dolphin theme application...${NC}"

    if command -v dolphin &> /dev/null; then
        echo -e "${BLUE}Starting Dolphin...${NC}"
        dolphin --new-window &
        sleep 2
        echo -e "${GREEN}✓ Dolphin started - check if Rose Pine theme is applied${NC}"
    else
        echo -e "${RED}✗ Dolphin not found${NC}"
        return 1
    fi
}

show_status() {
    echo -e "${BLUE}Current Theme Status:${NC}"
    echo ""

    # Check kdeglobals
    if [[ -f "$KDEGLOBALS_FILE" ]] && grep -q "RosePine" "$KDEGLOBALS_FILE"; then
        echo -e "${GREEN}✓ kdeglobals: Rose Pine configured${NC}"
    else
        echo -e "${RED}✗ kdeglobals: Not configured or missing${NC}"
    fi

    # Check Kvantum
    if [[ -f "$KVANTUM_CONFIG" ]] && grep -q "RosePine" "$KVANTUM_CONFIG"; then
        echo -e "${GREEN}✓ Kvantum: Rose Pine configured${NC}"
    else
        echo -e "${RED}✗ Kvantum: Not configured or missing${NC}"
    fi

    # Check Qt6ct
    if [[ -f "$QT6CT_CONFIG" ]] && grep -q "RosePine" "$QT6CT_CONFIG"; then
        echo -e "${GREEN}✓ Qt6ct: Rose Pine configured${NC}"
    else
        echo -e "${RED}✗ Qt6ct: Not configured or missing${NC}"
    fi

    echo ""
}

print_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  apply    Apply Rose Pine theme to Dolphin (default)"
    echo "  status   Show current theme status"
    echo "  test     Test Dolphin theme"
    echo "  check    Check environment and theme directories"
    echo "  help     Show this help"
}

main() {
    print_header

    case "${1:-apply}" in
        "apply")
            echo -e "${BLUE}Applying Rose Pine theme to Dolphin...${NC}"
            echo ""

            create_rose_pine_kdeglobals
            ensure_kvantum_config
            ensure_qt6ct_config
            restart_kde_apps

            echo ""
            echo -e "${GREEN}🎨 Rose Pine theme applied successfully!${NC}"
            echo ""
            echo -e "${YELLOW}Next steps:${NC}"
            echo "• Test with: $0 test"
            echo "• Check status: $0 status"
            echo "• Open Dolphin to verify theming"
            echo ""
            ;;
        "status")
            show_status
            ;;
        "test")
            test_dolphin
            ;;
        "check")
            echo -e "${BLUE}Checking configuration...${NC}"
            echo ""
            check_environment
            check_theme_dirs
            ;;
        "help"|"--help"|"-h")
            print_usage
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo ""
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
