# LLM Note: NixOS Config Testing & Troubleshooting

> Always use sequential-thinking MCP. Search if needed. Prefer diff if possible.

## Streamlined Commands

### Package Management
```
fish -c "git add ."
fish -c "nixpkg add <package> -rdm 'add <package> for <purpose>'"
```
- Fully automated: add package → dry-run test → rebuild → commit
- Automatic rollback if configuration fails
- Replace <package> with package name, <purpose> with brief description

### Configuration Changes
```
fish -c "git add ."
fish -c "nixos-apply-config -dm 'Config update description'"
```
- For manual configuration file edits
- Dry-run test then rebuild with commit message

### Package Search
```
fish -c "nix search nixpkgs <package>"
```
- Find correct package names for installation

### Hyprland Issues
```
fish -c "hyprctl configerrors"
```
- Check window manager configuration errors

### Repository Structure
```
fish -c "tree -L 4"
```
- View project structure for troubleshooting

## Workflow Examples

### Single Package
```
fish -c "git add ."
fish -c "nixpkg add firefox -rdm 'add Firefox browser'"
```

### Category-Specific Packages
```
fish -c "git add ."
fish -c "nixpkg add flameshot screenshot -rdm 'add screenshot tool'"
fish -c "git add ."
fish -c "nixpkg add papirus-icon-theme theme -rdm 'update icon theme'"
```

### Remove Packages
```
fish -c "git add ."
fish -c "nixpkg remove htop -rdm 'remove htop utility'"
```

### Manual Config Changes
```
# Edit config files manually first, then:
fish -c "git add ."
fish -c "nixos-apply-config -dm 'Manual configuration update'"
```

## Flag Reference

### nixpkg flags
- `-rdm "msg"` - Dry-run → rebuild → commit (recommended)
- `-rm "msg"` - Direct rebuild → commit (skip dry-run)
- `-d` - Dry-run test only (no rebuild)

### nixos-apply-config flags
- `-dm "msg"` - Dry-run → rebuild → commit
- `-m "msg"` - Direct rebuild → commit
- `-d` - Dry-run test only

## Troubleshooting

### Search Package
```
fish -c "nixpkg search '<partial-name>'"
```

### Build Failures
- Check error output for missing dependencies
- Use `fish -c "nixpkg files"` to see available config files
- Use `fish -c "nixpkg list all"` to see all current packages

### Hyprland Issues
```
fish -c "hyprctl configerrors"
```

### Git Issues
- Ensure new files are added: `fish -c "git add ."`
- Check status: `fish -c "git status"`

All steps automated with safety checks and automatic rollback on failure.
