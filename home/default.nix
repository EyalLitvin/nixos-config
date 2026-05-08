{ ... }:

{
  imports = [
    ./shell
    ./terminal
    ./cli
    ./editor
    ./desktop
    ./browser
    ./media
    ./dev
    ./theming
    ./secrets
    ./apps
  ];

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.username = "eyal";
  home.homeDirectory = "/home/eyal";

  gtk.gtk4.theme = null;

  home.stateVersion = "24.11";
}
