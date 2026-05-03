{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./terminal.nix
    ./apps.nix
    ./hyprland.nix
    ./git.nix
    ./secrets.nix
    ./shell-tools.nix
    ./nvim.nix
    ./languages.nix
    ./qutebrowser.nix
    ./yazi.nix
    ./clipboard.nix
    ./screenshot.nix
    ./notifications.nix
    ./stylix.nix
    ./waybar.nix
    ./repos.nix
    ./imv.nix
  ];

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.username = "eyal";
  home.homeDirectory = "/home/eyal";

  # This is the home-manager equivalent of system.stateVersion.
  # Same rule: set it once, never change it.
  gtk.gtk4.theme = null;

  home.stateVersion = "24.11";
}
