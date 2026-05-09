{ pkgs, lib, stylixShared, ... }:

{
  stylix = {
    enable = true;
    inherit (stylixShared) base16Scheme image;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.fira;
        name = "Fira Sans";
      };
      serif = {
        package = pkgs.fira;
        name = "Fira Sans";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes.terminal = 13;
      sizes.applications = 18;
    };
    opacity.terminal = 0.75;
    targets.hyprpaper.enable = lib.mkForce false;
  };

  home.packages = [ pkgs.awww ];
}
