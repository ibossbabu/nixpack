local M = {}

M.setup_all = function()
  require("linters.oxlint")()
  require("linters.clang_tidy")()
  require("linters.clippy")()
end

return M
