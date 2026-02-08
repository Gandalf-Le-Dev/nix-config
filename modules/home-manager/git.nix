{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
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
    };
  };
}
