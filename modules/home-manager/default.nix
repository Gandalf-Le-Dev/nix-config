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
  };

  # Secrets are loaded by zsh from ~/.config/zsh/secrets.zsh if it exists
  # (gitignored, not managed by Home Manager). See zsh.nix.
}
