return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "e", desc = "New File", action = ":ene" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
          { icon = " ", key = "g", desc = "Find Word", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = "󰁯 ", key = "s", desc = "Restore Session", action = ":AutoSession restore" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      },
    },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = false },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
        },
      },
      win = {
        input = {
          keys = {
            ["<C-k>"] = { "list_up", mode = { "i", "n" } },
            ["<C-j>"] = { "list_down", mode = { "i", "n" } },
            ["<C-q>"] = { "qflist", mode = { "i", "n" } },
            ["<C-t>"] = { "trouble_open", mode = { "i", "n" } },
            ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
          },
        },
        list = {
          keys = {
            ["<C-k>"] = { "list_up", mode = { "n", "x" } },
            ["<C-j>"] = { "list_down", mode = { "n", "x" } },
            ["<C-q>"] = { "qflist", mode = { "n", "x" } },
            ["<C-t>"] = { "trouble_open", mode = { "n", "x" } },
            ["<C-u>"] = { "preview_scroll_up", mode = { "n", "x" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "n", "x" } },
          },
        },
        preview = {
          keys = {
            ["<C-k>"] = "list_up",
            ["<C-j>"] = "list_down",
            ["<C-u>"] = "preview_scroll_up",
            ["<C-d>"] = "preview_scroll_down",
          },
        },
      },
      actions = {
        trouble_open = function(picker)
          picker:close()
          local trouble = require("trouble")
          trouble.open({ mode = "snacks", focus = true })
        end,
      },
      exclude = {
        "%.git/",
        "%.venv/",
        "%.next/",
        "%.cache/",
        "node_modules/",
        "__pycache__/",
        "%.pyc",
      },
    },
    notifier = { enabled = false },
    terminal = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    gitbrowse = {
      enabled = true,
      what = "permalink",
      url_patterns = {
        ["git.booli.se"] = {
          branch = "/-/tree/{branch}",
          file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
          permalink = "/-/blob/{commit}/{file}#L{line_start}-L{line_end}",
          commit = "/-/commit/{commit}",
        },
      },
    },
  },
  keys = {
    {
      "<leader><leader>",
      function()
        Snacks.picker.buffers()
      end,
      desc = "List open buffers",
    },
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>sC",
      function()
        Snacks.picker.commands({
          finder = "vim_commands",
          format = "command",
          preview = "preview",
          confirm = "cmd",
        })
      end,
    },
    {
      "<leader>sK",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse.open({ what = "commit" })
      end,
      desc = "Git Browse",
      mode = { "n", "v" },
    },
    -- Picker keymaps (matching telescope)
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Fuzzy find files in cwd",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Fuzzy find recent files",
    },
    {
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.grep()
      end,
      desc = "Find string in cwd",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Find string under cursor in cwd",
    },
    {
      "<leader>ft",
      function()
        Snacks.picker.todo_comments()
      end,
      desc = "Find todos",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep({ live = true })
      end,
      desc = "Live grep",
    },
    {
      "<C-t><C-t>",
      function()
        Snacks.terminal.toggle()
      end,
      desc = "Toggle floating terminal",
      mode = { "n", "t" },
    },
  },
}
