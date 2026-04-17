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
# Accepts either the standalone Command Line Tools package or a full Xcode.app
# install — both provide what nix-darwin / Homebrew need.
clt_ready() {
    xcode-select -p &>/dev/null && /usr/bin/xcrun --find git &>/dev/null
}

install_clt() {
    log "Checking Xcode developer tools..."
    if clt_ready; then
        echo "Developer tools already installed at $(xcode-select -p)"
        return
    fi

    log "Installing Xcode Command Line Tools (a GUI dialog will appear)..."
    xcode-select --install 2>/dev/null || true

    echo "Waiting for installation to complete..."
    local waited=0
    until clt_ready; do
        sleep 5
        waited=$((waited + 5))
        if (( waited >= 1800 )); then
            die "Timed out waiting for CLT install after 30 min — check the installer GUI"
        fi
    done
    log "Xcode developer tools installed"
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

# ─── Clone or sync repo ───────────────────────────────────────────────────────
sync_repo() {
    if [ ! -d "$CONFIG_DIR" ]; then
        log "Cloning $REPO_URL → $CONFIG_DIR"
        git clone "$REPO_URL" "$CONFIG_DIR"
        return
    fi

    log "Repo exists at $CONFIG_DIR — syncing with remote..."
    cd "$CONFIG_DIR"

    # Refuse to touch a dirty tree — pulling could clobber local edits
    if [ -n "$(git status --porcelain)" ]; then
        warn "Working tree has uncommitted changes — skipping pull"
        warn "Commit, stash, or discard changes and re-run to sync"
        return
    fi

    # Fast-forward only so we never silently create merge commits
    git fetch --quiet origin
    if ! git pull --ff-only --quiet; then
        warn "git pull --ff-only failed (diverged branch?) — continuing with local state"
    fi
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
    sync_repo
    validate_flake_host
    build_darwin

    cat <<EOF

==> Base system setup complete!

Next steps:
  1. Restart your terminal to load the new environment
  2. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  3. Run VS Code extension sync: ~/.config/nix-config/scripts/vscode-extensions.sh

Env vars honored (all optional):
  REPO_URL         default: https://github.com/Gandalf-Le-Dev/nix-config.git
  CONFIG_DIR       default: \$HOME/.config/nix-config
  HOSTNAME_FLAKE   default: macbook
EOF
}

main "$@"
