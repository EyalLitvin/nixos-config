{ pkgs, ... }:

{
  imports = [
    ./3d-printing.nix
    ./openacp.nix
  ];

  home.packages = with pkgs; [
    firefox
    zapzap
  ];
}
