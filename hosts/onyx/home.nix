{ ... }:

# onyx — home-manager profile for eyal
{
  userSettings.desktop.kanshi.enable = true;

  # Machine-specific monitor layout — kanshi matches by model+serial, not port.
  # Add a new profile here whenever you gain/lose a monitor on this machine.
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
