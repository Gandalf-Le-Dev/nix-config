{ ... }:

{
  # User configuration
  users.users.gandalfledev = {
    name = "gandalfledev";
    home = "/Users/gandalfledev";
  };

  # Hostname
  networking.hostName = "macbook";

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # State version
  system.stateVersion = 5;
}
