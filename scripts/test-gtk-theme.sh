#!/usr/bin/env bash

# Rose Pine GTK Theme Testing Script
# This script launches various GTK applications to test Rose Pine theming

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         Rose Pine GTK Theme Test Suite                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${BLUE}▶ $1${NC}"
    echo "────────────────────────────────────────────────────────────────────────────────"
}

test_app() {
    local app_name="$1"
    local app_command="$2"
    local description="$3"

    echo -e "${YELLOW}Testing: ${app_name}${NC}"
    echo "Description: ${description}"

    if command -v "${app_command%% *}" &> /dev/null; then
        echo -e "${GREEN}✓ ${app_name} is available${NC}"
        echo "Command: ${app_command}"
        echo "Run manually: ${app_command} &"
        echo ""
        return 0
    else
        echo -e "${RED}✗ ${app_name} is not installed${NC}"
        echo ""
        return 1
    fi
}

print_header

print_section "GTK Theme Testing Applications"
echo "The following applications will help you verify Rose Pine theming:"
echo ""

# GTK3 Applications
echo -e "${BLUE}GTK3 Applications:${NC}"
test_app "Nautilus (Files)" "nautilus" "GNOME file manager - shows headerbar, sidebar, and content theming"
test_app "Text Editor (gedit)" "gedit" "Simple text editor - shows text area and menu theming"
test_app "Calculator" "gnome-calculator" "GNOME calculator - shows button and window theming"
test_app "System Monitor" "gnome-system-monitor" "System monitor - shows list views and graphs"
test_app "Archive Manager" "file-roller" "Archive manager - shows file lists and toolbars"

# GTK4 Applications
echo -e "${BLUE}GTK4 Applications:${NC}"
test_app "Text Editor (GNOME)" "gnome-text-editor" "Modern GNOME text editor - shows GTK4 theming"
test_app "GNOME Control Center" "gnome-control-center" "System settings - shows modern GTK4 interface"
test_app "GNOME Disk Usage Analyzer" "baobab" "Disk usage analyzer - shows GTK4 visualizations"

# Theme Management Tools
echo -e "${BLUE}Theme Management Tools:${NC}"
test_app "nwg-look" "nwg-look" "GTK theme selector and configuration tool"
test_app "dconf Editor" "dconf-editor" "System configuration editor"

print_section "Theme Testing Instructions"
echo "1. Launch applications using the commands shown above"
echo "2. Look for Rose Pine colors:"
echo "   • Background: Dark purple (#191724)"
echo "   • Text: Light purple (#e0def4)"
echo "   • Accents: Pink/Rose (#ebbcba), Purple (#c4a7e7)"
echo "   • Selection: Iris purple (#c4a7e7)"
echo ""
echo "3. Check these elements:"
echo "   • Window headers and titlebars"
echo "   • Buttons and controls"
echo "   • Text selection"
echo "   • Menu and dropdown styling"
echo "   • Icon colors (should be light on dark)"
echo ""

print_section "Quick Theme Application Commands"
echo "If theming doesn't appear correct, try these commands:"
echo ""
echo "# Apply theme via dconf:"
echo "dconf write /org/gnome/desktop/interface/gtk-theme \"'rose-pine-gtk-theme'\""
echo "dconf write /org/gnome/desktop/interface/icon-theme \"'Papirus-Dark'\""
echo "dconf write /org/gnome/desktop/interface/cursor-theme \"'rose-pine-hyprcursor'\""
echo ""
echo "# Launch theme configuration tool:"
echo "nwg-look &"
echo ""
echo "# Restart GTK applications after theme changes"
echo ""

print_section "Troubleshooting Common Issues"
echo "1. ${YELLOW}Theme not applied:${NC}"
echo "   • Log out and log back in"
echo "   • Restart the application"
echo "   • Check if application is Flatpak (needs separate theming)"
echo ""
echo "2. ${YELLOW}Mixed themes:${NC}"
echo "   • Some apps may have their own theme settings"
echo "   • Check application preferences"
echo "   • Verify environment variables are set"
echo ""
echo "3. ${YELLOW}Icons not themed:${NC}"
echo "   • Ensure Papirus-Dark is selected"
echo "   • Some applications bundle their own icons"
echo "   • Check icon theme in nwg-look"
echo ""

print_section "Automatic Theme Testing"
echo "Launching key applications for visual verification..."
echo "Press Ctrl+C to stop, or wait 3 seconds to continue..."
sleep 3

# Launch applications in background for testing
if command -v nautilus &> /dev/null; then
    echo "Launching Nautilus..."
    nautilus &
    sleep 1
fi

if command -v nwg-look &> /dev/null; then
    echo "Launching nwg-look..."
    nwg-look &
    sleep 1
fi

if command -v gedit &> /dev/null; then
    echo "Launching gedit..."
    gedit &
    sleep 1
fi

echo ""
echo -e "${GREEN}Theme testing applications launched!${NC}"
echo "Check each application window for proper Rose Pine theming."
echo "Close applications when testing is complete."
echo ""
echo -e "${PURPLE}Rose Pine GTK theme testing completed!${NC}"
