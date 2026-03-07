{ config, pkgs, lib, ... }:

{
  imports = [
    ./fish.nix
    ./ghostty.nix
    ./git.nix
    ./atuin.nix
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

  # Secrets file (gitignored, not managed by Home Manager)
  # Only create symlink if secrets file already exists
  home.file.".config/fish/conf.d/secrets.fish" = lib.mkIf
    (builtins.pathExists "${config.home.homeDirectory}/.config/fish/conf.d/secrets.fish") {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/fish/conf.d/secrets.fish";
  };
}
