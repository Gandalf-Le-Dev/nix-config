{ ... }:

{
  homebrew = {
    enable = true;

    # Start with "none" to avoid accidental uninstalls during migration
    # Switch to "zap" later after verifying everything is listed
    onActivation.cleanup = "none";

    # Custom taps for embedded/QMK toolchain
    taps = [
      "qmk/qmk"
      "osx-cross/avr"
      "ovh/tap"
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
      "clang-format"

      # Better in Homebrew on macOS
      "dotnet"
      "mono"
      "llvm"
      "llvm@18"
      "llvm@20"
      "openjdk"
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
      "docker"
      "discord"
      "zen-browser"
      "alfred"
      "tailscale"
      "shottr"
    ];
  };
}
