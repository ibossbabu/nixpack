---@brief
---
--- https://github.com/ocaml/ocaml-lsp
---
--- `ocaml-lsp` can be installed as described in [installation guide](https://github.com/ocaml/ocaml-lsp#installation).
---
--- To install the lsp server in a particular opam switch:
--- ```sh
--- opam install ocaml-lsp-server
--- ```

-- https://github.com/ocaml/ocaml-lsp/blob/master/ocaml-lsp-server/docs/ocamllsp/switchImplIntf-spec.md
local function switch_impl_intf(bufnr, client)
  local method_name = 'ocamllsp/switchImplIntf'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
  end
  local uri = vim.lsp.util.make_given_range_params(nil, nil, bufnr, client.offset_encoding).textDocument.uri
  if not uri then
    return vim.notify('could not get URI for current buffer')
  end
  local params = { uri }
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result or #result == 0 then
      vim.notify('corresponding file cannot be determined')
    elseif #result == 1 then
      vim.cmd.edit(vim.uri_to_fname(result[1]))
    else
      vim.ui.select(
        result,
        { prompt = 'Select an implementation/interface:', format_item = vim.uri_to_fname },
        function(choice)
          if choice then
            vim.cmd.edit(vim.uri_to_fname(choice))
          end
        end
      )
    end
  end, bufnr)
end
return {
  cmd = { 'ocamllsp' },
  filetypes = { 'ocaml' },
  root_markers = { 'dune-project', 'dune-workspace', '*.opam', 'opam', '.git' },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'LspOcamllspSwitchImplIntf', function()
      switch_impl_intf(bufnr, client)
    end, { desc = 'Switch between implementation/interface' })
  end,
}
