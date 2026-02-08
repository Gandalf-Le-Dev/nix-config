{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Programming languages
    go
    nodejs
    python3
    zig

    # Go tools
    golangci-lint

    # Development tools
    clang-tools  # Includes clang-format

    # Libraries and tools
    protobuf
    flatbuffers
    simdjson
    boost
    fmt
    # z3 - removed due to build failures on this macOS version, can be added back if needed
    duti
    swig
    chafa
  ];

  # Note: VS Code extension sync should be run manually after darwin-rebuild:
  # ~/.config/nix-config/scripts/vscode-extensions.sh
}
