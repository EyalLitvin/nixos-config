{ ... }:

{
  imports = [
    ./users
    ./sudo
  ];

  programs.firejail.enable = true;
}
