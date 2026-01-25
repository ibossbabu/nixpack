return function()
  local tidy_ns = vim.api.nvim_create_namespace("manual_clang_tidy")

  local function run_clang_tidy()
    local bufnr = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufnr)

    vim.diagnostic.reset(tidy_ns, bufnr)

    local cmd = string.format(
      "clang-tidy --quiet --checks=-clang-diagnostic-format-security,... %s --",
      vim.fn.shellescape(fname)
    )

    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if not data then return end
        local diags = {}

        for _, line in ipairs(data) do
          local l, c, sev, msg = line:match(":(%d+):(%d+):%s+(%w+):%s+(.*)")

          if l then
            local severity_map = {
              error = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
              note = vim.diagnostic.severity.INFO,
              remark = vim.diagnostic.severity.HINT,
            }

            table.insert(diags, {
              lnum = tonumber(l) - 1,
              col = tonumber(c) - 1,
              severity = severity_map[sev:lower()] or vim.diagnostic.severity.INFO,
              -- use INFO as a fallback to prevent keywords that isn't in severity_map
              message = msg,
              source = "clang-tidy",
            })
          end
        end
        vim.diagnostic.set(tidy_ns, bufnr, diags)
      end,
    })
  end

  --linting on save and buffer enter
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
    callback = run_clang_tidy,
  })
end
