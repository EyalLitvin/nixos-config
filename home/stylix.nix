{ pkgs, lib, stylixShared, ... }:

{
  stylix = {
    enable = true;
    inherit (stylixShared) base16Scheme image;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes.terminal = 13;
    };
    opacity.terminal = 0.75;
    # Wallpaper is managed by awww, not hyprpaper
    targets.hyprpaper.enable = lib.mkForce false;
  };

  home.packages = [ pkgs.awww ];

  # awww daemon — persistent, tied to the graphical session
  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "awww wallpaper daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Oneshot service: pick a random wallpaper and apply it
  systemd.user.services.wallpaper-randomizer = {
    Unit = {
      Description = "Set random wallpaper";
      After = [ "awww-daemon.service" ];
      Requires = [ "awww-daemon.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "set-wallpaper" ''
        ${pkgs.awww}/bin/awww img \
          "$(${pkgs.findutils}/bin/find "$HOME/.dotfiles/wallpapers" -type f | ${pkgs.coreutils}/bin/shuf -n1)" \
          --transition-type grow --transition-pos center --transition-duration 2
      ''}";
    };
  };

  # Timer: trigger wallpaper rotation at every round hour
  systemd.user.timers.wallpaper-randomizer = {
    Unit.Description = "Rotate wallpaper every hour";
    Timer = {
      OnCalendar = "hourly";
      OnActiveSec = "0";  # also run immediately when timer activates
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
