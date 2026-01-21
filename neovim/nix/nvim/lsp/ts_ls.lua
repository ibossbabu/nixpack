return {
  cmd = { "typescript-language-server", "--stdio" },
  root_markers = { "tsconfig.json", "package.json", "bun.lock" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  handlers = {
    ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
      local filtered_diagnostics = {}
      for _, diagnostic in ipairs(result.diagnostics) do
        -- 6133 is "unused variable", 6196 is "unused declaration"
        if diagnostic.code ~= 6133 and diagnostic.code ~= 6196 then
          table.insert(filtered_diagnostics, diagnostic)
        end
      end
      result.diagnostics = filtered_diagnostics
      vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
    end,
  },
}
