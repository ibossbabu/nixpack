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
        "nixpkgs#bitwarden-cli"
        "nixpkgs#btop"
        "nixpkgs#direnv"
        "nixpkgs#fastfetch"
        "nixpkgs#fd"
        "nixpkgs#feh"
        "nixpkgs#firefox"
        "nixpkgs#fzf"
        "nixpkgs#gitu"
        "nixpkgs#lemonbar"
        "nixpkgs#noto-fonts"
        "nixpkgs#noto-fonts-cjk-sans"
        "nixpkgs#noto-fonts-color-emoji"
        "nixpkgs#pavucontrol"
        "nixpkgs#ripgrep"
        "nixpkgs#rofi"
        "nixpkgs#tree"
        "nixpkgs#unzip"
        "nixpkgs#xclip"
        "nixpkgs#xfce4-screenshooter"
        "nixpkgs#zoxide"
      ];
      targets = [
        "$HOME/nixpack/neovim"
        "$HOME/nixpack/tmux"
      ];
      install = pkgs.writeShellScript "install-nix-flakes" ''
        #!/usr/bin/env bash
        TARGETS=(${builtins.concatStringsSep " " targets})
        for TARGET in "''${TARGETS[@]}"; do
          eval TARGET_EXPANDED="$TARGET"
          [ -d "$TARGET_EXPANDED" ] && nix profile add "path:$TARGET_EXPANDED"
        done
        ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
          LINUX_PKGS=(${builtins.concatStringsSep " " linuxPkgs})
          for PKG in "''${LINUX_PKGS[@]}"; do
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
