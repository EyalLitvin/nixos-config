{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "EyalLitvin";
      user.email = "eyalitvin@email.com";
    };
  };
}
