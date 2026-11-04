return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>dv", desc = "Toggle diffview" },
    { "<leader>dh", desc = "Toggle file history" },
    { "<leader>dm", desc = "Toggle diff against main" },
  },
  config = function()
    local diffview = require("diffview")

    -- Yank the path of the file/folder under the cursor in the file panel.
    -- kind: "relative" (to cwd), "absolute", or "name" (basename)
    local function yank_path(kind)
      return function()
        local view = require("diffview.lib").get_current_view()
        if not view then
          return
        end
        local item = view:infer_cur_file(true)
        if not item or not item.path then
          return
        end
        local root = view.adapter.ctx.toplevel
        local abs = item.absolute_path or vim.fs.joinpath(root, item.path)
        local path = vim.fn.fnamemodify(abs, ":.")
        if kind == "absolute" then
          path = abs
        elseif kind == "name" then
          path = vim.fs.basename(item.path)
        end
        vim.fn.setreg('"', path)
        vim.fn.setreg("+", path)
        vim.notify("Yanked: " .. path)
      end
    end

    -- enable comment
    diffview.setup({
      keymaps = {
        file_panel = {
          { "n", "y", yank_path("relative"), { desc = "Yank relative path" } },
          { "n", "Y", yank_path("absolute"), { desc = "Yank absolute path" } },
          { "n", "gy", yank_path("name"), { desc = "Yank file name" } },
        },
      },
      file_panel = {
        listing_style = "tree", -- One of 'list' or 'tree'
        tree_options = { -- Only applies when listing_style is 'tree'
          flatten_dirs = true, -- Flatten dirs that only contain one single dir
          folder_statuses = "never", -- One of 'never', 'only_folded' or 'always'.
        },
        win_config = {
          position = "right",
          width = 40,
          win_opts = {},
        },
      },
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = false,
          winbar_info = true,
        },
      },
    })

    -- Check if any diffview tab is open by looking at the view state
    local function toggle_diffview()
      local lib = require("diffview.lib")
      local view = lib.get_current_view()
      if view ~= nil then
        vim.cmd("DiffviewClose")
      else
        vim.cmd("DiffviewOpen")
      end
    end

    local function toggle_file_history()
      local lib = require("diffview.lib")
      local view = lib.get_current_view()
      if view ~= nil then
        vim.cmd("tabclose")
      else
        vim.cmd("DiffviewFileHistory %")
      end
    end

    -- Diff the working tree against where the branch left main, so the view
    -- shows what a PR would contain plus uncommitted work; `main...HEAD` would
    -- drop the uncommitted part
    local function toggle_diff_main()
      local lib = require("diffview.lib")
      if lib.get_current_view() ~= nil then
        vim.cmd("DiffviewClose")
        return
      end
      local base = vim.fn.systemlist({ "git", "merge-base", "main", "HEAD" })[1]
      if vim.v.shell_error ~= 0 then
        vim.notify("No merge base with main", vim.log.levels.ERROR)
        return
      end
      vim.cmd("DiffviewOpen " .. base)
    end

    local keymap = vim.keymap
    keymap.set("n", "<leader>dv", toggle_diffview, { desc = "Toggle diffview" })
    keymap.set("n", "<leader>dm", toggle_diff_main, { desc = "Toggle diff against main" })
    keymap.set("n", "<leader>dh", toggle_file_history, { desc = "Toggle file history" })
  end,
}
