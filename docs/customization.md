# Customization Guide

This guide explains how to customize and personalize your NixOS configuration.

## Quick Customization

The fastest way to customize your system is through [`user-config.nix`](../user-config.nix), which contains all user-configurable settings in one place.

### Essential Customizations

#### 1. Personal Information
```nix
{
  user = {
    username = "your-username";
    fullName = "Your Full Name";
    email = "your@email.com";
  };
}
```

#### 2. Host Configuration
```nix
{
  host = {
    hostname = "your-computer-name";
    system = "x86_64-linux";  # or "aarch64-linux" for ARM64
  };
}
```

#### 3. Default Applications
```nix
{
  defaultApps = {
    browser = "firefox";      # or "chromium", "brave"
    terminal = "kitty";       # or "alacritty", "wezterm"
    editor = "micro";         # or "nano", "vim", "emacs"
    fileManager = "dolphin";  # or "nautilus", "thunar"
    musicPlayer = "spotify";  # or "clementine", "rhythmbox"
    videoPlayer = "vlc";      # or "mpv", "celluloid"
  };
}
```

## Advanced Customization

### Adding New Packages

#### System-Level Packages
Edit [`system_modules/packages.nix`](../system_modules/packages.nix) to add system-wide packages:

```nix
{
  environment.systemPackages = with pkgs; [
    # Add your packages here
    htop
    neofetch
    # your-custom-package
  ];
}
```

#### User-Level Packages
Edit [`home_modules/packages.nix`](../home_modules/packages.nix) for user-specific packages:

```nix
{
  home.packages = with pkgs; [
    # Add your packages here
    spotify
    discord
    # your-custom-package
  ];
}
```

### Customizing Hyprland

#### Window Rules
Edit [`hypr_config/userprefs.conf`](../hypr_config/userprefs.conf) to add window-specific rules:

```conf
windowrulev2 = float,class:^(firefox)$
windowrulev2 = center,class:^(firefox)$
windowrulev2 = size 1200 800,class:^(firefox)$
```

#### Keybindings
Add custom keybindings in [`hypr_config/userprefs.conf`](../hypr_config/userprefs.conf):

```conf
bind = SUPER_SHIFT, Q, exec, your-custom-command
bind = SUPER, E, exec, dolphin
```

### Theming Customization

#### GTK Themes
The system uses Rose Pine by default. To change themes:

1. **Install new theme package** in [`home_modules/desktop-theme.nix`](../home_modules/desktop-theme.nix)
2. **Update GTK settings** in the same file
3. **Apply theme** system-wide

#### Icon Themes
Modify icon themes in [`home_modules/desktop-theme.nix`](../home_modules/desktop-theme.nix):

```nix
{
  gtk.iconTheme = {
    name = "your-icon-theme";
    package = pkgs.your-icon-theme;
  };
}
```

### Shell Customization

#### Fish Shell Functions
Add custom functions to [`home_modules/fish.nix`](../home_modules/fish.nix):

```nix
{
  programs.fish.shellAliases = {
    ll = "ls -la";
    update = "nixos-rebuild switch --flake ~/nixos-config";
    # Add your aliases
  };
}
```

#### Starship Prompt
Customize the prompt in [`home_modules/starship.nix`](../home_modules/starship.nix):

```nix
{
  programs.starship.settings = {
    # Add your starship configuration
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✗](bold red)";
    };
  };
}
```

### Network Configuration

#### Firewall Rules
Edit network settings in [`user-config.nix`](../user-config.nix):

```nix
{
  network = {
    firewall.allowedTCPPorts = [ 22 80 443 8080 ];
    firewall.allowedUDPPorts = [ 53 1194 ];
    trustedInterfaces = [ "eth0" ];
  };
}
```

#### VPN Configuration
Add VPN configurations in [`system_modules/networking.nix`](../system_modules/networking.nix):

```nix
{
  networking.wireguard.interfaces = {
    wg0 = {
      # Your wireguard configuration
    };
  };
}
```

### Development Environment

