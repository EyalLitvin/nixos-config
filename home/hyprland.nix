{ config, pkgs, ... }:

{
  # Hyprland setup
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "kitty";
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod, M, exit"
      ];
    };
  };
}
