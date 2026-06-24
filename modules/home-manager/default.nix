{ config, pkgs, lib, ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./ghostty.nix
    ./git.nix
    ./atuin.nix
    ./zoxide.nix
    ./wakatime.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.05";

  # Packages that need to be in Home Manager for Linux
  home.packages = with pkgs; [
    # Shell tools (also needed on Linux servers)
    atuin
    bat
    ripgrep
    fzf
    tree
    zellij
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "code";
    VISUAL = "code";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # macOS-specific
    DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec";
  } // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
    # The VPS only has C.UTF-8 generated, but SSH forwards en_US.UTF-8 from
    # the Mac. The missing locale breaks zsh's line editor (garbled input
    # with starship's Unicode prompt). Pin the always-present C.UTF-8.
    LANG = "C.UTF-8";
    LC_ALL = "C.UTF-8";
  };

  # Secrets are loaded by zsh from ~/.config/zsh/secrets.zsh if it exists
  # (gitignored, not managed by Home Manager). See zsh.nix.
}
