{
  description = "Eyal's NixOS flake";

  inputs = {
    nixpkgs.url      = "nixpkgs/nixos-unstable";
    flake-parts.url  = "github:hercules-ci/flake-parts";
    home-manager     = { url = "github:nix-community/home-manager";  inputs.nixpkgs.follows = "nixpkgs"; };
    nixvim           = { url = "github:nix-community/nixvim";        inputs.nixpkgs.follows = "nixpkgs"; };
    stylix           = { url = "github:danth/stylix";                inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix         = { url = "github:Mic92/sops-nix";             inputs.nixpkgs.follows = "nixpkgs"; };
    prolix           = { url = "github:EyalLitvin/prolix";           inputs.nixpkgs.follows = "nixpkgs"; inputs.home-manager.follows = "home-manager"; inputs.flake-parts.follows = "flake-parts"; };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    imports = [
      ./flake-modules/hosts.nix
      inputs.prolix.flakeModules.default
    ];
    perSystem = { pkgs, ... }: {
      imports = [ ./home/dev/repos/default.nix ];
    };
  };
}
