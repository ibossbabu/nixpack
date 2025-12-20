return {
  "guard.nvim",
  before = function()
    vim.g.guard_config = {
      fmt_on_save = true,
      lsp_as_default_formatter = true,
      save_on_fmt = true,
      auto_lint = true,
      lint_interval = 1000,
      refresh_diagnostic = true,
    }
  end,
  after = function()
    -- Override vim.fn.executable to bypass Guard's checks
    local original_executable = vim.fn.executable

    vim.fn.executable = function(cmd)
      if cmd == 'clang-format' or cmd == 'clang-tidy'
          or cmd == 'ormolu' or cmd == 'hlint' then
        return 1 -- Pretend they exist
      end
      return original_executable(cmd)
    end

    -- Setup Guard normally
    local ft = require("guard.filetype")
    local lint = require("guard.lint")

    -- Nix ==>
    ft("nix"):fmt({
      cmd = 'alejandra',
      args = { '--quiet' },
      stdin = true,
    })

    -- C ==>
    ft('c'):fmt({
      cmd = "clang-format",
      args = { "--style={IndentWidth: 4}" },
      stdin = true,
    }):lint({
      cmd = "clang-tidy",
      args = { "--quiet",
        "--checks=-clang-diagnostic-format-security,-clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling"
      },
      fname = true,
      parse = lint.from_regex({
        source = "clang-tidy",
        regex = ":(%d+):(%d+):%s+(%w+):%s+(.-)%s+%[(.-)%]",
        groups = { "lnum", "col", "severity", "message", "code" },
        severities = {
          information = lint.severities.info,
          hint = lint.severities.info,
          note = lint.severities.style,
        },
      }),
    })

    -- Haskell ==>
    local severities = {
      suggestion = lint.severities.info,
      warning = lint.severities.warning,
      error = lint.severities
          .error,
    }
    ft('hs'):fmt({
      cmd = 'ormolu',
      args = { '--color', 'never', '--stdin-input-file' },
      stdin = true,
      fname = true,
    }):lint({
      cmd = 'hlint',
      args = { '--json', '--no-exit-code' },
      fname = true,
      parse = function(result, bufnr)
        local diags = {}

        result = result ~= '' and vim.json.decode(result) or {}
        for _, d in ipairs(result) do
          table.insert(
            diags,
            lint.diag_fmt(
              bufnr,
              d.startLine > 0 and d.startLine - 1 or 0,
              d.startLine > 0 and d.startColumn - 1 or 0,
              d.hint .. (d.to ~= vim.NIL and (': ' .. d.to) or ''),
              severities[d.severity:lower()],
              'hlint'
            )
          )
        end

        return diags
      end,
    })

    -- Restore original function
    vim.fn.executable = original_executable
  end,

  vim.keymap.set({ "n", "v" }, "<leader>gf", "<cmd>Guard fmt<cr>",
    { noremap = true, silent = true, desc = "Guard format" })
}
