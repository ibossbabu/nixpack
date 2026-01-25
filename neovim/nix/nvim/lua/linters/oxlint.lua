return function()
  local ox_ns = vim.api.nvim_create_namespace("manual_oxlint")

  local function run_oxlint()
    local bufnr = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufnr)

    vim.diagnostic.reset(ox_ns, bufnr)

    local cmd = string.format("bunx oxlint --format github --type-aware %s",
      vim.fn.shellescape(fname))

    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if not data then return end
        local diags = {}
        for _, line in ipairs(data) do
          local sev, l, c, msg =
              line:match("::([^ ]+) file=.*,line=(%d+),.-,col=(%d+),.-::(.*)")
          if l then
            table.insert(diags, {
              lnum = tonumber(l) - 1,
              col = tonumber(c) - 1,
              severity = sev == "error" and 1 or 2,
              message = msg,
              source = "oxlint",
            })
          end
        end
        vim.diagnostic.set(ox_ns, bufnr, diags)
      end,
    })
  end

  --linting on save and buffer enter
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = { "*.ts", "*.tsx" },
    callback = run_oxlint,
  })
end
