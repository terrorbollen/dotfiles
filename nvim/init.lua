vim.loader.enable()

vim.filetype.add({
  filename = { [".env"] = "sh" },
  pattern = { ["%.env%..*"] = "sh" },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh", "conf", "config", "dotenv", "gitignore", "gitconfig" },
  callback = function()
    vim.bo.commentstring = "# %s"
  end,
})

for _, p in ipairs({
  "gzip",
  "matchit",
  "matchparen",
  "netrwPlugin",
  "rplugin",
  "tarPlugin",
  "tohtml",
  "tutor",
  "zipPlugin",
  "spellfile",
}) do
  vim.g["loaded_" .. p] = 1
end

require("ifj.core")
require("ifj.lazy")
require("ifj.custom")
require("ifj.lsp")
