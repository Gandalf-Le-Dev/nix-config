{ config, pkgs, ... }:

{
  home.file.".config/ghostty/config".text = ''
    theme = dark:Catppuccin Macchiato,light:alabaster
    font-family = Maple Mono NF
    font-size = 14
    window-padding-x = 16
    window-padding-y = 8
    font-feature = +cv02
    quit-after-last-window-closed = true
    command = /run/current-system/sw/bin/fish --login --interactive
    macos-option-as-alt = false
  '';
}
