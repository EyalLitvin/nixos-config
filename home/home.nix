{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./terminal.nix
    ./apps.nix
    ./hyprland.nix
    ./git.nix
    ./shell-tools.nix
    ./fonts.nix
    ./nvim.nix
    ./languages.nix
    ./qutebrowser.nix
  ];

  programs.home-manager.enable = true;

  home.username = "eyal";
  home.homeDirectory = "/home/eyal";

  # This is the home-manager equivalent of system.stateVersion.
  # Same rule: set it once, never change it.
  home.stateVersion = "24.11";
}
