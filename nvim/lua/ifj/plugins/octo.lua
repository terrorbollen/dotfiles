return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  opts = {
    picker = "snacks",
    enable_builtin = true,
    use_local_fs = true,
  },
  config = function(_, opts)
    require("octo").setup(opts)
    vim.treesitter.language.register("markdown", "octo")

    -- Octo hardcodes the review file panel to a bottom split; move it to the right
    local FilePanel = require("octo.reviews.file-panel").FilePanel
    FilePanel.open = function(self)
      if not self:buf_loaded() then
        self:init_buffer()
      end
      if self:is_open() then
        return
      end

      vim.cmd "vsp"
      vim.cmd "wincmd L"
      vim.cmd "vertical resize 40"
      self.winid = vim.api.nvim_get_current_win()
      vim.cmd("buffer " .. self.bufid)

      for k, v in pairs(FilePanel.winopts) do
        vim.api.nvim_set_option_value(k, v, { win = self.winid, scope = "local" })
      end
      vim.wo[self.winid].winfixwidth = true

      vim.cmd "wincmd ="
    end

    -- Octo shows review threads by replacing the other diff side; use a bottom panel instead.
    -- Every thread placement goes through FileEntry:get_alternative_win, so we hand out our own window.
    local reviews = require "octo.reviews"
    local thread_panel = require "octo.reviews.thread-panel"
    local FileEntry = require("octo.reviews.file-entry").FileEntry
    local panels = {} -- tabpage -> { win, overview, targets }
    local overview_ns = vim.api.nvim_create_namespace "octo_thread_overview"

    local function get_panel()
      local panel = panels[vim.api.nvim_get_current_tabpage()]
      if panel and vim.api.nvim_win_is_valid(panel.win) then
        return panel
      end
    end

    -- List every thread in the PR; shown whenever the cursor isn't on a thread
    local function render_overview(panel)
      local review = reviews.get_current_review()
      local threads = review and vim.tbl_values(review.threads) or {}
      table.sort(threads, function(a, b)
        if a.path ~= b.path then
          return a.path < b.path
        end
        return (tonumber(a.line) or 0) < (tonumber(b.line) or 0)
      end)

      local lines, hls, targets = {}, {}, {}
      for _, thread in ipairs(threads) do
        local comments = thread.comments.nodes
        local first = comments[1]
        local author = first and first.author ~= vim.NIL and first.author.login or "ghost"
        local location = string.format("%s:%s", thread.path, tostring(thread.line))
        local info = {}
        if #comments > 1 then
          table.insert(info, string.format("%d %s", #comments - 1, #comments == 2 and "reply" or "replies"))
        end
        if thread.isResolved then
          table.insert(info, "resolved")
        end
        local suffix = #info > 0 and "  (" .. table.concat(info, ", ") .. ")" or ""

        table.insert(lines, string.format("%s  %s%s", location, author, suffix))
        targets[#lines] = thread
        table.insert(hls, { #lines, 0, #location, "Directory" })
        table.insert(hls, { #lines, #location + 2, #location + 2 + #author, "Identifier" })
        table.insert(hls, { #lines, #location + 2 + #author, -1, "Comment" })

        local body = first and first.body:gsub("\r", ""):match "[^\n]*" or ""
        table.insert(lines, "    " .. body)
        targets[#lines] = thread
      end
      if #lines == 0 then
        lines = { "  No review threads on this PR" }
      end

      local buf = panel.overview
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
      vim.api.nvim_buf_clear_namespace(buf, overview_ns, 0, -1)
      for _, hl in ipairs(hls) do
        local line = vim.api.nvim_buf_get_lines(buf, hl[1] - 1, hl[1], false)[1]
        vim.api.nvim_buf_set_extmark(buf, overview_ns, hl[1] - 1, hl[2], {
          end_col = hl[3] == -1 and #line or hl[3],
          hl_group = hl[4],
        })
      end
      panel.targets = targets
    end

    local function jump_to_thread(panel)
      local thread = panel.targets[vim.api.nvim_win_get_cursor(0)[1]]
      local review = reviews.get_current_review()
      if not (thread and review) then
        return
      end
      local layout = review.layout
      local file = layout:get_current_file()
      if not file or file.path ~= thread.path then
        for _, f in ipairs(layout.files) do
          if f.path == thread.path then
            layout:set_current_file(f)
            file = f
            break
          end
        end
      end
      if not file or file.path ~= thread.path then
        return
      end
      local win = thread.diffSide == "LEFT" and file.left_winid or file.right_winid
      vim.api.nvim_set_current_win(win)
      pcall(vim.api.nvim_win_set_cursor, win, { thread.line, 0 })
      vim.cmd "normal! zz"
      thread_panel.show_review_threads(false)
    end

    -- Octo runs `diffoff!` when showing a thread; turn the diff back on while keeping the cursor
    local function redraw_diff(file)
      local diff_win = file.right_winid or file.left_winid
      if not (diff_win and vim.api.nvim_win_is_valid(diff_win)) or vim.wo[diff_win].diff then
        return
      end
      local win = vim.api.nvim_get_current_win()
      local cursor = vim.api.nvim_win_get_cursor(win)
      file:show_diff()
      pcall(vim.api.nvim_win_set_cursor, win, cursor)
    end

    local function open_panel()
      local cur = vim.api.nvim_get_current_win()
      local review = reviews.get_current_review()
      local file_panel = review and review.layout.file_panel
      local file_panel_open = file_panel and file_panel:is_open()
      -- close the file panel so the split only spans the diff, then reopen it full height
      if file_panel_open then
        file_panel:close()
      end

      local overview = vim.api.nvim_create_buf(false, true)
      vim.bo[overview].modifiable = false

      vim.cmd "botright 15split"
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, overview)
      for opt, value in pairs { diff = false, scrollbind = false, cursorbind = false, winfixheight = true } do
        vim.wo[win][opt] = value
      end

      if file_panel_open then
        file_panel:open()
      end
      -- reopening the file panel gives it a new window id
      if not vim.api.nvim_win_is_valid(cur) and file_panel_open then
        cur = file_panel.winid
      end
      vim.api.nvim_set_current_win(cur)

      local panel = { win = win, overview = overview, targets = {} }
      panels[vim.api.nvim_get_current_tabpage()] = panel
      render_overview(panel)
      vim.keymap.set("n", "<CR>", function()
        jump_to_thread(panel)
      end, { buffer = overview, desc = "jump to review thread" })
      return panel
    end

    -- keep the panel visible for the whole review, not just once a thread shows up
    local Layout = require("octo.reviews.layout").Layout
    local init_layout = Layout.init_layout
    Layout.init_layout = function(self, ...)
      init_layout(self, ...)
      if not get_panel() then
        open_panel()
      end
    end

    FileEntry.get_alternative_win = function()
      return (get_panel() or open_panel()).win
    end

    thread_panel.hide_thread_buffer = function(_, file)
      local panel = get_panel()
      if panel and vim.api.nvim_win_get_buf(panel.win) ~= panel.overview then
        render_overview(panel)
        vim.api.nvim_win_set_buf(panel.win, panel.overview)
        redraw_diff(file)
      end
    end

    -- threads change when comments are added, resolved or the review reloads
    local update_threads = reviews.Review.update_threads
    reviews.Review.update_threads = function(self, ...)
      update_threads(self, ...)
      local panel = get_panel()
      if panel then
        render_overview(panel)
      end
    end

    local show_review_threads = thread_panel.show_review_threads
    thread_panel.show_review_threads = function(...)
      show_review_threads(...)
      local review = reviews.get_current_review()
      local file = review and review.layout:get_current_file()
      if file and get_panel() then
        redraw_diff(file)
      end
    end

    local add_comment = reviews.Review.add_comment
    reviews.Review.add_comment = function(self, ...)
      add_comment(self, ...)
      local file = self.layout:get_current_file()
      if file then
        redraw_diff(file)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "octo_panel",
      callback = function(args)
        vim.keymap.set("n", "l", function()
          -- select_entry moves focus to the diff; stay in the panel instead
          local win = vim.api.nvim_get_current_win()
          require("octo.mappings").select_entry()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
          end
        end, { buffer = args.buf, desc = "show selected changed file diffs (keep focus)" })
      end,
    })
  end,
  keys = {
    {
      "<leader>oi",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      "<leader>op",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      "<leader>or",
      "<CMD>Octo review<CR>",
      desc = "Start/resume GitHub PR review",
    },
    {
      "<leader>ob",
      "<CMD>Octo review browse<CR>",
      desc = "Browse GitHub PR review (read-only)",
    },
    {
      "<leader>od",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      "<leader>on",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      "<leader>os",
      function()
        require("octo.utils").create_base_search_command { include_current_repo = true }
      end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons", -- optional if file_panel.icons is a function
  },
}
