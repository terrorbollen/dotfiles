return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>hx", desc = "Harpoon add file" },
    { "<leader>hm", desc = "Harpoon open menu" },
    { "<leader>hn", desc = "Harpoon prev" },
    { "<leader>hp", desc = "Harpoon next" },
    { "<leader>h1", desc = "Harpoon file 1" },
    { "<leader>h2", desc = "Harpoon file 2" },
    { "<leader>h3", desc = "Harpoon file 3" },
    { "<leader>h4", desc = "Harpoon file 4" },
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local keymap = vim.keymap
    keymap.set("n", "<leader>hx", function() harpoon:list():add() end, { desc = "Harpoon add file" })
    keymap.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon open menu" })
    keymap.set("n", "<leader>hn", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
    keymap.set("n", "<leader>hp", function() harpoon:list():next() end, { desc = "Harpoon next" })
    keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
  end,
}
