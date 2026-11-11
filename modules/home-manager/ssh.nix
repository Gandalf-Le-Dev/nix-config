{ pkgs, lib, ... }:

# The Mac keeps its own unmanaged ~/.ssh/config.
lib.mkIf (!pkgs.stdenv.isDarwin) {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "hopbox/*.config" ];
    matchBlocks."github.com" = {
      identityFile = "~/.ssh/id_ed25519_github";
      identitiesOnly = true;
      # The key has a passphrase; ask for it once per agent.
      addKeysToAgent = "yes";
    };
  };
}
