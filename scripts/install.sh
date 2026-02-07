#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up new macOS machine with Nix + nix-darwin..."

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

# Install Xcode Command Line Tools
echo "==> Installing Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete Xcode CLT installation and run this script again."
    exit 0
else
    echo "Xcode CLT already installed"
fi

# Install Homebrew
echo "==> Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
fi

# Install Nix via Determinate Systems
echo "==> Installing Nix..."
if ! command -v nix &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    echo "Nix already installed"
fi

# Clone this repo if not already present
REPO_URL="${REPO_URL:-git@github.com:yourusername/nix-config.git}"
CONFIG_DIR="$HOME/.config/nix-config"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "==> Cloning nix-config repository..."
    git clone "$REPO_URL" "$CONFIG_DIR"
else
    echo "nix-config already exists at $CONFIG_DIR"
fi

cd "$CONFIG_DIR"

# Build and activate nix-darwin configuration
echo "==> Building nix-darwin configuration..."
sudo nix run nix-darwin -- switch --flake .#macbook

echo ""
echo "==> Base system setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal to load the new environment"
echo "  2. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
echo "  3. Create secrets files:"
echo "     - ~/.config/fish/conf.d/secrets.fish"
echo "     - ~/.zshrc.secrets"
echo "  4. Run VS Code extension sync: ~/.config/nix-config/scripts/vscode-extensions.sh"
echo ""
