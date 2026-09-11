{ pkgs, ... }:

{
  imports = [
    ./3d-printing.nix
    ./openacp.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    firefox
    zapzap
  ];
}
