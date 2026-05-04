vim.loader.enable()

for _, p in ipairs({
  "gzip", "matchit", "matchparen", "netrwPlugin", "rplugin",
  "tarPlugin", "tohtml", "tutor", "zipPlugin", "spellfile",
}) do
  vim.g["loaded_" .. p] = 1
end

require("ifj.core")
require("ifj.lazy")
require("ifj.custom")
require("ifj.lsp")


