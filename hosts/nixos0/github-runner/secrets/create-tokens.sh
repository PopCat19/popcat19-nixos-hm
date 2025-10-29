#!/usr/bin/env bash

# Simple script to create GitHub runner tokens using the flake's agenix
# This script uses the flake's agenix input to ensure compatibility

set -euo pipefail

echo "🔧 Creating GitHub runner tokens using flake agenix..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR"
# Get the flake root directory (4 levels up from secrets)
FLAKE_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"

echo "📋 You'll need to create GitHub Personal Access Tokens for each repository:"
echo ""
echo "1. Go to https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Give it a descriptive name (e.g., 'nixos0-shimboot-runner')"
echo "4. Select scopes: 'repo' (for private repos) or 'public_repo' (for public repos)"
echo "5. Generate token and copy it immediately (it won't be shown again)"
echo ""

# Function to create a token file
create_token() {
    local username="$1"
    local token_file="$SECRETS_DIR/github-nix-ci/${username}.token.age"
    
    echo "🔐 Creating encrypted token for GitHub user: $username"
    echo "When the editor opens:"
    echo "1. Paste your GitHub Personal Access Token"
    echo "2. Save the file (Ctrl+S in micro)"
    echo "3. Exit the editor (Ctrl+Q in micro)"
    echo "This token will be used for all repositories configured in github-runner.nix"
    read -p "Press Enter to open the editor..."
    
    # Use the flake's agenix to create the encrypted file with the editor
    # Change to the secrets directory so agenix can find secrets.nix with relative paths
    cd "$SECRETS_DIR"
    EDITOR=micro nix run "$FLAKE_ROOT"#agenix -- -i "/home/popcat19/.ssh/id_ed25519_builder" -e "github-nix-ci/${username}.token.age"
    cd - > /dev/null
    
    if [ -f "$token_file" ]; then
        echo "✅ Token file created: $token_file"
    else
        echo "❌ Failed to create token file: $token_file"
        return 1
    fi
}

# Create the github-nix-ci directory if it doesn't exist
mkdir -p "$SECRETS_DIR/github-nix-ci"

# Create token for PopCat19 user (covers all configured repositories)
create_token "PopCat19"

echo ""
echo "✅ Setup complete! The encrypted tokens have been created."
echo ""
echo "📝 Next steps:"
echo "1. Rebuild your NixOS configuration:"
echo "   sudo nixos-rebuild switch --flake .#popcat19-nixos0"
echo ""
echo "🔍 To verify the runners are working:"
echo "   - Check GitHub repository Settings > Actions > Runners"
echo "   - Check systemd services: systemctl status github-nix-ci-*"