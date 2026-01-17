vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("v", "JK", "<ESC>", { desc = "Exit visual mode with JK" })

keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Paste in inser mode
keymap.set("i", "<C-p>", "<Esc>\"+pa", { desc = "Paste in insert mode" })

-- Junp down/up center cursor

keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "<C-d>", "<C-d>zz")

-- jump multiple liness
keymap.set({ "n", "v" }, "<C-j>", "7j", { desc = "Jump 7 lines down" })
keymap.set({ "n", "v" }, "<C-k>", "7k", { desc = "Jump 7 lines up" })

-- Jump start/ end of line
keymap.set({ "n", "v" }, "<C-l>", "$")
keymap.set({ "n", "v" }, "<C-h>", "^")

-- Go left/ right when in insert mode
keymap.set("i", "<C-l>", "<Right>")
keymap.set("i", "<C-h>", "<Left>")

-- Remove highlight after search
keymap.set("n", "<esc>", ":noh<cr>")

-- Move selected line / block of text in visual mode
keymap.set("x", "K", ":move '<-2<CR>gv-gv")
keymap.set("x", "J", ":move '>+1<CR>gv-gv")

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character:without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>qr", ":cgetexpr getqflist()<CR>", { noremap = true, silent = true })

-- Cycle through quickfix list items
vim.keymap.set('n', '“', '<Cmd>try | cnext | catch | cfirst | catch | endtry<CR>')
vim.keymap.set('n', '‘', '<Cmd>try | cprevious | catch | clast | catch | endtry<CR>')

vim.api.nvim_create_user_command("CloseBuffers", "%bd | e#", {
  desc = "Close all buffers",
})
