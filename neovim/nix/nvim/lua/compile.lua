vim.keymap.set("n", "<C-s>x", function()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.input("Enter: ")
  if output == "" then
    output = "out"
  end
  -- Development flags
  local flags = {
    -- "-Wall",
    -- "-Wextra",  -- Warning
    -- "-Wpedantic",
    "-g",
    "-O0",
    "-lm"
  }

  local cmd = string.format(
    "gcc %s -o %s %s",
    file,
    output,
    table.concat(flags, " ")
  )
  local success = os.execute(cmd)
  if success then
    print("Compilation successful")
  else
    print("Compilation failed")
  end
end, { desc = "Compile current C file" })
