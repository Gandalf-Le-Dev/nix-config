{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shell and CLI tools
    fish
    gh
    # Note: atuin, bat, ripgrep, fzf, tree moved to Home Manager for cross-platform support

    # Version control
    jujutsu

    # Build tools
    cmake
    ninja
    gnumake

    # Cloud and DevOps
    awscli2
    terraform
    kubernetes-helm
    k9s
    go-task
  ];
}
