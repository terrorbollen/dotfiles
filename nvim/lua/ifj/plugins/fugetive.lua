return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite" },
  keys = {
    { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git blame" },
  },
}
