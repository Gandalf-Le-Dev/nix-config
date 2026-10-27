{ config, pkgs, ... }:

{
  # Generated from Rex Beta.app themes.json (whitby-bay, merino-light) to match the Rex terminal.
  home.file.".config/ghostty/themes/rex-whitby-bay".source = ./ghostty-themes/rex-whitby-bay;
  home.file.".config/ghostty/themes/rex-merino-light".source = ./ghostty-themes/rex-merino-light;

  home.file.".config/ghostty/config".text = ''
    theme = light:rex-merino-light,dark:rex-whitby-bay
    font-family = Maple Mono NF
    font-size = 14
    window-padding-x = 16
    window-padding-y = 8
    font-feature = +cv02
    quit-after-last-window-closed = false
    macos-option-as-alt = false
  '';
}
