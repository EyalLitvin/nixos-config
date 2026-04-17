{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    ripgrep
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
