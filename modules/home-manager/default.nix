{ config, pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./ghostty.nix
    ./git.nix
  ];

  # Home Manager state version
  home.stateVersion = "24.05";

  # Environment variables
  home.sessionVariables = {
    EDITOR = "code";
    VISUAL = "code";
    DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec";
  };

  # Secrets file (gitignored, not managed by Home Manager)
  home.file.".config/fish/conf.d/secrets.fish" = {
    source = config.lib.file.mkOutOfStoreSymlink "/Users/gandalfledev/.config/fish/conf.d/secrets.fish";
  };
}
