{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.commit-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.meslo-lg

    # Inter font
    inter
  ];

  # Note: Maple Mono stays as a Homebrew cask
}
