{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shell and CLI tools
    fish
    bat
    ripgrep
    fzf
    tree
    gh
    atuin  # Shell history sync

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
