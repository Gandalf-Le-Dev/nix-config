{ pkgs, ... }:

{
  # Disable nix-darwin's Nix management (using Determinate Systems installer)
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
