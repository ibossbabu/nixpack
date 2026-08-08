local ts = vim.treesitter

local ts_enable = function(buf, lang)
  if vim.b[buf].ts_enabled then
    return
  end

  local ok, hl = pcall(ts.query.get, lang, 'highlights')
  if ok and hl then
    vim.b[buf].ts_enabled = true
    ts.start(buf)
  end
end

vim.api.nvim_create_autocmd('FileType', {
  desc = 'enable treesitter',
  callback = function(event)
    local ft = event.match
    local buf = event.buf

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local lang = vim.treesitter.language.get_lang(ft)
      if not lang then
        return
      end

      ts_enable(buf, lang)
    end)
  end,
})
