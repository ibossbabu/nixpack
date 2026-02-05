local function is_library(fname)
  local user_home = vim.env.HOME
  local cargo_home = os.getenv('CARGO_HOME') or user_home .. '/.cargo'
  local rustup_home = os.getenv('RUSTUP_HOME') or user_home .. '/.rustup'

  for _, item in ipairs({
    rustup_home .. '/toolchains',
    cargo_home .. '/registry/src',
    cargo_home .. '/git/checkouts'
  }) do
    if vim.startswith(fname, item) then
      local clients = vim.lsp.get_clients({ name = 'rust_analyzer' })
      return #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  root_dir = function(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    return is_library(fname) or vim.fs.root(fname, { 'Cargo.toml', 'rust-project.json' })
  end,
  settings = {
    ['rust-analyzer'] = {
      lens = { enable = true, run = { enable = true }, debug = { enable = true } },
    },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'LspCargoReload', function()
      client:request('rust-analyzer/reloadWorkspace', nil, function(err)
        vim.notify(err and tostring(err) or 'Cargo workspace reloaded')
      end)
    end, { desc = 'Reload cargo workspace' })
  end,
}
