{ pkgs, ... }:

{
  home.packages = with pkgs; [
    firefox
    claude-code
    zapzap
  ];
}
