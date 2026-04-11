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

  # This is the home-manager equivalent of system.stateVersion.
  # Same rule: set it once, never change it.
  home.stateVersion = "24.11";
}
