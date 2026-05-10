{ pkgs, ... }:

let
  notifWatcher = pkgs.writers.writePython3Bin "waybar-notification" {
  } (builtins.readFile ./waybar-notification.py);

  openHistory = pkgs.writeShellScriptBin "open-notification-history" ''
    history_file="$HOME/.local/state/waybar-notifications.json"
    [ -f "$history_file" ] || exit 0
    selected=$(${pkgs.jq}/bin/jq -r \
      '.[] | if .body != "" then "\(.summary)  —  \(.body)" else .summary end' \
      "$history_file" | ${pkgs.fuzzel}/bin/fuzzel --dmenu)
    [ -n "$selected" ] && printf '%s' "$selected" | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in
{
  home.packages = [ openHistory ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        modules-left   = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right  = [ "custom/sep" "custom/notification" "tray" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%Y-%m-%d}";
          tooltip = false;
        };

        tray.spacing = 8;

        "custom/sep" = {
          format = "||";
          interval = "once";
          tooltip = false;
        };

        "custom/notification" = {
          exec = "${notifWatcher}/bin/waybar-notification";
          return-type = "json";
          on-click = "${openHistory}/bin/open-notification-history";
          escape = true;
          restart-interval = 5;
        };
      };
    };

    style = builtins.readFile ./style.css;
  };
}
