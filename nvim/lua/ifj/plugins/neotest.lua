return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-python",
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
  },

  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          args = { "-s" },
          dap = { justMyCode = false },
        }),
        -- require("neotest-plenary"),
        -- require("neotest-vim-test")({
        --   ignore_file_types = { "python", "vim", "lua" },
        -- }),
      },
    })
    local neotest = require("neotest")

    local keymap = vim.keymap

    keymap.set("n", "<leader>nt", function()
      neotest.output_panel.toggle()
    end, { desc = "Neotest toggle" })

    keymap.set("n", "<leader>nr", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Neotest run" })

    -- keymap.set("n", "<leader>ns", function()
    --   neotest.run.stop()
    -- end, { desc = "Neotest stop" })

    keymap.set("n", "<leader>na", function()
      neotest.run.attach()
    end, { desc = "Neotest attach" })

    keymap.set("n", "<leader>nw", function()
      neotest.watch.watch()
    end, { desc = "Neotest watch" })

    keymap.set("n", "<leader>nc", function()
      neotest.output_panel.clear()
    end, { desc = "Neotest clear output" })

    keymap.set("n", "<leader>ns", function()
      neotest.summary.toggle()
    end, { desc = "Neotest toggle summary" })
  end,
}
