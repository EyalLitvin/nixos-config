{ ... }:

# onyx — desktop workstation (x86_64, nvidia GPU, RTL88x2bu WiFi adapter)
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "onyx";

  systemSettings.hardware.nvidia.enable = true;
  systemSettings.hardware.audio.enable  = true;
}
