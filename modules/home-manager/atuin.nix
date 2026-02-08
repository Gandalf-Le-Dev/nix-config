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

      # Don't record commands that start with a space
      history_filter = [
        "^\\s+"  # commands starting with space
      ];

      # Update check
      update_check = false;
    };
  };
}
