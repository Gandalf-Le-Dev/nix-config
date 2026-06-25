{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # oh-my-zsh: kept for its excellent git plugin (aliases + completions).
    # Prompt is handled by starship (see starship.nix), so no omz theme.
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "sudo"
        "dirhistory"
      ];
      # Skip compaudit's slow insecure-directory scan on every startup
      # (set before oh-my-zsh.sh is sourced). ~40% of startup time.
      # Only on the single-user Mac; keep the security audit on the
      # (potentially multi-user) Linux VPS.
      extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
        ZSH_DISABLE_COMPFIX="true"
      '';
    };

    shellAliases = {
      # Basic aliases
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      c = "clear";
      ccusage = "npx ccusage@latest";

      # Grep with color
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      # Git aliases
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";
      gd = "git diff";
      gsw = "git switch";

      # Git (was fish abbrs)
      gco = "git checkout";
      gcom = "git checkout main";
      gcob = "git checkout -b";
      gst = "git status";
      gpl = "git pull";
      gcm = "git commit -m";

      # Go aliases
      gor = "go run";
      gob = "go build";
      got = "go test";
      gof = "go fmt";
      gom = "go mod";
      goi = "go install";
      gov = "go version";
      goget = "go get";
      goclean = "go clean";
      govet = "go vet";

      # Docker aliases
      dc = "docker compose";

      # Claude Code (--dangerously-skip-permissions)
      cc = "claude --dangerously-skip-permissions";
      ccr = "claude --continue --dangerously-skip-permissions";

      # Nix rebuild aliases
      nix-rebuild-mac = "sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook";
      nix-rebuild-vps = "nix run home-manager/master -- switch --flake .#debian@vps-e84ac0f1";
    };

    initContent = lib.mkOrder 1000 ''
      # === Completion ===
      # Case-insensitive matching
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # === Nix Setup ===
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      elif [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
      fi

      # === PATH Setup ===
      # Prepend dirs that exist; typeset -U keeps PATH de-duplicated.
      typeset -U path
      for __dir in \
        "$HOME/.nix-profile/bin" \
        /opt/homebrew/opt/curl/bin \
        /opt/homebrew/bin \
        /usr/local/bin \
        "$HOME/.gdvm/bin" \
        "$HOME/.gdvm/bin/current_godot" \
        "$HOME/.local/bin" \
        "$HOME/.cargo/bin" \
        "$HOME/go/bin" \
        /usr/local/zig; do
        [ -d "$__dir" ] && path=("$__dir" $path)
      done
      unset __dir
      export PATH

      # === SSH Agent ===
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null
      fi

      # === Functions ===
      # Quick directory creation and navigation
      mkcd() { mkdir -p "$1" && cd "$1"; }

      # Extract archives
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # Open Git repository in browser
      gitopen() {
        local remote_url branch_name https_url
        remote_url=$(git config --get remote.origin.url)
        branch_name=$(git rev-parse --abbrev-ref HEAD)

        if [ -n "$remote_url" ]; then
          case "$remote_url" in
            git@*) https_url=$(echo "$remote_url" | sed -E 's#git@github\.com:#https://github.com/#; s#\.git$##') ;;
            *)     https_url=$(echo "$remote_url" | sed -E 's#\.git$##') ;;
          esac

          [ -n "$branch_name" ] && https_url="$https_url/tree/$branch_name"

          case "$(uname)" in
            Darwin) open "$https_url" ;;
            Linux)  xdg-open "$https_url" ;;
            *)      echo "Unsupported operating system" ;;
          esac
        else
          echo "Warning: Git remote URL is empty. Please check your repository configuration."
        fi
      }

      # === Secrets (gitignored, optional) ===
      [ -f "$HOME/.config/zsh/secrets.zsh" ] && source "$HOME/.config/zsh/secrets.zsh"
    '';
  };
}
