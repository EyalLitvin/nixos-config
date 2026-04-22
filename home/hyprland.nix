{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "kitty";
      "$browser" = "qutebrowser";
      "$explorer" = "oil";
      "$mod" = "SUPER";

      exec-once = [
        "wl-paste --watch cliphist store"
      ];

      bind = [
        # Apps
        "$mod, Return, exec, $terminal"
        "$mod, B, exec, $browser"
        "$mod, E, exec, $terminal -e $explorer"
        "$mod, D, exec, fuzzel"
        "$mod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

        # Window management
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
        "$mod, M, exit"


        # Focus movement (vim-style)
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Move windows
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # Workspace cycling
        "$mod, Tab, workspace, e+1"
        "$mod SHIFT, Tab, workspace, e-1"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
      ];

      binde = [
        "$mod ALT, H, resizeactive, -20 0"
        "$mod ALT, L, resizeactive, 20 0"
        "$mod ALT, K, resizeactive, 0 -20"
        "$mod ALT, J, resizeactive, 0 20"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1.0";
        animation = [
          "windows, 1, 3, ease, popin 85%"
          "fade, 1, 4, ease"
          "workspaces, 1, 4, ease, slide"
        ];
      };
    };
  };
}
