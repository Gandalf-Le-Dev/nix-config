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
      vk = "npx vibe-kanban";

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
        set_color normal
        echo -n '╭─ '

        # Username@hostname
        set_color normal
        echo -n $USER'@'
        set_color green
        echo -n (string replace -r '\.local$' "" $hostname)' '

        # Full path
        set_color blue
        echo -n $PWD

        # Git branch info
        set_color yellow
        echo -n (__fish_git_prompt)

        # Timestamp
        set_color brblack
        echo -n ' ' (date "+%H:%M:%S")

        set_color normal
        echo
        echo -n '╰'
        set_color green
        echo -n '❯ '
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
