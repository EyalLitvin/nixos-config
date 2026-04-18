{ config, pkgs, ... }:

{
  # Kitty setup
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 13;
    };

    settings = {
      font_features = "FiraCodeNFM-DemiBold";
    };
  };
}
