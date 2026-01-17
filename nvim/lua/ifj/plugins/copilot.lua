return {
  "github/copilot.vim",
  -- disable copilot by default
  lazy = true,
  keys = {
    { "<leader>ce", desc = "Enable Copilot" },
    { "<leader>cd", desc = "Disable Copilot" },
  },
  config = function()
    vim.cmd("Copilot setup")
    vim.cmd("Copilot enable")

    vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      desc = "Enable Copilot",
    })

    vim.keymap.set("i", "<C-]>", 'copilot#Next()', {
      expr = true,
      replace_keycodes = false,
      desc = "Next Copilot suggestion",
    })

    vim.keymap.set("i", "<C-[>", 'copilot#Previous()', {
      expr = true,
      replace_keycodes = false,
      desc = "Previous Copilot suggestion",
    })


    vim.keymap.set("n", "<leader>cd", function()
      vim.cmd(":Copilot disable", {
        desc = "Disable Copilot",
      })
      print("Copilot deactivated 🔥")
    end)

    vim.keymap.set("n", "<leader>ce", function()
      vim.cmd("Copilot enable")
      print("Copilot enabled 🤖")
    end, {
      desc = "Enable Copilot",
    })
  end,
}
