--vim.cmd.packadd 'catppuccin-nvim'
vim.cmd.packadd 'base16-nvim'

vim.cmd.colorscheme('base16-circus')

-- setup custom colors
--[[ require('base16-colorscheme').setup({
  base00 = '#19141f',
  base01 = '#241d2c',
  base02 = '#3d3247',
  base03 = '#4d405a',
  base04 = '#6f5f82',
  base05 = '#8c7ba0',
  base06 = '#b9a9cc',
  base07 = '#ddd2e8',
  base08 = '#d9a441',
  base09 = '#9b6bc4',
  base0A = '#e0b563',
  base0B = '#7e58a8',
  base0C = '#c99a3e',
  base0D = '#a87ed4',
  base0E = '#f0c874',
  base0F = '#6b4a91',
}) ]]

return {
  {
    "base16-nvim",
    --  "catppuccin-nvim",
    --  colorscheme = "catppuccin",
  },
}
