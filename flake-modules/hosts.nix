{ inputs, lib, ... }:

let
  system = "x86_64-linux";

  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  stylixShared = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = ../assets/wallpapers/a_bird_on_a_branch.png;
  };

  hosts = builtins.attrNames (builtins.readDir ../hosts);
in
{
  flake.nixosConfigurations = builtins.listToAttrs (map (host: {
    name  = host;
    value = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit stylixShared; };
      modules = [
        ../hosts/${host}/configuration.nix
        ../system
        inputs.stylix.nixosModules.stylix
      ];
    };
  }) hosts);

  flake.homeConfigurations = builtins.listToAttrs (map (host: {
    name  = "eyal@${host}";
    value = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit stylixShared; };
      modules = [
        ../hosts/${host}/home.nix
        ../home
        inputs.nixvim.homeModules.nixvim
        inputs.stylix.homeModules.stylix
        inputs.sops-nix.homeManagerModules.sops
        inputs.prolix.homeManagerModules.default
      ];
    };
  }) hosts);
}
