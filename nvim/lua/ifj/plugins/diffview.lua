return {
  "sindrets/diffview.nvim",
  config = function()
    local diffview = require("diffview")

    -- enable comment
    diffview.setup({
      file_panel = {
        listing_style = "tree", -- One of 'list' or 'tree'
        tree_options = { -- Only applies when listing_style is 'tree'
          flatten_dirs = true, -- Flatten dirs that only contain one single dir
          folder_statuses = "never", -- One of 'never', 'only_folded' or 'always'.
        },
        win_config = {
          position = "right",
          width = 40,
          win_opts = {},
        },
      },
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = false,
          winbar_info = true,
        },
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<CR>", { desc = "Open diffview" }) -- restore last workspace session for current directory
    keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" })
    keymap.set("n", "<leader>dh", "<cmd>DiffviewFileHistory %<CR>", { desc = "Open file history" })
  end,
}
