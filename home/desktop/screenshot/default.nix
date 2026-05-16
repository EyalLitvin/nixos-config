{ pkgs, ... }:

{
  home.packages = [ pkgs.grimblast ];

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, S, exec, grimblast copy area"           # SUPER+S → region select (most common)
    "$mod SHIFT, S, exec, grimblast copy screen"   # SUPER+SHIFT+S → full screen
    "$mod ALT, S, exec, grimblast copy active"     # SUPER+ALT+S → active window
  ];
}
