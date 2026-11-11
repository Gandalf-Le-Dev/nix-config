{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    taps = [
      "goreleaser/tap"
      "ovh/tap"
    ];

    brews = [
      # Better in Homebrew on macOS
      "dotnet"
      "mono"
      "llvm"
      "llvm@18"
      "llvm@20"
      "openjdk"
      "herdr"
    ];

    casks = [
      "dotnet-runtime"
      "font-maple-mono"
      "font-maple-mono-nf"
      "gcc-arm-embedded"
      "ghostty"
      "ovh/tap/ovhcloud-cli"
      "visual-studio-code"
      "docker-desktop"
      "discord"
      "zen"
      "tailscale-app"
      "shottr"
      "goreleaser/tap/goreleaser"
      "finetune"
      "vorssaint"
    ];
  };
}
