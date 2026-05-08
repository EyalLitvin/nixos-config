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
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes.terminal = 13;
    };
    opacity.terminal = 0.75;
    targets.hyprpaper.enable = lib.mkForce false;
  };

  home.packages = [ pkgs.awww ];
}
