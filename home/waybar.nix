{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;  # waybar started and managed by systemd user session
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%Y-%m-%d}";
          tooltip = false;
        };

        tray = {
          spacing = 8;
        };
      };
    };
  };
}
