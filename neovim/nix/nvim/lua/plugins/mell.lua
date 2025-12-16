--vim.cmd.packadd 'catppuccin-nvim'
vim.cmd.packadd 'mellow-theme'
return {
  {
    "mellow-theme",
    colorscheme = "mellow",
--  "catppuccin-nvim",
--  colorscheme = "catppuccin",
  },
  vim.cmd.colorscheme('mellow')
}
