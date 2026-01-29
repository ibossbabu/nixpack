{
  description = "Home Manager configuration for sak";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: let
    mkHome = system: {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [./home.nix];
    };
  in {
    homeConfigurations = {
      "sak@gentoo" = home-manager.lib.homeManagerConfiguration (mkHome "x86_64-linux");
      #"sak@sak-book" = home-manager.lib.homeManagerConfiguration (mkHome "aarch64-darwin");
    };
  };
}
