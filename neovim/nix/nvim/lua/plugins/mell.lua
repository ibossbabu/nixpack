--vim.cmd.packadd 'catppuccin-nvim'
vim.cmd.packadd 'base16-nvim'

vim.cmd.colorscheme('base16-atelier-cave')

-- setup custom colors
require('base16-colorscheme').setup({
  base00 = '#1a1618',
  base01 = '#2a2427',
  base02 = '#554d52',
  base03 = '#645c61',
  base04 = '#7a7176',
  base05 = '#8f8589',
  base06 = '#c9c3be',
  base07 = '#dbd6d1',
  base08 = '#c4657d',
  base09 = '#bd7c59',
  base0A = '#bd8f5e',
  base0B = '#5c9f87',
  base0C = '#6499ba',
  base0D = '#7683d9',
  base0E = '#a278d9',
  base0F = '#c166c1'
})

return {
  {
    "base16-nvim",
    --  "catppuccin-nvim",
    --  colorscheme = "catppuccin",
  },
}
