{ config, lib, ... }:

{
  # Keep .wakatime.cfg out of the Nix store (contains secret API key).
  # The file must exist manually at ~/.wakatime.cfg (gitignored).
  home.file.".wakatime.cfg" = lib.mkIf
    (builtins.pathExists "${config.home.homeDirectory}/.wakatime.cfg") {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.wakatime.cfg";
  };
}
