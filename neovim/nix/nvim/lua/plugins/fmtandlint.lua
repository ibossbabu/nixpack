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
          or cmd == 'ormolu' or cmd == 'hlint'
          or cmd == 'ocamlformat' or cmd == 'bunx' then
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

    -- Ocaml ==>
    ft("ocaml", "ocamlinterface", "menhir", "ocamllex"):fmt({
      cmd = "ocamlformat",
      stdin = true,
      fname = true,
      args = { "--name", "%" },
    })

    -- TypeScript ==>
    ft("typescript", "typescriptreact", "javascript", "javascriptreact"):lint({
      cmd = "bunx",
      args = { "oxlint", "--type-aware", "--format", "json" },
      fname = true,
      parse = lint.from_json({
        get_diagnostics = function(output)
          local decoded = vim.json.decode(output)
          return decoded.diagnostics or {}
        end,
        attributes = {
          lnum = function(d)
            return d.labels and d.labels[1] and d.labels[1].span.line or 1
          end,
          col = function(d)
            return d.labels and d.labels[1] and d.labels[1].span.column or 1
          end,
          -- message = "message",
          message = function(d)
            local msg = d.message
            if d.help and d.help ~= "" then
              msg = msg .. "\n" .. d.help
            end
            return msg
          end,
          --code = "code",
          severity = "severity",
        },
        severities = {
          error = lint.severities.error,
          warning = lint.severities.warn,
        },
        source = "oxlint",
      }),
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
    ft('haskell'):fmt({
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
