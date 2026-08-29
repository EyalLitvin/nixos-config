{ lib, pkgs, ... }:

let
  inherit (lib.generators) mkLuaInline;

  bind = keys: cmd: {
    _args = [ keys (mkLuaInline "hl.dsp.exec_cmd(${builtins.toJSON cmd})") ];
  };
in
{
  home.packages = [ pkgs.grimblast ];

  wayland.windowManager.hyprland.settings.bind = [
    (bind "SUPER + S" "grimblast copy area")           # SUPER+S → region select (most common)
    (bind "SUPER + SHIFT + S" "grimblast copy screen") # SUPER+SHIFT+S → full screen
    (bind "SUPER + ALT + S" "grimblast copy active")   # SUPER+ALT+S → active window
  ];
}
