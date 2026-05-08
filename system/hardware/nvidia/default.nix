{ config, lib, pkgs, ... }:

{
  options.systemSettings.hardware.nvidia.enable = lib.mkEnableOption "nvidia GPU";

  config = lib.mkIf config.systemSettings.hardware.nvidia.enable {
    nixpkgs.config.allowUnfree = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
