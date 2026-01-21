return {
  cmd = { "typescript-language-server", "--stdio" },
  root_markers = { "tsconfig.json", "package.json", "bun.lock" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  --on_attach = function(_, bufnr)
  --  -- Disable diagnostics for this buffer from this client
  --  vim.diagnostic.enable(false, { bufnr = bufnr })
  --end
}
