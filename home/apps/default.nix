{ pkgs, ... }:

{
  imports = [ ./3d-printing.nix ];

  home.packages = with pkgs; [
    firefox
    claude-code
    zapzap
  ];
}
