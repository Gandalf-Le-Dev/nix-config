#!/usr/bin/env bash
set -euo pipefail

# ─── Config (override via env) ────────────────────────────────────────────────
REPO_URL="${REPO_URL:-https://github.com/Gandalf-Le-Dev/nix-config.git}"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/nix-config}"
HOSTNAME_FLAKE="${HOSTNAME_FLAKE:-macbook}"

# ─── Helpers ──────────────────────────────────────────────────────────────────
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==> WARN:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m==> ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# ─── Preflight ────────────────────────────────────────────────────────────────
preflight() {
    log "Running preflight checks..."

    # OS
    [[ "$(uname)" == "Darwin" ]] || die "This script is for macOS only"

    # Apple Silicon
    [[ "$(uname -m)" == "arm64" ]] || die "This config targets Apple Silicon only"

    # macOS version (nix-darwin baseline: macOS 12+)
    local macos_major
    macos_major="$(sw_vers -productVersion | cut -d. -f1)"
    if (( macos_major < 12 )); then
        die "macOS 12 (Monterey) or newer required, found $(sw_vers -productVersion)"
    fi

    # Admin group
    if ! /usr/bin/id -Gn | grep -qw admin; then
        die "Current user must be in the 'admin' group"
    fi

    # Network reachability
    if ! /usr/bin/curl -fsSL --max-time 5 https://github.com >/dev/null; then
        die "Cannot reach github.com — check your network"
    fi

    # Show effective config so the user can bail if HOSTNAME_FLAKE etc. look wrong
    cat <<EOF
    REPO_URL       = $REPO_URL
    CONFIG_DIR     = $CONFIG_DIR
    HOSTNAME_FLAKE = $HOSTNAME_FLAKE
    macOS          = $(sw_vers -productVersion) ($(uname -m))
EOF

    # Cache sudo up front, keep it alive for the rest of the run
    log "Caching sudo credentials..."
    sudo -v
    ( while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &

    log "Preflight OK"
}

# ─── Xcode Command Line Tools ─────────────────────────────────────────────────
install_clt() {
    log "Checking Xcode Command Line Tools..."
    if /usr/bin/pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &>/dev/null; then
        echo "Xcode CLT already installed"
        return
    fi

    log "Installing Xcode Command Line Tools (a GUI dialog will appear)..."
    xcode-select --install 2>/dev/null || true

    echo "Waiting for installation to complete..."
    until /usr/bin/pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &>/dev/null; do
        sleep 5
    done
    log "Xcode CLT installed"
}

# ─── Homebrew ─────────────────────────────────────────────────────────────────
install_homebrew() {
    log "Checking Homebrew..."
    if command -v brew &>/dev/null; then
        echo "Homebrew already installed"
    else
        log "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# ─── Nix ──────────────────────────────────────────────────────────────────────
install_nix() {
    log "Checking Nix..."
    if command -v nix &>/dev/null; then
        echo "Nix already installed"
    else
        log "Installing Nix (Determinate Systems installer)..."
        curl --proto '=https' --tlsv1.2 -sSf -L \
            https://install.determinate.systems/nix | sh -s -- install --no-confirm
    fi

    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # shellcheck disable=SC1091
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
}

# ─── SSH key ──────────────────────────────────────────────────────────────────
setup_ssh_key() {
    local key="$HOME/.ssh/id_ed25519"
    if [ -f "$key" ]; then
        echo "SSH key already exists at $key"
        return
    fi

    log "Generating ed25519 SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$key" -N "" -C "$(whoami)@$(hostname -s)"

    /usr/bin/pbcopy < "${key}.pub"
    log "Public key copied to clipboard."
    echo "    Add it at https://github.com/settings/ssh/new"
    echo ""
    cat "${key}.pub"
    echo ""
    read -r -p "Press ENTER once the key is added to GitHub (or Ctrl-C to skip)..."
}

# ─── Clone repo ───────────────────────────────────────────────────────────────
clone_repo() {
    if [ -d "$CONFIG_DIR" ]; then
        echo "nix-config already exists at $CONFIG_DIR"
        return
    fi
    log "Cloning $REPO_URL → $CONFIG_DIR"
    git clone "$REPO_URL" "$CONFIG_DIR"
}

# ─── Validate flake host ──────────────────────────────────────────────────────
validate_flake_host() {
    cd "$CONFIG_DIR"
    log "Validating flake has darwinConfigurations.${HOSTNAME_FLAKE}..."
    local hosts
    hosts="$(nix eval --json '.#darwinConfigurations' --apply 'builtins.attrNames' 2>/dev/null || echo '[]')"
    if ! echo "$hosts" | grep -q "\"${HOSTNAME_FLAKE}\""; then
        warn "Host '${HOSTNAME_FLAKE}' not found in flake. Available: $hosts"
        die "Set HOSTNAME_FLAKE env var to a valid host"
    fi
}

# ─── Seed secrets from templates ──────────────────────────────────────────────
seed_secrets() {
    local tpl_dir="$CONFIG_DIR/templates"
    local fish_secrets="$HOME/.config/fish/conf.d/secrets.fish"
    local zsh_secrets="$HOME/.zshrc.secrets"

    if [ ! -d "$tpl_dir" ]; then
        warn "No templates/ directory in repo — create one with secrets.fish.example and zshrc.secrets.example to auto-seed on future installs"
        return
    fi

    if [ ! -f "$fish_secrets" ] && [ -f "$tpl_dir/secrets.fish.example" ]; then
        mkdir -p "$(dirname "$fish_secrets")"
        cp "$tpl_dir/secrets.fish.example" "$fish_secrets"
        log "Seeded $fish_secrets"
    fi

    if [ ! -f "$zsh_secrets" ] && [ -f "$tpl_dir/zshrc.secrets.example" ]; then
        cp "$tpl_dir/zshrc.secrets.example" "$zsh_secrets"
        log "Seeded $zsh_secrets"
    fi
}

# ─── Build nix-darwin ─────────────────────────────────────────────────────────
build_darwin() {
    cd "$CONFIG_DIR"
    log "Building nix-darwin config for host: $HOSTNAME_FLAKE"
    sudo nix run nix-darwin -- switch --flake ".#${HOSTNAME_FLAKE}"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo "==> Setting up new macOS machine with Nix + nix-darwin..."
    preflight
    install_clt
    install_homebrew
    install_nix
    setup_ssh_key
    clone_repo
    validate_flake_host
    seed_secrets
    build_darwin

    cat <<EOF

==> Base system setup complete!

Next steps:
  1. Restart your terminal to load the new environment
  2. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  3. Review seeded secrets files:
       ~/.config/fish/conf.d/secrets.fish
       ~/.zshrc.secrets
  4. Run VS Code extension sync: ~/.config/nix-config/scripts/vscode-extensions.sh

Env vars honored (all optional):
  REPO_URL         default: https://github.com/Gandalf-Le-Dev/nix-config.git
  CONFIG_DIR       default: \$HOME/.config/nix-config
  HOSTNAME_FLAKE   default: macbook
EOF
}

main "$@"
