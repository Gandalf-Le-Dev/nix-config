{ config, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      # Sync to self-hosted server
      auto_sync = true;
      sync_address = "https://atuin.mroc.me";

      # Search settings
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";

      # Show preview of command
      show_preview = true;

      # Fuzzy search settings
      search_mode_shell_up_key_binding = "fuzzy";

      # Store more history
      max_history_length = 100000;

      # Key bindings (Ctrl+R for search)
      keymap_mode = "vim-normal";

      # QOL: Enter puts command in prompt instead of executing (safer!)
      enter_accept = false;

      # QOL: Show more results inline
      inline_height = 15;

      # QOL: Keep search query when exiting without selection
      exit_mode = "return-query";

      # QOL: Filter history by current directory (toggle with Ctrl+r Ctrl+r)
      workspaces = true;

      # QOL: Auto-filter commands with secrets (API keys, tokens, passwords)
      secrets_filter = true;

      # QOL: Don't store failed commands in history
      store_failed = false;

      # QOL: Enable natural date search (e.g., "yesterday", "last week")
      dialect = "us";

      # Don't record commands that start with a space
      history_filter = [
        "^\\s+"  # commands starting with space
      ];

      # Update check
      update_check = false;
    };
  };
}
