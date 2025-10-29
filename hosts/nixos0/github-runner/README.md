# GitHub Runner Configuration

This directory contains the complete setup for self-hosted GitHub Actions runners on nixos0.

## Structure

```
github-runner/
├── README.md                    # This file
├── github-runner.nix            # Main NixOS module configuration
├── secrets/                     # Agenix encrypted secrets
│   ├── secrets.nix             # Agenix secrets configuration
│   ├── get-ssh-keys.sh         # Helper script to get SSH keys
│   └── setup-github-runner-secrets.sh  # Setup script for tokens
└── GITHUB_RUNNER_SETUP.md      # Complete setup guide
```

## Quick Start

1. **Create GitHub Personal Access Tokens**
   - Go to https://github.com/settings/tokens
   - Create tokens for each repository you want to run CI/CD on
   - Scope: `repo` (private) or `public_repo` (public)

2. **Setup Encrypted Secrets**
   
   **Option A: Interactive (with editor)**
   ```bash
   cd secrets
   ./create-tokens.sh
   ```
   
   **Option B: CLI-only (no editor)**
   ```bash
   cd secrets
   ./create-tokens-cli.sh
   ```

3. **Rebuild System**
   ```bash
   sudo nixos-rebuild switch --flake .#popcat19-nixos0
   ```

## Configuration

The runners are configured in `github-runner.nix`:
- **2 runners** for `PopCat19/nixos-shimboot`
- **1 runner** for `PopCat19/nixos-config`
- **Docker support** enabled
- **Ephemeral runners** (clean state per job)

## Security

- Tokens encrypted with [agenix](https://github.com/ryantm/agenix)
- Only users with SSH keys in `secrets/secrets.nix` can decrypt
- Runner user has minimal permissions
- Runners are automatically labeled with hostname and system

## Verification

Check runner status:
```bash
# Systemd services
systemctl status github-nix-ci-*

# GitHub repository settings
# Settings > Actions > Runners
```

For detailed instructions, see `GITHUB_RUNNER_SETUP.md`.