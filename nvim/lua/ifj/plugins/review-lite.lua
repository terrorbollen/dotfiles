return {
  dir = vim.fn.stdpath("config") .. "/lua/ifj/plugins/review-lite",
  name = "review-lite",
  event = "VeryLazy",
  opts = {
    keymaps = {
      add     = { "<leader>arr", desc = "Review: add comment" },
      edit    = { "<leader>are", desc = "Review: edit comment" },
      delete  = { "<leader>ard", desc = "Review: delete comment" },
      list    = { "<leader>arl", desc = "Review: list comments" },
      next    = { "]n",          desc = "Review: next comment" },
      prev    = { "[n",          desc = "Review: prev comment" },
      export  = { "<leader>arx", desc = "Review: copy markdown to clipboard" },
      preview = { "<leader>arp", desc = "Review: preview markdown in split" },
      clear   = { "<leader>arc", desc = "Review: clear all comments" },
    },
    ui = {
      save_key = "ZZ",
      cancel_key = "<Esc>",
    },
  },
  config = function(_, opts)
    require("ifj.plugins.review-lite.core").setup(opts)
  end,
}
