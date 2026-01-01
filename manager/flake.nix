{
  description = "installation-flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      targets =
        [
          "$HOME/nixpack/neovim"
          "$HOME/nixpack/tmux"
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          ## For linux
        ];
      install = pkgs.writeShellScript "install-nix-flakes" ''
        #!/usr/bin/env bash
        TARGETS=(${builtins.concatStringsSep " " targets})

        for TARGET in "''${TARGETS[@]}"; do
          eval TARGET_EXPANDED="$TARGET"
          [ -d "$TARGET_EXPANDED" ] && nix profile add "path:$TARGET_EXPANDED"
        done
      '';

      update = pkgs.writeShellScript "update-nix-flakes" ''
        #!/usr/bin/env bash
        TARGETS=(${builtins.concatStringsSep " " targets})

        for TARGET in "''${TARGETS[@]}"; do
          eval TARGET_EXPANDED="$TARGET"
          [ -d "$TARGET_EXPANDED" ] && (cd "$TARGET_EXPANDED" && nix flake update)
        done

        nix profile upgrade --all
      '';
    in {
      packages = {
        install = install;
        update = update;
        default = install;
      };
      apps = {
        install = {
          type = "app";
          program = "${install}";
        };
        update = {
          type = "app";
          program = "${update}";
        };
      };
    });
}
