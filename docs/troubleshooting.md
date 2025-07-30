# Troubleshooting Guide

This guide helps you resolve common issues with this NixOS configuration.

## Quick Diagnostics

### Check System Status
```bash
# Check system health
nix flake check
nixos-rebuild dry-activate --flake .#$(hostname)

# Check Hyprland configuration
hyprctl configerrors

# Check system logs
journalctl -xe
```

### Common Commands
```bash
# Rebuild configuration
nixos-rebuild switch --flake .#$(hostname)

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Update flake inputs
nix flake update

# Check for broken packages
nix store verify --repair --check-contents
```

## Hyprland Issues

### Hyprland Won't Start
**Symptoms**: Black screen, returns to login manager
**Solutions**:
1. Check configuration errors:
   ```bash
   hyprctl configerrors
   ```

2. Verify GPU drivers:
   ```bash
   lspci | grep -i vga
   glxinfo | grep "OpenGL renderer"
   ```

3. Check display configuration:
   - Review [`hypr_config/monitors.conf`](../hypr_config/monitors.conf)
   - Ensure monitor names match your system

### Monitor Configuration Issues
**Symptoms**: Wrong resolution, monitor not detected
**Solutions**:
1. List available monitors:
   ```bash
   hyprctl monitors
   ```

2. Check connected displays:
   ```bash
   xrandr --listmonitors
   ```

3. Update monitor configuration:
   - Edit [`hypr_config/monitors.conf`](../hypr_config/monitors.conf)
   - Use exact monitor names from `hyprctl monitors`

### Keybindings Not Working
**Symptoms**: Custom keybindings don't respond
**Solutions**:
1. Check keybinding conflicts:
   ```bash
   hyprctl binds
   ```

2. Verify key names:
   ```bash
   wev  # Install with: nix-shell -p wev
   ```

3. Check configuration syntax:
   - Review [`hypr_config/userprefs.conf`](../hypr_config/userprefs.conf)
   - Ensure proper syntax for key combinations

## Audio Issues

### No Audio Output
**Symptoms**: No sound from speakers/headphones
**Solutions**:
1. Check audio services:
   ```bash
   systemctl --user status pipewire
   systemctl --user status wireplumber
   ```

2. Verify audio devices:
   ```bash
   pactl list short sinks
   pactl list short sources
   ```

3. Check audio configuration:
   - Review [`system_modules/audio.nix`](../system_modules/audio.nix)
   - Ensure correct audio server settings

### Bluetooth Audio Issues
**Symptoms**: Bluetooth devices not connecting or no audio
**Solutions**:
1. Check Bluetooth service:
   ```bash
   systemctl status bluetooth
   ```

2. Reset Bluetooth adapter:
   ```bash
   bluetoothctl power off
   bluetoothctl power on
   ```

3. Re-pair devices:
   ```bash
   bluetoothctl scan on
   bluetoothctl pair XX:XX:XX:XX:XX:XX
   ```

## Network Issues

### No Internet Connection
**Symptoms**: Cannot connect to websites
**Solutions**:
1. Check network interfaces:
   ```bash
   ip link show
   ip addr show
   ```

2. Test DNS resolution:
   ```bash
   nslookup google.com
   dig google.com
   ```

3. Check firewall rules:
   ```bash
   sudo ufw status
   ```

### VPN Connection Issues
**Symptoms**: VPN won't connect or no internet through VPN
**Solutions**:
1. Check VPN service:
   ```bash
   systemctl status openvpn@client
   systemctl status wireguard-wg0
   ```

2. Verify configuration:
   - Check [`system_modules/networking.nix`](../system_modules/networking.nix)
   - Ensure correct VPN credentials

3. Check DNS settings:
   ```bash
   cat /etc/resolv.conf
   ```

## Gaming Issues

### Steam Won't Launch
**Symptoms**: Steam crashes or won't start
**Solutions**:
1. Check 32-bit libraries:
   ```bash
   nix-shell -p steam-run --run "steam"
   ```

2. Clear Steam cache:
   ```bash
   rm -rf ~/.local/share/Steam/config/htmlcache
   ```

3. Check GPU drivers:
   ```bash
   glxinfo | grep "OpenGL renderer"
   ```

### Games Not Launching
**Symptoms**: Games crash immediately or won't start
**Solutions**:
1. Check Proton compatibility:
   - Enable Proton GE in Steam settings
   - Try different Proton versions

2. Verify game files:
   - Right-click game → Properties → Local Files → Verify integrity

3. Check system requirements:
   - Ensure sufficient RAM and GPU memory
   - Check Vulkan support: `vulkaninfo`

## Development Environment Issues

