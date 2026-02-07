{ pkgs, ... }:

{
  # Enable fish shell
  programs.fish.enable = true;

  # Add fish to available shells
  environment.shells = with pkgs; [
    fish
  ];
}
