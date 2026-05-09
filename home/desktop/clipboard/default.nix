{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cliphist
    wl-clipboard
  ];
}
