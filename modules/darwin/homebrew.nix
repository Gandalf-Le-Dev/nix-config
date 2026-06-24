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
      # macOS ships curl built against LibreSSL with fewer features; use brew's.
      "curl"
      "dotnet"
      "mono"
      "llvm"
      "llvm@18"
      "llvm@20"
      "openjdk"
      "postgrest"
      "herdr"
      "hopboxdev/tap/hop"
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
      "alfred"
      "tailscale-app"
      "shottr"
      "goreleaser/tap/goreleaser"
      "finetune"
    ];
  };
}
