return {
  "nvim-lint",
  after = function()
    require('lint').linters_by_ft = {
      c = { 'clangtidy' },
      rust = { 'clippy' },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
