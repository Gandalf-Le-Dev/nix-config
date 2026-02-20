# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# System Configuration

This is a fully declarative macOS system configuration using **Nix flakes**, **nix-darwin**, and **Home Manager**.

- **Config location**: `~/.config/nix-config/`
- **System**: macOS (aarch64-darwin), hostname `macbook`
- **Nix distribution**: Determinate Nix (flakes enabled, no channels)

## Key Commands

```bash
# After editing any .nix file — always run from repo root
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook

# Update all flake inputs (nixpkgs, home-manager, etc.)
nix flake update --flake ~/.config/nix-config
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook

# Rollback if something breaks
sudo darwin-rebuild switch --rollback

# Free disk space
nix-collect-garbage -d

# Linux VPS (standalone Home Manager, no nix-darwin)
home-manager switch --flake ~/.config/nix-config#"debian@vps-e84ac0f1"

# Sync VS Code extensions
~/.config/nix-config/scripts/vscode-extensions.sh
~/.config/nix-config/scripts/vscode-extensions.sh --prune  # remove unlisted
```

## Architecture

The flake defines two output types:
- `darwinConfigurations.macbook` — full macOS system via `mkDarwinSystem`
- `homeConfigurations."debian@vps-e84ac0f1"` — standalone Home Manager for Linux VPS via `mkHomeConfiguration`

Module layers (applied in order for macOS):
- `hosts/macbook/default.nix` — machine-specific overrides
- `modules/common/` — cross-platform (nix settings, shared packages)
- `modules/darwin/` — macOS-only (homebrew, fonts, system preferences, shell, packages)
- `modules/home-manager/` — dotfiles via Home Manager (fish, git, ghostty, atuin, wakatime)

### Where to Add Things

| What | Where |
|------|-------|
| Packages on all machines | `modules/common/packages.nix` |
| macOS-only Nix packages | `modules/darwin/packages.nix` |
| Homebrew formulae/casks | `modules/darwin/homebrew.nix` |
| Dotfiles / program config | `modules/home-manager/<tool>.nix` + import in `modules/home-manager/default.nix` |
| VS Code extensions | `scripts/vscode-extensions.txt` |

## Important Rules

- **Never edit dotfiles directly** (e.g. `~/.config/fish/config.fish`). All changes must be in `.nix` files — direct edits are overwritten on next rebuild.
- **Never use `nix-env`** — all packages are declared declaratively.
- `flake.lock` is committed and should be updated intentionally with `nix flake update`.
- Rust toolchain is managed via `rustup`, not Nix.

## Secrets Pattern

Sensitive files (containing API keys, tokens) are kept out of the Nix store using `mkOutOfStoreSymlink` + `lib.mkIf (builtins.pathExists ...)`. They must be created manually on new machines:

- `~/.config/fish/conf.d/secrets.fish` — shell env vars (e.g. `WAKATIME_API_KEY`)

Files without secrets are managed with `home.file."<path>".text = ''...''` directly in Nix.
