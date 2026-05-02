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
    end, { desc = "Neotest toggle output panel" })

    keymap.set("n", "<leader>nn", function()
      neotest.run.run()
    end, { desc = "Neotest run nearest" })

    keymap.set("n", "<leader>nf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Neotest run file" })

    keymap.set("n", "<leader>nd", function()
      neotest.run.run({ strategy = "dap" })
    end, { desc = "Neotest debug nearest" })

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
