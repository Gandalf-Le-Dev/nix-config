{ pkgs, ... }:

{
  # Enable zsh (system integration: /etc/zshrc sources Nix, completions, etc.)
  programs.zsh.enable = true;

  # Add zsh to available shells
  environment.shells = with pkgs; [
    zsh
  ];
}
