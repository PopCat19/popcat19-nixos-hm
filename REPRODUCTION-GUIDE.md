# NPM Global Packages on NixOS - Reproduction Guide

This guide shows how to reproduce the npm global package setup that allows installing packages like `@google/gemini-cli` globally on NixOS.

## Quick Setup

1. **Add PATH configuration** to your `home.nix`:
   ```nix
   # Add npm global directory to PATH
   home.sessionPath = [ "$HOME/.local/bin" "$HOME/.npm-global/bin" ];
   
   # Add to fish shell configuration
   programs.fish = {
     enable = true;
     shellInit = ''
       fish_add_path $HOME/.npm-global/bin
     '';
   };
   ```

2. **Add npm configuration** to your `home.nix`:
   ```nix
   # NPM global configuration
   home.file.".npmrc".text = ''
     prefix=${config.home.homeDirectory}/.npm-global
   '';
   ```

3. **Rebuild your configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

4. **Install global packages**:
   ```bash
   mkdir -p ~/.npm-global
   npm install -g @google/gemini-cli
   ```

## What This Does

- **Solves the permission problem**: NixOS npm can't write to `/nix/store`, so we use `~/.npm-global`
- **Makes it permanent**: Configuration survives system rebuilds
- **Adds to PATH**: Global packages become available system-wide

## Verification

```bash
# Check if it's working
which gemini
gemini --version

# Check npm configuration
npm config get prefix  # Should show: /home/username/.npm-global
```

## Adding More Global Packages

After the initial setup, you can install any global npm package:

```bash
npm install -g typescript
npm install -g @vue/cli
npm install -g create-react-app
```

## Files Created

- `~/.npmrc` - NPM configuration pointing to local directory
- `~/.npm-global/` - Directory containing global packages
- PATH updated to include `~/.npm-global/bin`

This approach is **reproducible**, **clean**, and **persistent** across NixOS rebuilds.