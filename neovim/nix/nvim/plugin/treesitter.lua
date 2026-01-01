--vim.cmd.packadd 'nvim-treesitter'
--vim.opt.runtimepath:prepend(vim.fn.expand("~/.local/share/nvim/treesitter"))
vim.opt.runtimepath:remove(vim.fn.expand("~/.local/share/nvim/site"))
vim.defer_fn(function()
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      pcall(vim.treesitter.start, args.buf)
    end,
  })
end, 1)
