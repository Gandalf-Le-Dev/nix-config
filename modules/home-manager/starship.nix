{ config, pkgs, lib, ... }:

{
  # Cross-shell prompt — replaces the old hand-rolled fish_prompt.
  # Two-line layout (user@host path  git  time) themed to Catppuccin Macchiato
  # to match the ghostty theme.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = false;
      palette = "catppuccin_macchiato";

      format = ''
        [╭─ ](overlay1)$username[@](overlay1)$hostname $directory$git_branch$git_status$cmd_duration$time
        [╰─](overlay1)$character'';

      username = {
        show_always = true;
        style_user = "mauve";
        style_root = "red";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "mauve";
        format = "[$hostname]($style)";
      };

      directory = {
        style = "blue";
        truncation_length = 3;
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };

      git_branch = {
        style = "yellow";
        format = "[ $symbol$branch]($style)";
      };

      git_status = {
        style = "red";
        format = "([ $all_status$ahead_behind]($style))";
      };

      cmd_duration = {
        min_time = 2000;
        style = "overlay1";
        format = "[ $duration]($style)";
      };

      time = {
        disabled = false;
        style = "overlay1";
        format = "[  $time]($style)";
        time_format = "%H:%M:%S";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };

      palettes.catppuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };
    };
  };
}
