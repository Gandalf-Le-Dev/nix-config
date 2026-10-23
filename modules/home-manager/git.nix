{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    settings = lib.mkMerge [ {
      user = {
        name = "Gandalf-Le-Dev";
        email = "matproz.gaming@gmail.com";
      };

      core = {
        autocrlf = "input";
        editor = "code --wait";
      };

      merge = {
        tool = "vscode";
        conflictStyle = "zdiff3";
      };

      "mergetool \"vscode\"" = {
        cmd = "code --wait ";
      };

      diff = {
        tool = "vscode";
      };

      "difftool \"vscode\"" = {
        cmd = "code --wait --diff  ";
      };

      alias = {
        publish = ''!f() { git push --set-upstream "''${1:-origin}" "$(git current-branch)"; }; f'';
        current-branch = "rev-parse --abbrev-ref HEAD";
      };

      "url \"ssh://git@github.com/\"" = {
        insteadOf = "https://github.com/";
      };
    }
    # delta comes from Homebrew, so the VPS has no binary for this pager.
    (lib.mkIf pkgs.stdenv.isDarwin {
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        dark = true;
      };
    }) ];
  };
}
