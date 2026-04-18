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

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      cat = "bat";
      cs = "z";
    };
  };

  # Starship setup
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
