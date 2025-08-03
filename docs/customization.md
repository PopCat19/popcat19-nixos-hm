# Customization

This NixOS configuration is designed for easy customization through a modular structure.

## Quick Customization

Edit [`user-config.nix`](../user-config.nix) for personal settings:

```nix
{
  user = {
    username = "your-username";
    fullName = "Your Full Name";
    email = "your@email.com";
  };

  host = {
    hostname = "your-computer-name";
    system = "x86_64-linux";
  };

  defaultApps = {
    browser = "firefox";
    terminal = "kitty";
    editor = "micro";
    fileManager = "dolphin";
    musicPlayer = "spotify";
    videoPlayer = "vlc";
  };
}
```

## Adding Packages

- **System packages**: Edit [`system_modules/packages.nix`](../system_modules/packages.nix)
- **User packages**: Edit [`home_modules/packages.nix`](../home_modules/packages.nix)

## Hyprland Customization

- **Window rules**: Edit [`hypr_config/userprefs.conf`](../hypr_config/userprefs.conf)
- **Keybindings**: Add custom bindings in [`hypr_config/userprefs.conf`](../hypr_config/userprefs.conf)

## Theming

- **GTK themes**: Modify [`home_modules/desktop-theme.nix`](../home_modules/desktop-theme.nix)
- **Icon themes**: Update in [`home_modules/desktop-theme.nix`](../home_modules/desktop-theme.nix)

## Shell Customization

- **Fish shell**: Edit [`home_modules/fish.nix`](../home_modules/fish.nix)
- **Starship prompt**: Customize in [`home_modules/starship.nix`](../home_modules/starship.nix)

## Network Configuration

- **Firewall rules**: Edit in [`user-config.nix`](../user-config.nix)
- **VPN setup**: Configure in [`system_modules/networking.nix`](../system_modules/networking.nix)

## Development Environment

- **Languages**: Add to [`home_modules/development.nix`](../home_modules/development.nix)
- **IDE settings**: Configure in [`home_modules/development.nix`](../home_modules/development.nix)

## Gaming

- **Gaming tools**: Edit [`home_modules/gaming.nix`](../home_modules/gaming.nix)
- **Proton settings**: Configure in Steam

## Services

- **System services**: Edit [`system_modules/services.nix`](../system_modules/services.nix)
- **User services**: Edit [`home_modules/services.nix`](../home_modules/services.nix)

## Testing Changes

```bash
# Test build
nixos-rebuild test --flake .#<hostname>

# Check for errors
nix flake check

# Review changes
nixos-rebuild dry-activate --flake .#<hostname>

# Rollback if needed
sudo nixos-rebuild switch --rollback
```

## Custom Modules

Create new modules in `system_modules/` or `home_modules/` following the existing structure.