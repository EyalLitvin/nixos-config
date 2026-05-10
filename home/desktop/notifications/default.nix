{ pkgs, ... }:

{
  home.packages = [ pkgs.libnotify ];

  services.swaync = {
    enable = true;

    settings = {
      notification-window-width = 0;

      # Allowlist: first match wins. allow-scripts before block-all.
      notification-visibility = {
        allow-scripts = {
          app-name = "^waybar-notify$";
          state = "muted";
        };
        block-all = {
          state = "ignored";
        };
      };

      widgets = [];
    };
  };
}
