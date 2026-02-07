# Nix + nix-darwin + Home Manager Configuration

Fully declarative macOS system configuration using Nix, nix-darwin, and Home Manager.

## Quick Start

### Daily Usage

```bash
# Rebuild system after editing any .nix file
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook

# Update all packages (nixpkgs + homebrew)
nix flake update --flake ~/.config/nix-config
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook

# Rollback if something breaks
sudo darwin-rebuild switch --rollback

# Reclaim disk space
nix-collect-garbage -d
```

### Adding Packages

- **Common packages** (all machines): Edit `modules/common/packages.nix`
- **macOS-only packages**: Edit `modules/darwin/packages.nix`
- **Homebrew formulae/casks**: Edit `modules/darwin/homebrew.nix`

### Modifying Dotfiles (Home Manager)

All dotfiles are now managed declaratively through Home Manager:

- **Fish config**: Edit `modules/home-manager/fish.nix`
- **Git config**: Edit `modules/home-manager/git.nix`
- **Ghostty config**: Edit `modules/home-manager/ghostty.nix`

After editing, rebuild:
```bash
sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook
```

**Important**: Do NOT edit dotfiles directly (e.g., `~/.config/fish/config.fish`). Changes will be overwritten on next rebuild. All changes must be made in the Nix files.

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
- **Home Manager**: Manages all dotfiles declaratively
  - Fish, Git, Ghostty configs are all in Nix
  - Changes must be made in `.nix` files, not directly in dotfiles
  - Old configs backed up with `.backup-before-hm` extension
- **Secrets**: Stored in gitignored files (not managed by Home Manager):
  - `~/.config/fish/conf.d/secrets.fish`
  - `~/.zshrc.secrets`

## New Machine Setup

See `scripts/install.sh` for automated setup on a new machine.
