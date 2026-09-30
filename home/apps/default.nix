{ pkgs, ... }:

{
  imports = [
    ./3d-printing.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    firefox
    zapzap
  ];
}
