#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Linux server with Nix + Home Manager..."

# Detect username and hostname
USERNAME="${USER}"
HOSTNAME="${1:-linux-server}"  # Pass hostname as argument or use default

# Install Nix (single-user mode for servers)
if ! command -v nix &> /dev/null; then
    echo "==> Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    echo "Nix already installed"
fi

# Clone this repo if not already present
CONFIG_DIR="$HOME/.config/nix-config"
REPO_URL="${REPO_URL:-git@github.com:Gandalf-Le-Dev/nix-config.git}"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "==> Cloning nix-config repository..."
    git clone "$REPO_URL" "$CONFIG_DIR"
else
    echo "nix-config already exists at $CONFIG_DIR"
    cd "$CONFIG_DIR" && git pull
fi

cd "$CONFIG_DIR"

# Build and activate home-manager configuration
echo "==> Building Home Manager configuration..."
nix run home-manager/master -- switch --flake ".#${USERNAME}@${HOSTNAME}"

echo ""
echo "==> Setup complete!"
echo ""
echo "Your dotfiles are now managed by Home Manager."
echo "To update in the future:"
echo "  cd ~/.config/nix-config"
echo "  git pull"
echo "  home-manager switch --flake .#${USERNAME}@${HOSTNAME}"
echo ""
