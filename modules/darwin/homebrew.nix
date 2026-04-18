{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    taps = [
      "goreleaser/tap"
      "ovh/tap"
      "hopboxdev/tap"
    ];

    brews = [
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
      "hopboxdev/tap/hop"
    ];

    casks = [
      "arc"
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
      "alfred"
      "tailscale-app"
      "shottr"
      "goreleaser/tap/goreleaser"
    ];
  };
}
