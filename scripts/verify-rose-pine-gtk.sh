#!/usr/bin/env bash

# Rose Pine GTK Theme Verification Script
# This script checks if Rose Pine theming is properly applied across GTK applications

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Rose Pine colors
ROSE_PINE_BASE="#191724"
ROSE_PINE_SURFACE="#1f1d2e"
ROSE_PINE_TEXT="#e0def4"
ROSE_PINE_ROSE="#ebbcba"

print_header() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         Rose Pine GTK Theme Verification                     ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${BLUE}▶ $1${NC}"
    echo "────────────────────────────────────────────────────────────────────────────────"
}

check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
        return 0
    else
        echo -e "${RED}✗ $1${NC}"
        return 1
    fi
}

check_file_exists() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓ Found: $1${NC}"
        return 0
    else
        echo -e "${RED}✗ Missing: $1${NC}"
        return 1
    fi
}

check_package_installed() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓ $1 is installed${NC}"
        return 0
    else
        echo -e "${RED}✗ $1 is not installed${NC}"
        return 1
    fi
}

print_header

# Check GTK theme files
print_section "Checking GTK Theme Files"
check_file_exists "$HOME/.config/gtk-3.0/settings.ini"
check_file_exists "$HOME/.config/gtk-4.0/settings.ini"
check_file_exists "$HOME/.config/gtk-3.0/gtk.css"
check_file_exists "$HOME/.config/gtk-4.0/gtk.css"

# Check dconf settings
print_section "Checking dconf Settings"
if command -v dconf &> /dev/null; then
    GTK_THEME=$(dconf read /org/gnome/desktop/interface/gtk-theme 2>/dev/null | tr -d "'")
    ICON_THEME=$(dconf read /org/gnome/desktop/interface/icon-theme 2>/dev/null | tr -d "'")
    CURSOR_THEME=$(dconf read /org/gnome/desktop/interface/cursor-theme 2>/dev/null | tr -d "'")

    echo "Current GTK theme: ${GTK_THEME:-"not set"}"
    echo "Current icon theme: ${ICON_THEME:-"not set"}"
    echo "Current cursor theme: ${CURSOR_THEME:-"not set"}"

    if [[ "$GTK_THEME" == *"rose-pine"* ]]; then
        echo -e "${GREEN}✓ Rose Pine GTK theme is active${NC}"
    else
        echo -e "${YELLOW}⚠ Rose Pine GTK theme may not be active${NC}"
    fi
else
    echo -e "${YELLOW}⚠ dconf not available, cannot check system settings${NC}"
fi

# Check environment variables
print_section "Checking Environment Variables"
echo "QT_QPA_PLATFORMTHEME: ${QT_QPA_PLATFORMTHEME:-"not set"}"
echo "QT_STYLE_OVERRIDE: ${QT_STYLE_OVERRIDE:-"not set"}"
echo "GTK_THEME: ${GTK_THEME:-"not set"}"

# Check required packages
print_section "Checking Required Packages"
check_package_installed "nwg-look"
check_package_installed "dconf"

# Check Rose Pine theme package
print_section "Checking Rose Pine Theme Package"
if nix-store --query --references ~/.nix-profile | grep -q "rose-pine-gtk-theme" 2>/dev/null; then
    echo -e "${GREEN}✓ Rose Pine GTK theme package is installed${NC}"
else
    echo -e "${YELLOW}⚠ Rose Pine GTK theme package may not be installed${NC}"
fi

# Check GTK settings content
print_section "Verifying GTK Settings Content"
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    if grep -q "rose-pine" "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null; then
        echo -e "${GREEN}✓ GTK 3 settings contain Rose Pine theme${NC}"
    else
        echo -e "${YELLOW}⚠ GTK 3 settings may not contain Rose Pine theme${NC}"
    fi
fi

if [ -f "$HOME/.config/gtk-4.0/settings.ini" ]; then
    if grep -q "rose-pine" "$HOME/.config/gtk-4.0/settings.ini" 2>/dev/null; then
        echo -e "${GREEN}✓ GTK 4 settings contain Rose Pine theme${NC}"
    else
        echo -e "${YELLOW}⚠ GTK 4 settings may not contain Rose Pine theme${NC}"
    fi
fi

# Test theme application
print_section "Testing Theme Application"
if command -v gsettings &> /dev/null; then
    echo "Applying Rose Pine theme via gsettings..."
    gsettings set org.gnome.desktop.interface gtk-theme 'rose-pine-gtk-theme' 2>/dev/null && \
        check_status "Applied GTK theme via gsettings"
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null && \
        check_status "Applied icon theme via gsettings"
    gsettings set org.gnome.desktop.interface cursor-theme 'rose-pine-hyprcursor' 2>/dev/null && \
        check_status "Applied cursor theme via gsettings"
else
    echo -e "${YELLOW}⚠ gsettings not available${NC}"
fi

# Check Hyprland cursor settings
print_section "Checking Hyprland Cursor Settings"
if pgrep -x "Hyprland" > /dev/null; then
    echo -e "${GREEN}✓ Hyprland is running${NC}"
    if command -v hyprctl &> /dev/null; then
        echo "Setting cursor theme via hyprctl..."
        hyprctl setcursor rose-pine-hyprcursor 24 2>/dev/null && \
            check_status "Applied cursor via hyprctl"
    else
        echo -e "${YELLOW}⚠ hyprctl not available${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Hyprland is not running${NC}"
fi

# Summary
print_section "Theme Application Summary"
echo -e "${PURPLE}To ensure Rose Pine theming is fully applied:${NC}"
echo "1. Restart any open GTK applications"
echo "2. Log out and log back in for system-wide changes"
echo "3. Use 'nwg-look' to visually verify theme application"
echo "4. Check Dolphin and other Qt applications for consistent theming"

echo -e "\n${PURPLE}Quick theme refresh commands:${NC}"
echo "• Reload GTK theme: nwg-look"
echo "• Reload cursor: hyprctl setcursor rose-pine-hyprcursor 24"
echo "• Reload dconf: dconf reset -f /org/gnome/desktop/interface/"

echo -e "\n${GREEN}Rose Pine GTK theme verification completed!${NC}"
