{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos-vm";

  # Networking - NetworkManager handles wifi/ethernet
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ] ;

  # Timezone and locale
  time.timeZone = "Asia/Jerusalem";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.eyal = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    home-manager
  ];

  # Hyperland setup
  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Enable SSH so we can log in from the host later
  services.openssh.enable = true;

  # This value determines the NixOS compatibility version.
  # Never change this after the initial install.
  system.stateVersion = "24.11";
}
