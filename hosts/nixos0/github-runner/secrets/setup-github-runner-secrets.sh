#!/usr/bin/env bash

# Setup script for GitHub runner secrets using agenix
# This script helps create encrypted token files for GitHub runners

set -euo pipefail

echo "🔧 Setting up GitHub runner secrets with agenix..."

# Check if agenix is available
if ! command -v agenix &> /dev/null; then
    echo "❌ agenix not found. Installing..."
    echo "📦 Installing agenix temporarily..."
    nix-shell -p age agenix --run "echo '✅ agenix installed in nix-shell'"
    echo ""
    echo "🔐 Creating encrypted tokens using nix-shell..."
    echo "Note: You'll be prompted for tokens in separate nix-shell environments."
fi

# Create secrets directory if it doesn't exist
mkdir -p "$(dirname "$0")/github-runner"

echo "📋 You'll need to create GitHub Personal Access Tokens for each repository:"
echo ""
echo "1. Go to https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Give it a descriptive name (e.g., 'nixos0-shimboot-runner')"
echo "4. Select scopes: 'repo' (for private repos) or 'public_repo' (for public repos)"
echo "5. Generate token and copy it immediately (it won't be shown again)"
echo ""

# Create shimboot token
echo "🔐 Creating encrypted token for PopCat19/nixos-shimboot..."
echo "Paste your GitHub token when the editor opens, then save and exit."
read -p "Press Enter to continue..."
nix-shell -p age agenix --run "agenix -e $(dirname "$0")/github-runner/shimboot.token.age"

# Create nixos-config token
echo "🔐 Creating encrypted token for PopCat19/nixos-config..."
echo "Paste your GitHub token when the editor opens, then save and exit."
read -p "Press Enter to continue..."
nix-shell -p age agenix --run "agenix -e $(dirname "$0")/github-runner/nixos-config.token.age"

echo ""
echo "✅ Setup complete! The encrypted tokens have been created."
echo ""
echo "📝 Next steps:"
echo "1. Make sure your SSH public key is added to secrets.nix"
echo "2. Make sure the nixos0 host key is added to secrets.nix"
echo "3. Rebuild your NixOS configuration:"
echo "   sudo nixos-rebuild switch --flake .#popcat19-nixos0"
echo ""
echo "🔍 To verify the runners are working:"
echo "   - Check GitHub repository Settings > Actions > Runners"
echo "   - Check systemd services: systemctl status github-nix-ci-*"