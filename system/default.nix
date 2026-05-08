{ ... }:

{
  imports = [
    ./boot
    ./hardware
    ./networking
    ./display
    ./security
    ./nix
    ./locale
  ];

  # Basic system packages available on all machines
  environment.systemPackages = [
    # Prefer putting packages in home-manager or module-specific files.
    # Only add here if truly system-wide and not covered by a module.
  ];

  system.stateVersion = "25.11";
}
