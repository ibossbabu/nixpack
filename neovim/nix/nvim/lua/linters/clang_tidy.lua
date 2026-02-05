return function()
  local tidy_ns = vim.api.nvim_create_namespace("manual_clang_tidy")

  local function run_clang_tidy()
    local bufnr = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufnr)
    vim.diagnostic.reset(tidy_ns, bufnr)

    local cmd = string.format(
      "clang-tidy %s --quiet " ..
      "--checks='-*,clang-analyzer-core.*,clang-analyzer-unix.Malloc,-clang-analyzer-security.insecureAPI.scanf' " ..
      "-- -std=c11 -Wall -Wextra -Wuninitialized",
      vim.fn.shellescape(fname)
    )

    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if not data or #data == 0 then return end

        local diags = {}
        local severity_map = {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
          information = vim.diagnostic.severity.INFO,
          note = vim.diagnostic.severity.HINT,
          hint = vim.diagnostic.severity.HINT,
        }

        for _, line in ipairs(data) do
          -- Match pattern: filename:line:col: severity: message
          local file, l, c, sev, msg = line:match("([^:]*):(%d+):(%d+):%s*(%w+):%s*(.+)")
          if l and c and sev and msg then
            table.insert(diags, {
              lnum = tonumber(l) - 1,
              col = tonumber(c) - 1,
              severity = severity_map[sev:lower()] or vim.diagnostic.severity.WARN,
              message = msg,
              source = "clang-tidy",
            })
          end
        end

        vim.diagnostic.set(tidy_ns, bufnr, diags)
      end,
    })
  end

  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
    callback = run_clang_tidy,
  })
end
