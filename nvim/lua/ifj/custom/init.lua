-- exit terminal mode with double escape
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- Dim neovim when losing focus (for tmux pane visibility)
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    vim.cmd("hi Normal guibg=#181825")
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    vim.cmd("hi Normal guibg=#1e1e2e")
  end,
})
