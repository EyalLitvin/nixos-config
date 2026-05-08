{ pkgs, ... }:

{
  programs.fuzzel.enable = true;

  home.packages = with pkgs; [
    cliphist
    wl-clipboard
  ];
}
