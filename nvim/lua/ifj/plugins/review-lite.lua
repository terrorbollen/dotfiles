return {
  dir = vim.fn.stdpath("config") .. "/lua/ifj/plugins/review-lite",
  name = "review-lite",
  event = "VeryLazy",
  opts = {
    keymaps = {
      add     = { "<leader>ara", desc = "Review: add comment" },
      reply   = { "<leader>arr", desc = "Review: reply to thread" },
      edit    = { "<leader>are", desc = "Review: edit last message" },
      resolve = { "<leader>aro", desc = "Review: resolve thread" },
      delete  = { "<leader>ard", desc = "Review: delete thread" },
      list    = { "<leader>arl", desc = "Review: list comments" },
      next    = { "<leader>arn", desc = "Review: next comment" },
      prev    = { "<leader>arb", desc = "Review: prev comment" },
      export  = { "<leader>arx", desc = "Review: copy markdown to clipboard" },
      preview = { "<leader>arp", desc = "Review: preview markdown in split" },
      send    = { "<leader>ars", desc = "Review: send open threads to clipboard" },
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
