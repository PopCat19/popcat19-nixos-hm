# LLM Note: NixOS Config Testing & Troubleshooting

## Key Commands for Testing and Troubleshooting

### Streamlined Package Management & Rebuild
```bash
fish -c "nixpkg add <package> -rdm '<short-commit>'"
```
- **RECOMMENDED**: Dry-run test, then rebuild with commit message if successful
- Fully automated workflow: add package → test → rebuild → commit
- Replace `<package>` with package name and `<short-commit>` with description

### Alternative: Direct Rebuild (for confident changes)
```bash
fish -c "nixpkg add <package> -rm '<short-commit>'"
```
- Skip dry-run, rebuild immediately with commit message
- Use when you're confident the package addition will work

### Traditional Rebuild (if needed)
```bash
fish -c "nixos-apply-config -m '<short-commit>'"
```
- Use this for manual configuration changes not done through nixpkg
- Replace `<short-commit>` with a brief description of changes

### Package Resolution
```bash
nix search nixpkgs <package>
```
- Search for packages in nixpkgs to resolve dependency errors
- Replace `<package>` with the package name you're looking for

### Hyprland Configuration Errors
```bash
hyprctl configerrors
```
- Check for Hyprland configuration errors
- Run this if experiencing window manager issues

### Repository Structure Overview
```bash
tree -L 4
```
- Display repository tree structure (4 levels deep)
- Useful for understanding project layout during troubleshooting

## Streamlined Workflow (Recommended)

### For Package Operations
1. **Single Command Package Management**:
   ```bash
   fish -c "nixpkg add <package> -rdm 'add <package> for <purpose>'"
   ```
   - This automatically: adds package → tests config → rebuilds → commits
   - No manual git operations needed
   - Automatic rollback if configuration fails

2. **Multiple Package Categories**:
   ```bash
   fish -c "nixpkg add firefox theme -rdm 'Add Firefox to theme config'"
   fish -c "nixpkg add flameshot screenshot -rdm 'Add screenshot tool'"
   ```

### For Manual Configuration Changes
1. Make configuration changes with Sequential Thinking MCP
2. Check repo structure with `tree -L 4`
3. **IMPORTANT: Add new files/dirs to git** with `git add .` (required for flake compatibility)
4. **Test build first** with `fish -c "nix build --dry-run .#nixosConfigurations.popcat19-nixos0.config.system.build.toplevel"` (no sudo required)
5. **Only after dry-run succeeds**, rebuild with `fish -c "nixos-apply-config -m '<short-commit>'"`

### Troubleshooting
1. If package operations fail, use `nix search` to find correct package names
2. Check Hyprland issues with `hyprctl configerrors`
3. Use `nixpkg files` to see available configuration files
4. Use `nixpkg list all` to see all packages across configurations

## Workflow Comparison

**Old Multi-Step Process:**
```bash
# Manual editing of nix files
git add .
nix build --dry-run .#nixosConfigurations.popcat19-nixos0.config.system.build.toplevel
fish -c "nixos-apply-config -m '<short-commit>'"
```

**New Streamlined Process:**
```bash
fish -c "nixpkg add <package> -rdm '<short-commit>'"
# Done! Everything automated with safety checks
```
