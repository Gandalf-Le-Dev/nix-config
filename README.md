# Nix + nix-darwin Configuration

Declarative macOS system configuration using Nix and nix-darwin.

## Quick Start

### Daily Usage

```bash
# Rebuild system after editing any .nix file
darwin-rebuild switch --flake ~/.config/nix-config#macbook

# Update all packages (nixpkgs + homebrew)
nix flake update --flake ~/.config/nix-config
darwin-rebuild switch --flake ~/.config/nix-config#macbook

# Rollback if something breaks
darwin-rebuild switch --rollback

# Reclaim disk space
nix-collect-garbage -d
```

### Adding Packages

- **Common packages** (all machines): Edit `modules/common/packages.nix`
- **macOS-only packages**: Edit `modules/darwin/packages.nix`
- **Homebrew formulae/casks**: Edit `modules/darwin/homebrew.nix`

### VS Code Extensions

Extensions are managed declaratively in `scripts/vscode-extensions.txt`.

```bash
# Sync extensions after updating the list
~/.config/nix-config/scripts/vscode-extensions.sh

# Prune unlisted extensions
~/.config/nix-config/scripts/vscode-extensions.sh --prune
```

## Structure

```
.
├── flake.nix              # Entry point
├── flake.lock            # Lock file (committed)
├── hosts/
│   └── macbook/
│       └── default.nix   # This machine's config
├── modules/
│   ├── common/           # Cross-platform modules
│   │   ├── nix-settings.nix
│   │   └── packages.nix
│   └── darwin/           # macOS-specific modules
│       ├── packages.nix
│       ├── homebrew.nix
│       ├── system.nix
│       ├── fonts.nix
│       └── shell.nix
└── scripts/
    ├── install.sh                # Bootstrap script
    ├── vscode-extensions.sh      # VS Code extension sync
    └── vscode-extensions.txt     # Extension list
```

## Notes

- **Nix installation**: Managed by Determinate Systems installer (not nix-darwin)
- **Rust toolchain**: Managed separately via `rustup` (not in Nix)
- **Secrets**: Stored in gitignored files:
  - `~/.config/fish/conf.d/secrets.fish`
  - `~/.zshrc.secrets`

## New Machine Setup

See `scripts/install.sh` for automated setup on a new machine.
