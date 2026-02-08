{ config, pkgs, lib, ... }:

{
  imports = [
    ./fish.nix
    ./ghostty.nix
    ./git.nix
    ./atuin.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.05";

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
