{ config, lib, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font           = lib.mkForce "${config.stylix.fonts.sansSerif.name}:size=24";
        anchor         = "center";
        lines          = 6;
        width          = 30;
        terminal       = "kitty";
        icons-enabled  = true;
        horizontal-pad = 16;
        vertical-pad   = 8;
        inner-pad      = 4;
      };
      border = {
        width  = 2;
        radius = 8;
      };
    };
  };
}
