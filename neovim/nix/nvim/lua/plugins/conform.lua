return {
  "conform.nvim",
  ft = { "nix", "c", "rust", },
  after = function()
    require("conform").setup({
      formatters_by_ft = {
        nix = { "alejandra" },
        c = { "clang-format", lsp_format = "fallback" },
        rust = { "rustfmt", lsp_format = "fallback" },
      },

      formatters = {
        alejandra = {
          args = { "--quiet" },
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
