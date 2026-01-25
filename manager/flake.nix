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
      linuxPkgs = [
      ];
      darwinPkgs = [
      ];
      commonPkgs = [
       # "nixpkgs#home-manager"
      ];
      targets = [
        "$HOME/nixpack/neovim"
       "$HOME/nixpack/zellij"
        "$HOME/nixpack/home-manager/"
      ];
      install = pkgs.writeShellScript "install-nix-flakes" ''
        #!/usr/bin/env bash
        TARGETS=(${builtins.concatStringsSep " " targets})
        for TARGET in "''${TARGETS[@]}"; do
          eval TARGET_EXPANDED="$TARGET"
          [ -d "$TARGET_EXPANDED" ] && nix profile add "path:$TARGET_EXPANDED"
        done
          #Common
        COMMON_PKGS=(${builtins.concatStringsSep " " commonPkgs})
        for PKG in "''${COMMON_PKGS[@]}"; do
          nix profile add "$PKG"
        done
          #Linux
        ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
          LINUX_PKGS=(${builtins.concatStringsSep " " linuxPkgs})
          for PKG in "''${LINUX_PKGS[@]}"; do
            nix profile add "$PKG"
          done
        ''}
          #Mac
        ${pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
          DARWIN_PKGS=(${builtins.concatStringsSep " " darwinPkgs})
          for PKG in "''${DARWIN_PKGS[@]}"; do
            nix profile add "$PKG"
          done
        ''}
      '';
      update = pkgs.writeShellScript "update-nix-flakes" ''
        #!/usr/bin/env bash
        TARGETS=(${builtins.concatStringsSep " " targets})
        for TARGET in "''${TARGETS[@]}"; do
          eval TARGET_EXPANDED="$TARGET"
          [ -d "$TARGET_EXPANDED" ] && (cd "$TARGET_EXPANDED" && nix flake update)
        done
        #nix profile upgrade --all
      '';
    in {
      packages = {
        install = install;
        update = update;
        default = update;
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
