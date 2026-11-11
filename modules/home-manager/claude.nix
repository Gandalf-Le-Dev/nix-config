{ config, ... }:

{
  # Out-of-store link: edits to ~/.claude/CLAUDE.md land in the repo, no rebuild needed.
  home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/nix-config/dotfiles/claude/CLAUDE.md";
}
