{
  description = "Eyal's NixOS flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, stylix, sops-nix }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    stylixShared = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      image = ./wallpapers/a_bird_on_a_branch.png;
    };
  in
  {
    nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit stylixShared; };
      modules = [
        ./nixos/configuration.nix
        stylix.nixosModules.stylix
      ];
    };

    homeConfigurations.eyal = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit stylixShared; };
      modules = [
        nixvim.homeModules.nixvim
        stylix.homeModules.stylix
        sops-nix.homeManagerModules.sops
        ./home/home.nix
      ];
    };
  };
}
