{ pkgs, ... }:

{
  users.mutableUsers = false;

  users.users.eyal = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$ZgMaueXVa5YfoppG$BAZFUVPVVdXSkmNBeewildzRKy9iOjnxyKKUweovCyyjhuZ3TUF5YHGwPXweEuiePFo787Tb6Y7n37aZ2BgO/0";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
