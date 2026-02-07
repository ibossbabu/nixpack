_G.start_time = vim.uv.hrtime()
vim.loader.enable()
require("options")
require("keymaps")
require("quickswap")
require("lsp")

require("lze").load {
  { "nvim-surround",
    after = function()
      require("nvim-surround").setup()
    end,
  },
  { "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup()
    end,
  },
  { import = "plugins/snack" },
  { import = "plugins/conform" },
  { import = "plugins/completion" },
  { import = "plugins/oil" },
  { import = "plugins/mell" },
  {
    "custom-linters",
    ft = { "typescript", "typescriptreact", "c", "cpp", "rust", "haskell" },
    after = function()
      require("linters.lint").setup_all()
    end,
  },
}
--vim.lsp.enable({ "lua-ls", "nixd" })
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local end_time = vim.uv.hrtime()
    local startup_time = (end_time - _G.start_time) / 1000000
    vim.defer_fn(function()
      print(string.format("⚡ vim loaded in ~%.2fms", startup_time))
    end, 10)
  end,
})
-- Transparent background
vim.cmd [[hi Normal guibg=NONE]]
vim.cmd [[hi NormalNC guibg=NONE]]
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#1a1a1a' })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#808080', bold = false })

vim.api.nvim_set_hl(0, 'LineNr', { fg = '#606060' })
vim.api.nvim_set_hl(0, 'CursorLineSign', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Visual', { bg = '#2a2a2a', fg = 'NONE' })
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE', fg = '#abb2bf' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#0a0a0a' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#0a0a0a', fg = '#6c7891' })
vim.g.loaded_matchparen = 1
