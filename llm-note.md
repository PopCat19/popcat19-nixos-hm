# LLM Note: NixOS Config Testing & Troubleshooting

## Key Commands for Testing and Troubleshooting

### Rebuild and Push Configuration
```bash
fish -c 'nixos-apply-config -m "<short-commit>"'
```
- Use this to rebuild NixOS configuration with a commit message
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

## Workflow
1. Make configuration changes with Sequential Thinking MCP
2. Check repo structure with `tree -L 4`
3. **IMPORTANT: Add new files/dirs to git** with `git add .` (required for flake compatibility)
4. **Test build first** with `fish -c "nix build --dry-run .#nixosConfigurations.popcat19-nixos0"` (no sudo required)
5. **Only after dry-run succeeds**, rebuild with `fish -c 'nixos-apply-config -m "<short-commit>"'`
6. If errors occur, use `nix search` to find missing packages
7. Check Hyprland issues with `hyprctl configerrors`
