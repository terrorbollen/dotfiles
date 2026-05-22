return {
  "harrisoncramer/gitlab.nvim",
  cmd = { "GitLab" },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "stevearc/dressing.nvim", -- Recommended but not required. Better UI for pickers.
    "nvim-tree/nvim-web-devicons", -- Recommended but not required. Icons in discussion tree.
  },
  build = function()
    require("gitlab.server").build(true)
  end, -- Builds the Go binary
  config = function()
    require("gitlab").setup({
      -- attachment_dir = vim.fn.expand("~/.cache/gitlab.nvim/attachments"),
      popup = {
        width = "30%",
        height = "40%",
      },
    })

      vim.keymap.set("n", "<leader>rm", "<cmd>lua require('gitlab').choose_merge_request()<cr>")
      vim.keymap.set("v", "C", "<cmd>lua require('gitlab').create_multiline_comment()<cr>")
      vim.keymap.set("v", "S", "<cmd>lua require('gitlab').create_comment_suggestion()<cr>")
      vim.keymap.set("v", "ZA", "<cmd>lua require('gitlab').keymaps.popup.perform_linewise_action()<cr>")
  end,
}
