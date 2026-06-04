{ ... }:

# onyx — machine-specific monitor layout.
# Connectors: DP-3 = ASUS VG27A (primary, left)  |  HDMI-A-1 = LG FULL HD (right)
# Workspaces: 1-3 on DP-3 (primary), 4-5 on HDMI-A-1 (secondary)
{
  # Hyprland monitor placement — tells Hyprland where each output goes on hot-plug,
  # before kanshi has a chance to apply its profile. Without these, Hyprland
  # auto-places new monitors (often at 0,0), causing a brief overlap warning.
  # Format: "name,WxH@Hz,XxY,scale"
  wayland.windowManager.hyprland.settings.monitor = [
    "DP-3,2560x1440@165,0x0,1"
    "HDMI-A-1,1920x1080@60,2560x0,1"
  ];

  # Hyprland workspace-to-monitor pinning
  wayland.windowManager.hyprland.settings.workspace = [
    "1, monitor:DP-3,     persistent:true"
    "2, monitor:DP-3,     persistent:true"
    "3, monitor:DP-3,     persistent:true"
    "4, monitor:HDMI-A-1, persistent:true"
    "5, monitor:HDMI-A-1, persistent:true"
  ];

  # kanshi monitor profiles — matches by model+serial, not port
  # Add a new profile here whenever you gain/lose a monitor on this machine
  services.kanshi.settings = [
    # Two monitors: ASUS VG27A (left, primary) + LG FULL HD (right)
    {
      profile.name = "dual-monitors";
      profile.outputs = [
        {
          criteria = "ASUSTek COMPUTER INC VG27A M3LMQS348204";
          position = "0,0";
          mode = "2560x1440@165";
        }
        {
          criteria = "LG Electronics LG FULL HD 0x01010101";
          position = "2560,0";
          mode = "1920x1080@60";
        }
      ];
    }

    # Single monitor fallbacks (e.g. if one is unplugged)
    {
      profile.name = "asus-only";
      profile.outputs = [
        {
          criteria = "ASUSTek COMPUTER INC VG27A M3LMQS348204";
          position = "0,0";
          mode = "2560x1440@165";
        }
      ];
    }

    {
      profile.name = "lg-only";
      profile.outputs = [
        {
          criteria = "LG Electronics LG FULL HD 0x01010101";
          position = "0,0";
          mode = "1920x1080@60";
        }
      ];
    }
  ];
}
