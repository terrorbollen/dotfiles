return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>dv", desc = "Toggle diffview" },
    { "<leader>dh", desc = "Toggle file history" },
  },
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

    -- Check if any diffview tab is open by looking at the view state
    local function toggle_diffview()
      local lib = require("diffview.lib")
      local view = lib.get_current_view()
      if view ~= nil then
        vim.cmd("DiffviewClose")
      else
        vim.cmd("DiffviewOpen")
      end
    end

    local function toggle_file_history()
      local lib = require("diffview.lib")
      local view = lib.get_current_view()
      if view ~= nil then
        vim.cmd("tabclose")
      else
        vim.cmd("DiffviewFileHistory %")
      end
    end

    local keymap = vim.keymap
    keymap.set("n", "<leader>dv", toggle_diffview, { desc = "Toggle diffview" })
    keymap.set("n", "<leader>dh", toggle_file_history, { desc = "Toggle file history" })
  end,
}
