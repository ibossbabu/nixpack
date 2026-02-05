-- ]f - slide to next file, [f - slide to previous file
local function get_files()
  local current = vim.fn.expand('%:p')
  local dir = current ~= '' and vim.fn.fnamemodify(current, ':h') or vim.fn.getcwd()
  local files = vim.tbl_filter(
    function(f) return vim.fn.isdirectory(f) == 0 and not vim.fn.fnamemodify(f, ':t'):match('^%.') end,
    vim.fn.glob(dir .. '/*', false, true)
  )
  table.sort(files,
    function(a, b) return vim.fn.fnamemodify(a, ':t'):lower() < vim.fn.fnamemodify(b, ':t'):lower() end)
  return files
end

local function slide_file(direction)
  local files = get_files()
  if #files == 0 then
    vim.notify('No files in current directory', vim.log.levels.WARN)
    return
  end

  local current = vim.fn.expand('%:p')
  local idx = 0
  for i, f in ipairs(files) do
    if f == current then
      idx = i
      break
    end
  end

  local next_idx = direction == 'next'
      and (idx == 0 and 1 or idx % #files + 1)
      or (idx == 0 and #files or (idx == 1 and #files or idx - 1))

  vim.cmd.edit(files[next_idx])
  vim.notify(string.format('[%d/%d] %s', next_idx, #files, vim.fn.fnamemodify(files[next_idx], ':t')))
end

vim.keymap.set('n', ']f', function() slide_file('next') end, { desc = 'Slide to next file' })
vim.keymap.set('n', '[f', function() slide_file('prev') end, { desc = 'Slide to previous file' })

for i = 97, 122 do
  local letter = string.char(i)
  vim.keymap.set('n', '<leader>f' .. letter, function()
    local files = get_files()
    for idx, file in ipairs(files) do
      local first_char = vim.fn.fnamemodify(file, ':t'):match('^(%a)')
      if first_char and first_char:lower() == letter then
        vim.cmd.edit(file)
        vim.notify(string.format('[%d/%d] %s', idx, #files, vim.fn.fnamemodify(file, ':t')))
        return
      end
    end
    vim.notify('No file starting with "' .. letter .. '" found', vim.log.levels.WARN)
  end, { desc = 'Jump to first file starting with ' .. letter })
end
