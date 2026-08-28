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

  home.stateVersion = "24.11";
}
