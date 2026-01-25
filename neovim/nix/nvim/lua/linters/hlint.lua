return function()
  local hlint_ns = vim.api.nvim_create_namespace("manual_hlint")

  local function run_hlint()
    local bufnr = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufnr)

    vim.diagnostic.reset(hlint_ns, bufnr)

    -- --json: outputs machine readable format
    -- --no-exit-code: prevents hlint from returning error exit codes on hints
    local cmd = string.format("hlint --json --no-exit-code %s", vim.fn.shellescape(fname))

    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if not data or #data == 0 or (#data == 1 and data[1] == "") then return end

        -- Join the lines into a single string for JSON decoding
        local stdout_str = table.concat(data, "\n")
        local ok, decoded = pcall(vim.json.decode, stdout_str)
        if not ok or not decoded then return end

        local diags = {}
        local severity_map = {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
          suggestion = vim.diagnostic.severity.INFO,
        }

        for _, d in ipairs(decoded) do
          -- hlint provides startLine and startColumn
          -- Neovim uses 0-indexed coordinates
          table.insert(diags, {
            lnum = (d.startLine > 0) and (d.startLine - 1) or 0,
            col = (d.startColumn > 0) and (d.startColumn - 1) or 0,
            end_lnum = (d.endLine > 0) and (d.endLine - 1) or nil,
            end_col = (d.endColumn > 0) and (d.endColumn - 1) or nil,
            severity = severity_map[d.severity:lower()] or vim.diagnostic.severity.WARN,
            message = d.hint .. (d.to and (" -> " .. d.to) or ""),
            source = "hlint",
          })
        end

        vim.diagnostic.set(hlint_ns, bufnr, diags)
      end,
    })
  end

  --linting on save and buffer enter
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = { "*.hs", "*.lhs" },
    callback = run_hlint,
  })
end
