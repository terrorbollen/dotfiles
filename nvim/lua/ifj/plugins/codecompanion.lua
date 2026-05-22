return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = "OPENAI_API_KEY",
          },
          schema = {
            model = {
              default = "gpt-5.5",
            },
          },
        })
      end,
    },
    strategies = {
      chat = { adapter = "openai" },
      inline = { adapter = "openai" },
    },
    display = {
      chat = {
        render_headers = false,
      },
    },
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" },
    { "<leader>aa", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to chat" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "Inline ask" },
    {
      "<leader>ae",
      "<cmd>CodeCompanionExplain<cr>",
      mode = { "v" },
      { desc = "Explain code" },
    },
    {
      "<leader>ar",
      "<cmd>CodeCompanionRefactor<cr>",
      mode = { "v" },
      { desc = "Refactor code" },
    },
    {
      "<leader>aw",
      "<cmd>CodeCompanionRewrite<cr>",
      mode = { "v" },
      { desc = "Rewrite code" },
    },
    {
      "<leader>ad",
      "<cmd>CodeCompanionDocstring<cr>",
      mode = { "v" },
      { desc = "Add docstring" },
    },
    {
      "<leader>at",
      "<cmd>CodeCompanionTest<cr>",
      mode = { "v" },
      { desc = "Generate tests" },
    },
  },
}
