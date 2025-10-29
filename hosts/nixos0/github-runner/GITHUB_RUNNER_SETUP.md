# GitHub Runner Setup for nixos0

This document explains the GitHub self-hosted runner setup for the nixos0 host using the [github-nix-ci](https://github.com/juspay/github-nix-ci) flake.

## Overview

The configuration provides:
- **2 runners** for `PopCat19/nixos-shimboot` (for shimboot builds)
- **1 runner** for `PopCat19/nixos-config` (for personal config management)
- **Docker support** for containerized builds
- **Agenix integration** for secure token management

## Files Created/Modified

### Core Configuration
- `hosts/nixos0/system_modules/github-runner.nix` - Main runner configuration
- `hosts/nixos0/configuration.nix` - Imports the github-runner module

### Secrets Management
- `hosts/nixos0/secrets/secrets.nix` - Agenix secrets configuration
- `hosts/nixos0/secrets/get-ssh-keys.sh` - Helper script to get SSH keys
- `hosts/nixos0/secrets/setup-github-runner-secrets.sh` - Setup script for tokens

### Documentation
- `hosts/nixos0/system_modules/README.md` - Detailed setup instructions
- `hosts/nixos0/GITHUB_RUNNER_SETUP.md` - This file

### Flake Updates
- `flake.nix` - Added `github-nix-ci` and `agenix` inputs
- `flake.lock` - Updated with new inputs

## Quick Setup Guide

### 1. Create GitHub Personal Access Tokens

For each repository, create a Personal Access Token:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Set descriptive names:
   - `nixos0-shimboot-runner` for PopCat19/nixos-shimboot
   - `nixos0-config-runner` for PopCat19/nixos-config
4. Select scope: `repo` (for private repos) or `public_repo` (for public repos)
5. Copy tokens immediately (they won't be shown again)

### 2. Setup Encrypted Secrets

```bash
cd hosts/nixos0/secrets
./setup-github-runner-secrets.sh
```

This will:
- Install agenix if not available
- Create encrypted token files for each repository
- Guide you through the token creation process

### 3. Rebuild the System

```bash
sudo nixos-rebuild switch --flake .#popcat19-nixos0
```

### 4. Verify Runners

Check GitHub repository settings:
1. Navigate to your repository
2. Go to Settings > Actions > Runners
3. Look for runners with names like:
   - `popcat19-nixos0-PopCat19-nixos-shimboot-01`
   - `popcat19-nixos0-PopCat19-nixos-shimboot-02`
   - `popcat19-nixos0-PopCat19-nixos-config-01`

Or check locally:
```bash
# Check systemd services
systemctl status github-nix-ci-*

# Check runner logs
journalctl -u github-nix-ci-*
```

## Security Notes

- Tokens are encrypted using [agenix](https://github.com/ryantm/agenix)
- Only users with SSH keys in `secrets.nix` can decrypt tokens
- Runner user has minimal permissions but is in docker group
- Runners are ephemeral (clean state for each job)

## Troubleshooting

### Runners not appearing in GitHub
```bash
# Check service status
systemctl status github-nix-ci-*

# Check logs
journalctl -u github-nix-ci-* -f

# Verify network connectivity
curl -I https://github.com
```

### Docker permission issues
```bash
# Verify docker is running
systemctl status docker

# Check user groups
groups github-runner
```

### Token issues
```bash
# Re-create encrypted tokens
cd hosts/nixos0/secrets
agenix -e github-runner/shimboot.token.age
agenix -e github-runner/nixos-config.token.age
```

## Runner Labels

The runners are automatically labeled with:
- Hostname: `popcat19-nixos0`
- Supported systems: `x86_64-linux`

Use these labels in your GitHub Actions workflows:
```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, x86_64]
    # or
    runs-on: [self-hosted, popcat19-nixos0]
```

## Performance Considerations

- **Concurrent runners**: 2 for shimboot, 1 for config (configurable)
- **Disk space**: Ensure adequate space for Nix store and build artifacts
- **Network**: Stable internet connection required for GitHub API communication
- **Memory**: Recommended 4GB+ RAM for complex Nix builds

## Maintenance

### Updating Runner Configuration
Modify `hosts/nixos0/system_modules/github-runner.nix` and rebuild:
```bash
sudo nixos-rebuild switch --flake .#popcat19-nixos0
```

### Rotating Tokens
1. Create new GitHub tokens
2. Update encrypted files:
   ```bash
   cd hosts/nixos0/secrets
   agenix -e github-runner/shimboot.token.age
   agenix -e github-runner/nixos-config.token.age
   ```
3. Rebuild system

### Monitoring
Set up monitoring for:
- Runner service status
- Disk usage in `/nix/store`
- Network connectivity to GitHub
- Build success/failure rates

## References

- [github-nix-ci repository](https://github.com/juspay/github-nix-ci)
- [agenix documentation](https://github.com/ryantm/agenix)
- [GitHub Actions self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)