return function()
  local clippy_ns = vim.api.nvim_create_namespace("manual_clippy")

  local function run_clippy()
    local bufnr = vim.api.nvim_get_current_buf()
    local fname = vim.api.nvim_buf_get_name(bufnr)
    vim.diagnostic.reset(clippy_ns, bufnr)

    local cmd = string.format("cargo clippy --message-format=json --quiet 2>&1")

    vim.fn.jobstart(cmd, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if not data or #data == 0 or (#data == 1 and data[1] == "") then return end

        local diags = {}
        local severity_map = {
          warning = vim.diagnostic.severity.WARN,
          note = vim.diagnostic.severity.INFO,
          help = vim.diagnostic.severity.HINT,
        }

        -- Get relative filename for comparison
        local rel_fname = vim.fn.fnamemodify(fname, ":.")

        -- Cargo clippy outputs line-delimited JSON
        for _, line in ipairs(data) do
          if line ~= "" then
            local ok, item = pcall(vim.json.decode, line)
            if ok and item and item.reason == "compiler-message" and item.message then
              local msg = item.message
              for _, span in ipairs(msg.spans or {}) do
                if span.file_name == rel_fname and span.is_primary then
                  local message = msg.message
                  if span.suggested_replacement
                      and span.suggested_replacement ~= vim.NIL
                      and type(span.suggested_replacement) == "string" then
                    message = message .. "\nSuggestion: " .. span.suggested_replacement
                  end

                  table.insert(diags, {
                    lnum = (span.line_start > 0) and (span.line_start - 1) or 0,
                    col = (span.column_start > 0) and (span.column_start - 1) or 0,
                    end_lnum = (span.line_end > 0) and (span.line_end - 1) or nil,
                    end_col = (span.column_end > 0) and (span.column_end - 1) or nil,
                    severity = severity_map[msg.level] or vim.diagnostic.severity.WARN,
                    message = message,
                    source = "clippy",
                  })
                end
              end
            end
          end
        end

        vim.diagnostic.set(clippy_ns, bufnr, diags)
      end,
    })
  end

  -- Linting on save and buffer enter
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = { "*.rs" },
    callback = run_clippy,
  })
end
