{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

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

      # Nix rebuild aliases
      nix-rebuild-mac = "sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook";
      nix-rebuild-vps = "nix run home-manager/master -- switch --flake .#debian@vps-e84ac0f1";
    };

    shellAbbrs = {
      gco = "git checkout";
      gcom = "git checkout main";
      gcob = "git checkout -b";
      gst = "git status";
      gpl = "git pull";
      gcm = "git commit -m";
    };

    interactiveShellInit = ''
      # === Nix Setup ===
      # Nix daemon (system-wide Nix installation)
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      else if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix.fish
      end

      # Home Manager profile (user packages)
      fish_add_path -p ~/.nix-profile/bin

      # === PATH Setup ===
      # macOS Homebrew (if it exists)
      if test -d /opt/homebrew/bin
          fish_add_path -p /opt/homebrew/bin
      end
      fish_add_path -p /usr/local/bin

      # GDVM path
      fish_add_path -p ~/.gdvm/bin
      fish_add_path -p ~/.gdvm/bin/current_godot

      # Local bin
      if test -d ~/.local/bin
          fish_add_path ~/.local/bin
      end

      # Cargo (Rust)
      if test -d ~/.cargo/bin
          fish_add_path ~/.cargo/bin
      end

      # Go
      if test -d ~/go/bin
          fish_add_path ~/go/bin
      end

      # Custom zig location
      if test -d /usr/local/zig
          fish_add_path /usr/local/zig
      end

      # === History Settings ===
      set -g fish_history_size 10000

      # === Colors ===
      set -g fish_color_command blue
      set -g fish_color_error red
      set -g fish_color_comment brblack

      # === Auto-completion ===
      set -g fish_complete_case_insensitive true

      # === Git Prompt Settings ===
      set __fish_git_prompt_showdirtystate 'yes'
      set __fish_git_prompt_showuntrackedfiles 'yes'

      # === SSH Agent Setup ===
      # Start ssh-agent if not running
      if not set -q SSH_AUTH_SOCK
          eval (ssh-agent -c) > /dev/null
          set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
          set -Ux SSH_AGENT_PID $SSH_AGENT_PID
      end
    '';

    functions = {
      # Quick directory creation and navigation
      mkcd = ''
        mkdir -p $argv[1] && cd $argv[1]
      '';

      # Extract archives
      extract = ''
        if test -f $argv[1]
            switch $argv[1]
                case '*.tar.bz2'
                    tar xjf $argv[1]
                case '*.tar.gz'
                    tar xzf $argv[1]
                case '*.bz2'
                    bunzip2 $argv[1]
                case '*.rar'
                    unrar x $argv[1]
                case '*.gz'
                    gunzip $argv[1]
                case '*.tar'
                    tar xf $argv[1]
                case '*.tbz2'
                    tar xjf $argv[1]
                case '*.tgz'
                    tar xzf $argv[1]
                case '*.zip'
                    unzip $argv[1]
                case '*.Z'
                    uncompress $argv[1]
                case '*.7z'
                    7z x $argv[1]
                case '*'
                    echo "'$argv[1]' cannot be extracted via extract()"
            end
        else
            echo "'$argv[1]' is not a valid file"
        end
      '';

      # Open Git repository in browser
      gitopen = ''
        set remote_url (git config --get remote.origin.url)
        set branch_name (git rev-parse --abbrev-ref HEAD)

        if test -n "$remote_url"
            if string match -q "git@*" "$remote_url"
                set https_url (string replace -r 'git@github\.com:' 'https://github.com/' "$remote_url" | string replace -r '\.git$' "")
            else
                set https_url (string replace -r '\.git$' "" "$remote_url")
            end

            if test -n "$branch_name"
                set https_url "$https_url/tree/$branch_name"
            end

            switch (uname)
                case Darwin
                    open "$https_url"
                case CYGWIN_NT-* MINGW*
                    start "$https_url"
                case Linux
                    xdg-open "$https_url"
                case '*'
                    echo "Unsupported operating system"
            end
        else
            echo "Warning: Git remote URL is empty. Please check your repository configuration."
        end
      '';

      # Custom prompt
      fish_prompt = ''
        set -l last_status $status

        # ── Top line ──
        set_color brblack
        echo -n '╭─ '

        # Username@hostname
        set_color magenta
        echo -n ' '$USER
        set_color brblack
        echo -n '@'
        set_color magenta
        echo -n (string replace -r '\.local$' "" $hostname)

        # Path (~ for home, truncate middle dirs)
        set_color blue
        echo -n ' '
        set -l display_path (string replace "$HOME" "~" $PWD)
        set -l parts (string split "/" $display_path)
        if test (count $parts) -gt 4
            echo -n $parts[1]'/'
            for i in (seq 2 (math (count $parts) - 2))
                echo -n (string sub -l 1 $parts[$i])'/'
            end
            echo -n $parts[-2]'/'$parts[-1]
        else
            echo -n $display_path
        end

        # Git info
        if git rev-parse --is-inside-work-tree &>/dev/null
            set -l branch (git branch --show-current 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
            set_color brblack
            echo -n ' '
            set_color yellow
            echo -n ' '$branch

            # Status indicators
            set -l indicators
            if not git diff --quiet 2>/dev/null
                set -a indicators (set_color red)'●'  # dirty
            end
            if not git diff --cached --quiet 2>/dev/null
                set -a indicators (set_color green)'●'  # staged
            end
            if test -n "$(git ls-files --others --exclude-standard 2>/dev/null)"
                set -a indicators (set_color blue)'+'  # untracked
            end

            set -l ahead (git rev-list --count @{upstream}..HEAD 2>/dev/null)
            set -l behind (git rev-list --count HEAD..@{upstream} 2>/dev/null)
            if test -n "$ahead" -a "$ahead" -gt 0
                set -a indicators (set_color cyan)'⇡'$ahead
            end
            if test -n "$behind" -a "$behind" -gt 0
                set -a indicators (set_color cyan)'⇣'$behind
            end

            if test (count $indicators) -gt 0
                echo -n ' '(string join "" $indicators)
            end
        end

        # Timestamp
        set_color brblack
        echo -n '  '(date "+%H:%M:%S")

        # ── Bottom line ──
        set_color normal
        echo
        set_color brblack
        echo -n '╰─'
        if test $last_status -eq 0
            set_color green
            echo -n '❯ '
        else
            set_color red
            echo -n '❯ '
        end
        set_color normal
      '';

      # Custom greeting
      fish_greeting = ''
        set hour (date "+%H")
        if test $hour -lt 6
            set greeting "Good night 🌃"
        else if test $hour -lt 12
            set greeting "Good morning 🌅"
        else if test $hour -lt 18
            set greeting "Good afternoon ☀️"
        else if test $hour -lt 21
            set greeting "Good evening 🌆"
        else
            set greeting "Good night 🌙"
        end
        echo "$greeting, $USER! 💻✨"
      '';
    };
  };
}
