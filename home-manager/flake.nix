{
  description = "Home Manager configuration for sak";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim.url = "path:/home/sak/nixpack/neovim";
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
  } @ inputs: let
    mkHome = system: {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {inherit inputs system;};
      modules = [./home.nix];
    };
  in {
    homeConfigurations = {
      "sak@gentoomachine" = home-manager.lib.homeManagerConfiguration (mkHome "x86_64-linux");
    };
  };
}
