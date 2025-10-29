#!/usr/bin/env bash

# CLI-only script to create GitHub runner tokens using nix-shell
# This script reads tokens from stdin without opening an editor

set -euo pipefail

echo "🔧 Creating GitHub runner tokens using CLI..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR"

echo "📋 You'll need to create GitHub Personal Access Tokens for each repository:"
echo ""
echo "1. Go to https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Give it a descriptive name (e.g., 'nixos0-shimboot-runner')"
echo "4. Select scopes: 'repo' (for private repos) or 'public_repo' (for public repos)"
echo "5. Generate token and copy it immediately (it won't be shown again)"
echo ""

# Function to create a token file
create_token_cli() {
    local repo_name="$1"
    local token_file="$SECRETS_DIR/github-runner/${repo_name}.token.age"
    
    echo "🔐 Creating encrypted token for $repo_name..."
    echo "Paste your GitHub token below (Ctrl+D to finish):"
    
    # Read token from stdin
    local token=""
    while IFS= read -r line; do
        token="${token}${line}\n"
    done
    
    if [ -z "$token" ]; then
        echo "❌ No token provided. Skipping."
        return 1
    fi
    
    # Create temporary file with token
    local temp_file=$(mktemp)
    echo -e "$token" > "$temp_file"
    
    # Use nix-shell with agenix to create the encrypted file
    echo "Encrypting token..."
    if nix-shell -p age agenix --run "agenix -e $token_file --editor cat" < "$temp_file"; then
        echo "✅ Token file created: $token_file"
    else
        echo "❌ Failed to create token file: $token_file"
        rm -f "$temp_file"
        return 1
    fi
    
    # Clean up
    rm -f "$temp_file"
}

# Create the github-runner directory if it doesn't exist
mkdir -p "$SECRETS_DIR/github-runner"

# Create shimboot token
create_token_cli "shimboot"

echo ""

# Create nixos-config token  
create_token_cli "nixos-config"

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