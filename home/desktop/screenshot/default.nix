{ pkgs, ... }:

{
  home.packages = [ pkgs.grimblast ];

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, SHIFT, exec, grimblast copy screen"
    "$mod, S, exec, grimblast copy area"
    "$mod, ALT, exec, grimblast copy active"
  ];
}
