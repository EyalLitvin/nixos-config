{ config, lib, pkgs, ... }:

{
  options.userSettings.apps.printing3d.enable = lib.mkEnableOption "3D printing tools (OrcaSlicer)";

  config = lib.mkIf config.userSettings.apps.printing3d.enable {
    home.packages = [ pkgs.orca-slicer ];
  };
}
