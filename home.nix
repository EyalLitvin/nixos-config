{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.username = "eyal";
  home.homeDirectory = "/home/eyal";

  programs.git = {
    enable = true;
    settings = {
      user.name = "EyalLitvin";
      user.email = "eyalitvin@email.com";
    };
  };

  # Kitty setup
  programs.kitty.enable = true;

  # Hyprland setup
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "kitty";
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod, M, exit"
      ];
    };
  };
        
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


  # This is the home-manager equivalent of system.stateVersion.
  # Same rule: set it once, never change it.
  home.stateVersion = "24.11";
}
