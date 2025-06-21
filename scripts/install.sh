#!/usr/bin/env bash
# NixOS Configuration Installation Script
#
# This script helps new users set up the NixOS configuration flake
# Run with: bash install.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
REPO_URL="https://github.com/user/nixos-config.git"  # Update this
INSTALL_DIR="/etc/nixos"
BACKUP_DIR="$HOME/nixos-backup-$(date +%Y%m%d-%H%M%S)"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this script as root. It will use sudo when needed."
        exit 1
    fi
}

check_nixos() {
    if [[ ! -f /etc/os-release ]] || ! grep -q "ID=nixos" /etc/os-release; then
        log_error "This script is designed for NixOS only."
        exit 1
    fi
}

check_flakes() {
    if ! nix --version | grep -q "nix"; then
        log_error "Nix is not installed or not in PATH."
        exit 1
    fi

    if ! nix eval --expr '(builtins.getFlake "github:nixos/nixpkgs").lib.version' 2>/dev/null; then
        log_warning "Flakes might not be enabled. Enable them in configuration.nix:"
        echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"
    fi
}

backup_existing() {
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "Backing up existing configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        sudo cp -r "$INSTALL_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
        sudo chown -R "$USER:$USER" "$BACKUP_DIR"
        log_success "Backup created at $BACKUP_DIR"
    fi
}

get_user_input() {
    log_info "Please provide the following information:"

    read -p "Enter your username: " USERNAME
    read -p "Enter your hostname: " HOSTNAME
    read -p "Enter your email for git: " EMAIL

    # Validate input
    if [[ -z "$USERNAME" || -z "$HOSTNAME" || -z "$EMAIL" ]]; then
        log_error "All fields are required."
        exit 1
    fi

    # Confirm
    echo
    log_info "Configuration summary:"
    echo "  Username: $USERNAME"
    echo "  Hostname: $HOSTNAME"
    echo "  Email: $EMAIL"
    echo

    read -p "Continue with this configuration? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi
}

clone_repository() {
    log_info "Cloning configuration repository..."

    # Remove existing directory if it exists
    if [[ -d "$INSTALL_DIR" ]]; then
        sudo rm -rf "$INSTALL_DIR"
    fi

    # Clone repository
    sudo git clone "$REPO_URL" "$INSTALL_DIR"
    sudo chown -R root:root "$INSTALL_DIR"

    log_success "Repository cloned to $INSTALL_DIR"
}

generate_hardware_config() {
    log_info "Generating hardware configuration..."

    # Generate new hardware configuration
    sudo nixos-generate-config --root /

    # Copy hardware configuration to our directory
    sudo cp /etc/nixos/hardware-configuration.nix "$INSTALL_DIR/"

    log_success "Hardware configuration generated"
}

update_configuration() {
    log_info "Updating configuration files..."

    # Update flake.nix
    sudo sed -i "s/hostname = \".*\";/hostname = \"$HOSTNAME\";/" "$INSTALL_DIR/flake.nix"
    sudo sed -i "s/username = \".*\";/username = \"$USERNAME\";/" "$INSTALL_DIR/flake.nix"

    # Update home.nix
    sudo sed -i "s/home.username = \".*\";/home.username = \"$USERNAME\";/" "$INSTALL_DIR/home.nix"
    sudo sed -i "s|home.homeDirectory = \"/home/.*\";|home.homeDirectory = \"/home/$USERNAME\";|" "$INSTALL_DIR/home.nix"

    # Update git configuration
    sudo sed -i "s/userEmail = \".*\";/userEmail = \"$EMAIL\";/" "$INSTALL_DIR/home.nix"
    sudo sed -i "s/userName = \".*\";/userName = \"$USERNAME\";/" "$INSTALL_DIR/home.nix"

    log_success "Configuration files updated"
}

build_system() {
    log_info "Building NixOS configuration..."
    log_warning "This may take a while on first build..."

    cd "$INSTALL_DIR"

    # Update flake lock
    sudo nix flake update

    # Build and switch
    if sudo nixos-rebuild switch --flake ".#$HOSTNAME"; then
        log_success "System built and activated successfully!"
    else
        log_error "System build failed. Check the error messages above."
        log_info "You can try to fix issues and run:"
        echo "  cd $INSTALL_DIR"
        echo "  sudo nixos-rebuild switch --flake .#$HOSTNAME"
        exit 1
    fi
}

install_theme() {
    log_info "Installing Rose Pine theme..."

    # Create themes directory
    mkdir -p "$HOME/.local/share/themes"

    # Download Rose Pine theme if not present
    if [[ ! -d "$HOME/.local/share/themes/Rosepine-Dark" ]]; then
        log_info "Downloading Rose Pine theme..."
        # This would download the theme - adjust URL as needed
        # For now, just create a placeholder
        mkdir -p "$HOME/.local/share/themes/Rosepine-Dark"
        log_warning "Rose Pine theme directory created. You may need to install the actual theme files."
    fi

    # Apply theme
    if command -v nwg-look >/dev/null 2>&1; then
        nwg-look -a
        log_success "Theme applied"
    else
        log_warning "nwg-look not found. Theme will be applied after reboot."
    fi
}

cleanup() {
    log_info "Cleaning up..."

    # Remove any temporary files
    sudo nix-collect-garbage -d >/dev/null 2>&1 || true

    log_success "Cleanup completed"
}

show_next_steps() {
    log_success "Installation completed successfully!"
    echo
    log_info "Next steps:"
    echo "1. Reboot your system to ensure all changes take effect"
    echo "2. Log in and check that theming is applied correctly"
    echo "3. Customize the configuration in $INSTALL_DIR"
    echo "4. Read the README and QUICKREF files for usage information"
    echo
    log_info "Useful commands:"
    echo "  sudo nixos-rebuild switch --flake $INSTALL_DIR#$HOSTNAME  # Apply changes"
    echo "  nix flake update                                           # Update packages"
    echo "  fastfetch                                                  # Check system info"
    echo "  nwg-look -a                                               # Apply GTK theme"
    echo
    log_info "Configuration backup: $BACKUP_DIR"
    log_info "Have fun with your new NixOS setup!"
}

main() {
    log_info "NixOS Configuration Installation Script"
    echo "========================================"

    # Checks
    check_root
    check_nixos
    check_flakes

    # Backup existing configuration
    backup_existing

    # Get user input
    get_user_input

    # Installation steps
    clone_repository
    generate_hardware_config
    update_configuration
    build_system
    install_theme
    cleanup

    # Show completion message
    show_next_steps
}

# Handle interrupts
trap 'log_error "Installation interrupted"; exit 1' INT TERM

# Run main function
main "$@"
