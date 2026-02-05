return {
  "conform.nvim",
  ft = { "nix", "c", "ocaml", "ocamlinterface", "menhir", "ocamllex", "rust" },
  after = function()
    require("conform").setup({
      formatters_by_ft = {
        nix = { "alejandra" },
        c = { "clang-format" },
        ocaml = { "ocamlformat" },
        ocamlinterface = { "ocamlformat" },
        menhir = { "ocamlformat" },
        ocamllex = { "ocamlformat" },
        rust = { "rustfmt", lsp_format = "fallback" },
      },

      formatters = {
        alejandra = {
          args = { "--quiet" },
        },
        ocamlformat = {
          args = { "--name", "$FILENAME", "-" },
        },
        ["clang-format"] = {
          prepend_args = { "--style={IndentWidth: 4}" },
        },
        rustfmt = {
          args = { '--edition', '2024' },
        },
      },

      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    })
  end,
}
