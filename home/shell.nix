{ config, pkgs, ... }:

{
  # Zsh setup
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };
  };

  # Starship setup
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
