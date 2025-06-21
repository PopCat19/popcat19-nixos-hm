#!/usr/bin/env bash

# HyDE-nix Theme Integration Script
# This script helps integrate the "stolen" hydenix fastfetch and Rose Pine GTK configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Rose Pine colors
RP_LOVE='\033[38;2;235;111;146m'
RP_GOLD='\033[38;2;246;193;119m'
RP_FOAM='\033[38;2;156;207;216m'
RP_IRIS='\033[38;2;196;167;231m'
RP_TEXT='\033[38;2;224;222;244m'

print_header() {
    echo -e "${RP_FOAM}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  HyDE-nix Theme Integration                  ║"
    echo "║                    Rose Pine Configuration                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${RP_LOVE}[STEP $1]${NC} $2"
}

print_info() {
    echo -e "${RP_FOAM}[INFO]${NC} $1"
}

print_success() {
    echo -e "${RP_GOLD}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backed up $file"
    fi
}

check_dependencies() {
    print_step "1" "Checking dependencies..."

    local deps=("nix" "home-manager")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi

    print_success "All dependencies found"
}

check_directory() {
    print_step "2" "Checking directory structure..."

    if [[ ! -f "home.nix" ]]; then
        print_error "home.nix not found. Please run this script from your nixos-config directory."
        exit 1
    fi

    if [[ ! -d "fastfetch_config" ]]; then
        print_error "fastfetch_config directory not found."
        exit 1
    fi

    if [[ ! -d "gtk_config" ]]; then
        print_error "gtk_config directory not found."
        exit 1
    fi

    print_success "Directory structure looks good"
}

update_home_nix() {
    print_step "3" "Updating home.nix configuration..."

    backup_file "home.nix"

    # Check if gtk_config import already exists
    if grep -q "gtk_config/rose-pine-theme.nix" home.nix; then
        print_info "GTK theme module already imported"
    else
        print_info "Adding GTK theme module import..."
        # This is a placeholder - user will need to manually add the import
        print_warning "Please manually add './gtk_config/rose-pine-theme.nix' to your imports in home.nix"
    fi

    # Check if fastfetch config is enabled
    if grep -q "home.file.\".config/fastfetch\"" home.nix; then
        print_info "Fastfetch configuration already enabled"
    else
        print_warning "Please manually enable fastfetch configuration in home.nix"
        echo -e "${RP_TEXT}Add this to your home.nix:${NC}"
        echo -e "${RP_IRIS}  home.file.\".config/fastfetch\" = {${NC}"
        echo -e "${RP_IRIS}    source = ./fastfetch_config;${NC}"
        echo -e "${RP_IRIS}    recursive = true;${NC}"
        echo -e "${RP_IRIS}  };${NC}"
    fi
}

test_fastfetch() {
    print_step "4" "Testing fastfetch configuration..."

    if command -v fastfetch &> /dev/null; then
        print_info "Testing fastfetch with new configuration..."

        # Test with default config
        echo -e "${RP_FOAM}Testing default fastfetch:${NC}"
        fastfetch --config ~/.config/fastfetch/config.jsonc 2>/dev/null || {
            print_warning "Fastfetch test failed - config may not be applied yet"
        }

        # Test with custom logo if it exists
        if [[ -f "fastfetch_config/logos/rose-pine-nixos.txt" ]]; then
            echo -e "${RP_FOAM}Testing with custom Rose Pine logo:${NC}"
            fastfetch --logo fastfetch_config/logos/rose-pine-nixos.txt 2>/dev/null || {
                print_warning "Custom logo test failed"
            }
        fi

        print_success "Fastfetch tests completed"
    else
        print_warning "Fastfetch not installed - will be available after rebuild"
    fi
}

rebuild_system() {
    print_step "5" "Rebuilding Home Manager configuration..."

    print_info "Running home-manager switch..."

    if home-manager switch --flake . ; then
        print_success "Home Manager rebuild successful"
    else
        print_error "Home Manager rebuild failed"
        print_info "You may need to run: sudo nixos-rebuild switch --flake ."
        return 1
    fi
}

test_theming() {
    print_step "6" "Testing theme integration..."

    # Test fastfetch
    if command -v fastfetch &> /dev/null; then
        echo -e "${RP_FOAM}Final fastfetch test:${NC}"
        fastfetch
        print_success "Fastfetch working with Rose Pine theme"
    fi

    # Test GTK tools
    local gtk_tools=("nwg-look" "kvantummanager")
    for tool in "${gtk_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_success "$tool is available"
        else
            print_warning "$tool not found - may not be installed yet"
        fi
    done

    # Check theme files
    if [[ -f "$HOME/.config/fastfetch/config.jsonc" ]]; then
        print_success "Fastfetch config deployed"
    else
        print_warning "Fastfetch config not found in home directory"
    fi

    if [[ -f "$HOME/.config/kdeglobals" ]]; then
        print_success "KDE globals config deployed"
    else
        print_warning "KDE globals config not found"
    fi
}

show_post_install() {
    echo -e "${RP_FOAM}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     Integration Complete!                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${RP_TEXT}Next steps:${NC}"
    echo -e "${RP_LOVE}1.${NC} Open a new terminal to see the fastfetch greeting"
    echo -e "${RP_LOVE}2.${NC} Run ${RP_IRIS}nwg-look${NC} to verify GTK theming"
    echo -e "${RP_LOVE}3.${NC} Run ${RP_IRIS}kvantummanager${NC} to verify Qt theming"
    echo -e "${RP_LOVE}4.${NC} Test various applications to see Rose Pine theming"
    echo ""
    echo -e "${RP_TEXT}Useful commands:${NC}"
    echo -e "${RP_FOAM}fastfetch${NC}                          - Show system info"
    echo -e "${RP_FOAM}fastfetch --logo path/to/logo.txt${NC}  - Use custom logo"
    echo -e "${RP_FOAM}nwg-look${NC}                           - GTK theme manager"
    echo -e "${RP_FOAM}kvantummanager${NC}                     - Qt theme manager"
    echo ""
    echo -e "${RP_TEXT}Configuration files:${NC}"
    echo -e "${RP_IRIS}~/.config/fastfetch/config.jsonc${NC}  - Fastfetch config"
    echo -e "${RP_IRIS}~/.config/kdeglobals${NC}              - KDE theme config"
    echo -e "${RP_IRIS}~/.config/Kvantum/kvantum.kvconfig${NC} - Kvantum config"
    echo ""
    echo -e "${RP_GOLD}Enjoy your Rose Pine themed system! 🌹${NC}"
}

main() {
    print_header

    # Run integration steps
    check_dependencies
    check_directory
    update_home_nix

    # Ask user if they want to rebuild
    echo -e "${RP_TEXT}Do you want to rebuild Home Manager now? ${RP_FOAM}[y/N]${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        rebuild_system
        test_theming
    else
        print_info "Skipping rebuild. Run 'home-manager switch --flake .' when ready."
    fi

    test_fastfetch
    show_post_install
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
