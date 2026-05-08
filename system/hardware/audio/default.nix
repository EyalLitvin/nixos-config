{ lib, config, ... }:

{
  options.systemSettings.hardware.audio.enable = lib.mkEnableOption "PipeWire audio";

  config = lib.mkIf config.systemSettings.hardware.audio.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
