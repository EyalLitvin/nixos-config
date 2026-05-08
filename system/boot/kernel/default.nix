{ config, ... }:

{
  # Extra out-of-tree kernel modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl88x2bu
  ];
}
