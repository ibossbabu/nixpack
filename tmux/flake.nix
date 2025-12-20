{
  description = "tmux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        tmuxModule = import ./tmux.nix {
          inherit inputs pkgs;
        };
      in {
        packages = {
          default = tmuxModule.package;
          tmux = tmuxModule.package;
        };
        apps = {
          tmux = tmuxModule;
        };
      }
    );
}
