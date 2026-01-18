{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ytsurf.url = "github:Stan-breaks/ytsurf";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    ytsurf,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ytsurf.overlays.default];
        };
      in {
        packages.default = pkgs.ytsurf;

        apps.default = {
          type = "app";
          program = "${pkgs.ytsurf}/bin/ytsurf";
        };
      }
    );
}
