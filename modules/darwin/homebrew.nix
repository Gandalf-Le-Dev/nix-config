{ ... }:

{
  homebrew = {
    enable = true;

    # Disable automatic cleanup to avoid dependency conflicts
    # Run 'brew autoremove' manually when needed to clean up unused packages
    onActivation.cleanup = "none";

    # Custom taps for embedded/QMK toolchain
    taps = [
      "qmk/qmk"
      "osx-cross/avr"
      "ovh/tap"
      "goreleaser/tap"
    ];

    # Formulae that stay in Homebrew
    brews = [
      # Embedded/QMK toolchain (custom taps, not in nixpkgs)
      "qmk"
      "avr-binutils"
      "avr-gcc@8"
      # ARM toolchain is installed via gcc-arm-embedded cask below
      "avrdude"
      "dfu-programmer"
      "dfu-util"
      "teensy_loader_cli"
      "mdloader"
      "hid_bootloader_cli"
      "bootloadhid"
      "hidapi"
      # Note: clang-format moved to Nix (clang-tools package)

      # Go tooling
      "golangci-lint"
      "rtk"

      # Better in Homebrew on macOS
      "dotnet"
      "mono"
      "llvm"
      "llvm@18"
      "llvm@20"
      "openjdk"
      "postgrest"
    ];

    # All casks stay in Homebrew
    casks = [
      "arc"
      "dotnet-runtime"
      "font-maple-mono"
      "font-maple-mono-nf"
      "gcc-arm-embedded"
      "ghostty"
      "ovhcloud-cli"
      "visual-studio-code"
      "docker-desktop"  # renamed from docker
      "discord"
      "zen"  # renamed from zen-browser
      "alfred"
      "tailscale-app"  # renamed from tailscale
      "shottr"
      "goreleaser"
    ];
  };
}
