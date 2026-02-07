{
  description = "gandalfledev's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin }:
    let
      mkDarwinSystem = { hostname, system, username }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./hosts/${hostname}/default.nix
            ./modules/common/nix-settings.nix
            ./modules/common/packages.nix
            ./modules/darwin/packages.nix
            ./modules/darwin/homebrew.nix
            ./modules/darwin/system.nix
            ./modules/darwin/fonts.nix
            ./modules/darwin/shell.nix
            {
              users.users.${username}.home = "/Users/${username}";
              networking.hostName = hostname;
            }
          ];
          specialArgs = { inherit inputs; };
        };
    in
    {
      darwinConfigurations = {
        macbook = mkDarwinSystem {
          hostname = "macbook";
          system = "aarch64-darwin";
          username = "gandalfledev";
        };
      };
    };
}
