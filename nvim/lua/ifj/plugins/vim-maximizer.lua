-- native maximize toggle, no plugin needed
local maximized = false
local saved_layout = nil

vim.keymap.set("n", "<leader>sm", function()
  if maximized then
    vim.cmd("wincmd =")
    maximized = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    maximized = true
  end
end, { desc = "Maximize/minimize a split" })

return {}
