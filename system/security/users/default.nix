{ pkgs, ... }:

{
  users.users.eyal = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
