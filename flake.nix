{
  description = "gandalfledev's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
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

            # Home Manager integration
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./modules/home-manager;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.backupFileExtension = "backup-before-hm";
            }

            {
              users.users.${username}.home = "/Users/${username}";
              networking.hostName = hostname;
            }
          ];
          specialArgs = { inherit inputs; };
        };

      mkHomeConfiguration = { hostname, system, username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./modules/home-manager
            {
              home = {
                username = username;
                homeDirectory = homeDirectory;
                stateVersion = "24.05";
              };
            }
          ];
          extraSpecialArgs = { inherit inputs; };
        };
    in
    {
      # macOS configuration
      darwinConfigurations = {
        macbook = mkDarwinSystem {
          hostname = "macbook";
          system = "aarch64-darwin";
          username = "gandalfledev";
        };
      };

      # Linux/standalone Home Manager configurations
      homeConfigurations = {
        # Example: your Linux server
        "gandalfledev@linux-server" = mkHomeConfiguration {
          hostname = "linux-server";
          system = "x86_64-linux";  # or "aarch64-linux" for ARM
          username = "gandalfledev";
          homeDirectory = "/home/gandalfledev";
        };
      };
    };
}
