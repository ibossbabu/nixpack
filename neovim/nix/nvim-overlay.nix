{inputs}: final: {
  system,
  pkgs ? final,
  lib,
  callPackage,
  vimPlugins,
  vimUtils,
  ...
}: let
  buildVimPlugin = src: pname:
    vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate or "dev";
    };
  mkNeovim = callPackage ./mkNeovim.nix {};

  plugins = let
    start = x: {
      plugin = x;
      optional = false;
    };
    opt = x: {
      plugin = x;
      optional = true;
    };
    treesitter =
      vimPlugins.nvim-treesitter.withPlugins
      (p: [
        p.bash
        p.nix
        p.haskell
        p.make
        p.ocaml
        p.ocaml_interface
        p.ocamllex
        p.typescript
        p.rust
      ]);
    #haskell-indent = buildVimPlugin inputs.haskell-indent "haskell-indent";
  in
    with vimPlugins; [
      # It's technically possible to provide lua configuration for
      # plugins here, in nix, but in this template we prefer to config plugins in
      # the actual lua files inside the nvim config directory.
      # There are two good reasons for this decision:
      #   1. You've got an lsp assistance
      #   2. It's possisble to apply configuration just by restarting nvim,
      #      that is without rebuilding

      # lazy-load plugins https://github.com/BirdeeHub/lze
      #(start lze)
      lze
      (start snacks-nvim)
      (opt blink-cmp)
      (opt luasnip)
      (opt nvim-surround)
      (opt nvim-autopairs)
      #(opt fzf-lua)
      (opt oil-nvim)
      #(opt catppuccin-nvim)
      #(opt mellow-nvim)
      #(start haskell-indent)
      (opt base16-nvim)
      (opt vim-tmux-navigator)
      #(opt guard-nvim)
      (opt conform-nvim)
      treesitter
      #nvim-treesitter-textobjects
    ];

  extraPackages = with pkgs; [
    lua-language-server
    nil
    alejandra
  ];
in {
  myNeovim = mkNeovim {
    inherit plugins extraPackages;
  };
}
