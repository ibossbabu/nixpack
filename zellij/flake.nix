{
  description = "Zellij terminal multiplexer with zjstatus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zjstatus.url = "github:dj95/zjstatus";
    room.url = "github:rvcas/room";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    zjstatus,
    room,
    ...
  } @ inputs: let
    inherit (nixpkgs.lib) attrValues;
    overlays = with inputs; [
      (final: prev: {
        zjstatus = zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
        room = room.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      })
    ];
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = overlays;
        };
        zellij = pkgs.writeShellApplication {
          name = "zellij";
          runtimeInputs = [pkgs.zellij pkgs.zjstatus pkgs.room];
          text = ''
            export ZJSTATUS_PLUGIN_PATH="${pkgs.zjstatus}"
            export ROOM_PLUGIN_PATH="${pkgs.room}/lib/zellij/plugins/room.wasm"
            exec zellij --config-dir ${./.} --config ${./config.kdl} --layout ${./layout_file.kdl} "$@"
          '';
        };
      in {
        packages = {
          default = zellij;
        };

        apps.default = {
          type = "app";
          program = "${zellij}/bin/zellij";
        };
      }
    );
}
