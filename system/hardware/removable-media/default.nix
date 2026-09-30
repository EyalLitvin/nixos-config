{ config, lib, ... }:

{
  options.systemSettings.hardware.removableMedia.enable =
    lib.mkEnableOption "on-demand mounting of USB drives and SD cards via udisks2";

  config = lib.mkIf config.systemSettings.hardware.removableMedia.enable {
    services.udisks2.enable = true;
  };
}
