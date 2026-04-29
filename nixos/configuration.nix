{ config, lib, pkgs, stylixShared, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "onyx";

  # Networking - NetworkManager handles wifi/ethernet
  networking.networkmanager.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ] ;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBs="
    ];
  };

  # Timezone and locale
  time.timeZone = "Asia/Jerusalem";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.eyal = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
    shell = pkgs.zsh;
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    tree
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

  # Zsh setup
  programs.zsh.enable = true;

  # Enable SSH so we can log in from the host later
  services.openssh.enable = true;

  # GitHub host key — prevents the "unknown host" prompt
  programs.ssh.knownHosts."github.com" = {
    hostNames = [ "github.com" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  # Stylix — system-level theming (greeter, fonts, cursor)
  stylix = {
    enable = true;
    inherit (stylixShared) base16Scheme image;
  };

  # WiFi — RTL88x2bu USB adapter (USB ID 0bda:b812, e.g. AC1200 Techkey)
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl88x2bu ];

  # nvidia

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ] ;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };


  # This value determines the NixOS compatibility version.
  # Never change this after the initial install.
  system.stateVersion = "25.11";

}
