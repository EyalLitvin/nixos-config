{ config, lib, ... }:

let cfg = config.userSettings.desktop.kanshi;
in {
  options.userSettings.desktop.kanshi.enable =
    lib.mkEnableOption "kanshi multi-monitor manager";

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      # Hyprland registers its own systemd target; kanshi must start after it
      systemdTarget = "hyprland-session.target";
    };
  };
}
