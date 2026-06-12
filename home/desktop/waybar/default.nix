{ pkgs, config, lib, ... }:

let
  cfg = config.userSettings.desktop.waybar;

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
  options.userSettings.desktop.waybar.battery.enable =
    lib.mkEnableOption "battery status widget in waybar";

  config.home.packages = [ openHistory pkgs.networkmanager_dmenu ];

  config.xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = ${pkgs.fuzzel}/bin/fuzzel --dmenu

    [editor]
    terminal = ${pkgs.kitty}/bin/kitty
  '';

  config.programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;

        modules-left   = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right  =
          [ "cpu" "memory" "disk" "wireplumber" "network" ]
          ++ lib.optional cfg.battery.enable "battery"
          ++ [ "custom/notification" "tray" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        clock = {
          format = "{:%H:%M  %a %d %b}";
          tooltip = false;
        };

        cpu = {
          format = "󰘚 {usage}%";
          interval = 2;
          tooltip = false;
        };

        memory = {
          format = "󰍛 {used}G";
          tooltip-format = "{used}G / {total}G";
        };

        disk = {
          format = "󰋊 {percentage_used}%";
          tooltip-format = "{used} used / {total} total";
        };

        wireplumber = {
          format = " {volume}%";
          format-muted = " mute";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip = false;
        };

        network = {
          format-wifi        = "{icon}  {essid}";
          format-ethernet    = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  offline";
          format-icons       = { wifi = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"]; };
          tooltip-format     = "{ifname}: {ipaddr}\nSignal: {signalStrength}%";
          on-click           = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
        };

        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
          on-click = "blueman-manager";
          tooltip-format = "{num_connected} connected\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
        };

        battery = lib.mkIf cfg.battery.enable {
          format = "{icon} {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
          tooltip-format = "{timeTo}, {capacity}%";
        };

        tray = {
          spacing = 8;
          icon-size = 16;
        };

        "custom/notification" = {
          exec = "${notifWatcher}/bin/waybar-notification";
          return-type = "json";
          format = "  {}";
          on-click = "${openHistory}/bin/open-notification-history";
          escape = true;
          restart-interval = 5;
        };
      };
    };

    style = builtins.readFile ./style.css;
  };
}