### Language Server Not Working
**Symptoms**: VS Code shows "Language server crashed"
**Solutions**:
1. Check language server installation:
   ```bash
   which rust-analyzer
   which solargraph
   ```

2. Restart language servers:
   - In VS Code: Ctrl+Shift+P → "Developer: Reload Window"

3. Check configuration:
   - Review [`home_modules/development.nix`](../home_modules/development.nix)
   - Ensure correct language server paths

### Docker Issues
**Symptoms**: Docker commands fail or containers won't start
**Solutions**:
1. Check Docker service:
   ```bash
   systemctl status docker
   ```

2. Add user to docker group:
   ```bash
   sudo usermod -aG docker $USER
   ```

3. Check storage driver:
   ```bash
   docker info | grep "Storage Driver"
   ```

## Package Management Issues

### Package Not Found
**Symptoms**: Package installation fails with "attribute missing"
**Solutions**:
1. Search for package:
   ```bash
   nix search nixpkgs package-name
   ```

2. Check package name:
   - Use exact package name from search results
   - Check case sensitivity

3. Update flake inputs:
   ```bash
   nix flake update
   ```

### Broken Dependencies
**Symptoms**: Build fails with dependency errors
**Solutions**:
1. Update all inputs:
   ```bash
   nix flake update
   ```

2. Check for breaking changes:
   - Review recent commits
   - Check NixOS release notes

3. Use specific package versions:
   ```nix
   {
     my-package = pkgs.my-package.override {
       version = "specific-version";
     };
   }
   ```

## System Boot Issues

### Boot Hangs or Fails
**Symptoms**: System won't boot or hangs during boot
**Solutions**:
1. Boot from previous generation:
   - At GRUB menu, select previous generation

2. Check boot logs:
   ```bash
   journalctl -b -1
   ```

3. Verify hardware configuration:
   - Review [`hardware-configuration.nix`](../hardware-configuration.nix)
   - Check for hardware changes

### Kernel Panic
**Symptoms**: Kernel panic during boot
**Solutions**:
1. Boot with older kernel:
   - Select previous generation at GRUB

2. Check hardware compatibility:
   - Review [`system_modules/boot.nix`](../system_modules/boot.nix)
   - Check kernel parameters

## Performance Issues

### High CPU Usage
**Symptoms**: System feels slow, fans always on
**Solutions**:
1. Check running processes:
   ```bash
   htop
   ```

2. Check system services:
   ```bash
   systemctl list-units --failed
   ```

3. Monitor resource usage:
   ```bash
   btop
   ```

### Memory Issues
**Symptoms**: Out of memory errors, system freezing
**Solutions**:
1. Check memory usage:
   ```bash
   free -h
   ```

2. Check swap usage:
   ```bash
   swapon --show
   ```

3. Check for memory leaks:
   ```bash
   ps aux --sort=-%mem | head
   ```

## Backup and Recovery

### Configuration Backup Issues
**Symptoms**: Backups not created or corrupted
**Solutions**:
1. Check backup script:
   ```bash
   ls -la /etc/nixos/backup/
   ```

2. Verify backup integrity:
   ```bash
   nix-instantiate --eval backup-user-config.nix
   ```

3. Manual backup creation:
   ```bash
   nix-build backup-user-config.nix -o backup-result
   ```

### Recovery from Broken Configuration
**Symptoms**: System won't boot after configuration change
**Solutions**:
1. Boot from live USB
2. Mount system:
   ```bash
   sudo mount /dev/nvme0n1p2 /mnt
   sudo mount /dev/nvme0n1p1 /mnt/boot
   ```

3. Chroot into system:
   ```bash
   sudo nixos-enter
   ```

4. Rollback configuration:
   ```bash
   nixos-rebuild switch --rollback
   ```

## Getting Help

### Community Resources
- **NixOS Discourse**: https://discourse.nixos.org/
- **NixOS Wiki**: https://nixos.wiki/
- **Hyprland Discord**: https://discord.gg/hyprland
- **NixOS Matrix**: https://matrix.to/#/#nix:nixos.org

### Debug Information
When asking for help, provide:

1. **System information**:
   ```bash
   nix-shell -p nix-info --run "nix-info -m"
   ```

2. **Configuration files** (sanitized):
   - [`user-config.nix`](../user-config.nix)
   - Relevant module files

3. **Error messages**:
   - Full error output
   - System logs (`journalctl -xe`)

4. **Steps to reproduce**:
   - Exact commands used
   - Expected vs actual behavior

### Emergency Contacts
- **NixOS IRC**: #nixos on Libera.Chat
- **Hyprland IRC**: #hyprland on Libera.Chat
- **GitHub Issues**: Report issues on the repository

Remember: Always backup your configuration before making significant changes!