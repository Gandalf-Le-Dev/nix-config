{ config, pkgs, lib, ... }:

{
  # Smarter cd: `z <dir>` jumps to frecent dirs, `zi` for interactive (uses fzf).
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
