return {
  "rmagatti/auto-session",
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { },
    -- only auto-restore when nvim opened with a directory arg (not bare `nvim`)
    -- bare `nvim` shows snacks dashboard instead
    auto_restore = function()
      return vim.fn.argc() > 0
    end,
  },
  config = function(_, opts)
    require('auto-session').setup(opts)
    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
    keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
  end,
}
