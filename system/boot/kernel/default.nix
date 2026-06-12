{ config, ... }:

{
  # Extra out-of-tree kernel modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl88x2bu
  ];

  # Disable USB autosuspend — prevents the USB WiFi adapter from going DORMANT
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # Disable rtl88x2bu driver power management and USB selective suspend
  boot.extraModprobeConfig = ''
    options 88x2bu rtw_power_mgnt=0 rtw_enusbss=0
  '';
}
