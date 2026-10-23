{ config, lib, pkgs, ... }:

{
  options.userSettings.apps.printing3d.enable = lib.mkEnableOption "3D printing tools (SolveSpace, OrcaSlicer)";

  config = lib.mkIf config.userSettings.apps.printing3d.enable {
    home.packages = with pkgs; [
      solvespace # parametric CAD - model the part
      orca-slicer # slicer - turn the STL into gcode
    ];
  };
}
