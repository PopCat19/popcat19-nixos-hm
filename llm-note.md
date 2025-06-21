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
1. Make configuration changes
2. Check repo structure with `tree -L 4`
3. Rebuild with `nixos-apply-config`
4. If errors occur, use `nix search` to find missing packages
5. Check Hyprland issues with `hyprctl configerrors`
