{ config, lib, pkgs, ... }:

{
  options.systemSettings.hardware.bluetooth.enable =
    lib.mkEnableOption "Bluetooth";

  config = lib.mkIf config.systemSettings.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
