{ ... }:

# onyx — home-manager profile for eyal
{
  imports = [ ./monitors.nix ];

  userSettings.desktop.kanshi.enable = true;
  userSettings.apps.printing3d.enable = true;
}
