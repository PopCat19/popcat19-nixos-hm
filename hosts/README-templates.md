# NixOS Host Configuration Templates

This directory contains template configurations for creating new NixOS machine configurations quickly and consistently.

## Files

- `minimal.nix` - Minimal system configuration template
- `home-minimal.nix` - Minimal Home Manager configuration template
- `README-templates.md` - This documentation file

## Quick Start

### 1. Create a New Host Configuration

```bash
# Copy the templates to create a new host
cp minimal.nix hosts/your-hostname.nix
cp home-minimal.nix hosts/your-hostname/home.nix

# Create the host directory if it doesn't exist
mkdir -p hosts/your-hostname
```

### 2. Customize the System Configuration

Edit `hosts/your-hostname.nix` and update:

```nix
# Change the hostname
hostname = "your-hostname-here";

# Set the correct system architecture
system = "x86_64-linux";  # or "aarch64-linux"

# Uncomment and customize imports as needed
# ./hardware-configuration.nix  # Add when you generate hardware config
```

### 3. Customize the Home Configuration

Edit `hosts/your-hostname/home.nix` and:

- Uncomment the modules you need
- Add host-specific configurations
- Customize packages if necessary

### 4. Add to Flake Configuration

Edit `flake.nix` and add your new host to `nixosConfigurations`:

```nix
nixosConfigurations = {
  # ... existing configurations
  "your-hostname" = hosts.mkHostConfig "your-hostname" "x86_64-linux" ./hosts/your-hostname.nix {
    inherit inputs nixpkgs modules;
  };
};
```

### 5. Generate Hardware Configuration (if needed)

For physical machines, generate the hardware configuration:

```bash
# On the target machine, generate hardware config
sudo nixos-generate-config --show-hardware-config > hosts/your-hostname/hardware-configuration.nix
```

### 6. Test the Configuration

```bash
# Test the configuration (dry run)
nixos-rebuild dry-run --flake .#your-hostname

# If successful, rebuild
sudo nixos-rebuild switch --flake .#your-hostname
```

## Template Features

### System Template (`minimal.nix`)

**Included by default:**
- Core system modules (boot, hardware, networking, users, etc.)
- Home Manager integration
- User configuration system
- Essential services

**Optional modules (commented out):**
- Display and audio modules (for GUI systems)
- Additional services (SSH, virtualization, etc.)
- Host-specific customizations

### Home Template (`home-minimal.nix`)

**Essential modules:**
- Environment configuration
- Fish shell with Starship
- Kitty terminal
- Micro editor

**Optional modules:**
- Desktop environment modules (Hyprland, theming)
- Development tools
- Gaming modules
- Creative tools

## Customization Guide

### Common Customizations

#### For Desktop Systems
1. Uncomment display and audio modules in system config
2. Uncomment desktop-related modules in home config
3. Add Hyprland configuration if using Hyprland WM

#### For Server Systems
1. Keep only essential modules
2. Add SSH and networking modules
3. Remove GUI-related modules

#### For Development Machines
1. Add development modules
2. Include virtualization if needed
3. Add Android tools if developing for mobile

### Host-Specific Modules

Create host-specific modules in `hosts/your-hostname/system_modules/`:

```
hosts/your-hostname/
├── configuration.nix
├── home.nix
└── system_modules/
    ├── custom-hardware.nix
    ├── custom-services.nix
    └── special-config.nix
```

### Hardware-Specific Configuration

For laptops or systems with special hardware:

1. Create hardware-specific modules
2. Handle thermal management, power settings, etc.
3. Configure special input devices

## Best Practices

### 1. Start Minimal
Begin with the essential modules and add more as needed. This keeps configurations clean and rebuilds faster.

### 2. Use Host-Specific Modules
For hardware-specific or complex configurations, create separate modules instead of cluttering the main configuration.

### 3. Test Before Deploying
Always use `nixos-rebuild dry-run` to test configurations before applying them.

### 4. Keep Templates Updated
As you add new modules or change configurations, consider updating these templates to reflect best practices.

### 5. Document Host-Specific Changes
Add comments in your host configurations explaining why certain modules are included or configured in specific ways.

## Troubleshooting

### Common Issues

**Flake errors:**
```bash
# Check for uncommitted changes
git status

# Add new files to git
git add .

# Check flake validity
nix flake check
```

**Hardware configuration issues:**
- Ensure `hardware-configuration.nix` is properly generated
- Check that all required kernel modules are included
- Verify device-specific configurations

**Home Manager issues:**
- Check that userConfig is properly passed
- Ensure home.stateVersion matches system.stateVersion
- Verify all required home modules are available

## Examples

See existing host configurations in:
- `hosts/nixos0/` - Full desktop system
- `hosts/surface0/` - Laptop with special hardware
- `hosts/thinkpad0/` - Another desktop system

These serve as references for how to structure more complex configurations.