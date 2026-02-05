return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  settings = {
    ['rust-analyzer'] = {
      lens = {
        enable = true,
        run = { enable = true },
        debug = { enable = true },
      },
    },
  },
}
