return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>s", group = "search" },
      { "<leader>d", group = "debug" },
      { "<leader>e", group = "explorer" },
      { "<leader>h", group = "harpoon/hunks" },
      { "<leader>g", group = "git" },
      { "<leader>l", group = "lsp" },
      { "<leader>n", group = "neotest" },
      { "<leader>t", group = "tabs" },
      { "<leader>w", group = "session" },
      { "<leader>x", group = "trouble" },
      { "<leader>c", group = "calls" },
      { "<leader>r", group = "rename/restart" },
      { "<leader>q", group = "quickfix" },
      { "<leader>m", group = "format" },
      { "<leader>a", group = "ai" },
    },
  },
}