#### Adding New Languages
To add support for a new programming language:

1. **Add language package** in [`home_modules/development.nix`](../home_modules/development.nix)
2. **Configure language server** in the same file
3. **Add build tools** and package managers

Example for adding Ruby:
```nix
{
  home.packages = with pkgs; [
    ruby
    bundler
    rubyPackages.solargraph  # Language server
  ];
}
```

#### IDE Configuration
Customize VS Code settings in [`home_modules/development.nix`](../home_modules/development.nix):

```nix
{
  programs.vscode.userSettings = {
    "editor.fontSize": 14,
    "workbench.colorTheme": "Rosé Pine",
    # Add your settings
  };
}
```

### Gaming Customization

#### Adding New Gaming Tools
Edit [`home_modules/gaming.nix`](../home_modules/gaming.nix):

```nix
{
  home.packages = with pkgs; [
    # Add gaming tools
    heroic
    bottles
    # your-gaming-tool
  ];
}
```

#### Proton Configuration
Customize Proton settings for Steam:

1. **Enable Proton GE** in Steam settings
2. **Configure per-game settings** in Steam
3. **Add custom launch options** as needed

### Services Configuration

#### Adding System Services
Edit [`system_modules/services.nix`](../system_modules/services.nix):

```nix
{
  services = {
    # Add your services
    nginx.enable = true;
    postgresql.enable = true;
  };
}
```

#### Adding User Services
Edit [`home_modules/services.nix`](../home_modules/services.nix):

```nix
{
  services = {
    # Add user services
    syncthing.enable = true;
    nextcloud-client.enable = true;
  };
}
```

### Backup Customization

#### Backup Locations
Modify backup settings in [`backup-user-config.nix`](../backup-user-config.nix):

```nix
{
  backupLocations = [
    "/path/to/backup1"
    "/path/to/backup2"
  ];
}
```

#### Backup Rotation
Adjust backup retention in the same file:

```nix
{
  backupRotation = 5;  # Keep 5 backups instead of 3
}
```

### Hardware-Specific Customization

#### GPU Configuration
For NVIDIA users, edit [`system_modules/display.nix`](../system_modules/display.nix):

```nix
{
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    # Add your NVIDIA settings
  };
}
```

#### Audio Configuration
Customize audio in [`system_modules/audio.nix`](../system_modules/audio.nix):

```nix
{
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}
```

### Testing Changes

#### Safe Testing
Before applying changes system-wide:

1. **Test build**: `nixos-rebuild test --flake .#<hostname>`
2. **Check for errors**: `nix flake check`
3. **Review changes**: `nixos-rebuild dry-activate --flake .#<hostname>`

#### Rollback Changes
If something breaks:

```bash
sudo nixos-rebuild switch --rollback
```

### Creating Custom Modules

#### New System Module
Create a new file in `system_modules/`:

```nix
# system_modules/my-module.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.my-module = {
    enable = mkEnableOption "my custom module";
  };

  config = mkIf config.my-module.enable {
    # Your configuration here
  };
}
```

#### New Home Module
Create a new file in `home_modules/`:

```nix
# home_modules/my-module.nix
{ config, lib, pkgs, ... }:

{
  options.my-home-module = {
    enable = mkEnableOption "my custom home module";
  };

  config = mkIf config.my-home-module.enable {
    # Your configuration here
  };
}
```

### Migration Tips

#### From Other Distributions
- **Preserve home directory** during installation
- **Import browser bookmarks** and settings
- **Transfer SSH keys** and configurations
- **Migrate application data** as needed

#### Between NixOS Systems
- **Copy user-config.nix** to new system
- **Update hardware-configuration.nix**
- **Adjust hostname** in user-config.nix
- **Test configuration** before full switch

### Best Practices

1. **Use user-config.nix** for all personal settings
2. **Test changes** before applying system-wide
3. **Keep backups** of working configurations
4. **Document customizations** for future reference
5. **Use git** for version control of changes
6. **Follow modular structure** for maintainability