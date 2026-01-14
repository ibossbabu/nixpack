--vim.cmd.packadd 'catppuccin-nvim'
--vim.cmd.packadd 'mellow-theme'
vim.cmd.packadd 'base16-nvim'
return {
  {
    "base16-nvim",
    colorscheme = "base16-atelier-cave",
    --  "catppuccin-nvim",
    --  colorscheme = "catppuccin",
  },
  vim.cmd.colorscheme('base16-atelier-cave')
}
