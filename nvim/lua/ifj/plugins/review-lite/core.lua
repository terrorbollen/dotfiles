local M = {}

local storage = require("ifj.plugins.review-lite.storage")
local marks = require("ifj.plugins.review-lite.marks")
local ui = require("ifj.plugins.review-lite.ui")
local export = require("ifj.plugins.review-lite.export")

---@type table<string, table[]>  -- keyed by relative path
local state = {}

local function uuid()
  return string.format("%x-%x", os.time(), math.random(0, 0xffffff))
end

local function rel_path(bufnr)
  local abs = vim.api.nvim_buf_get_name(bufnr)
  if abs == "" then return nil end
  local root = storage.git_root()
  if not root then return nil end
  local prefix = root .. "/"
  if abs:sub(1, #prefix) == prefix then return abs:sub(#prefix + 1) end
  return nil
end

local function persist() storage.save(state) end

local function render_buf(bufnr)
  local path = rel_path(bufnr)
  if path then marks.render(bufnr, path, state) end
end

local function render_all()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then render_buf(b) end
  end
end

local function selection_range()
  local mode = vim.fn.mode()
  if mode:match("[vV]") then
    local s = vim.fn.getpos("v")
    local e = vim.fn.getpos(".")
    local a, b = s[2], e[2]
    if a > b then a, b = b, a end
    vim.api.nvim_input("<Esc>")
    return a, b
  end
  local l = vim.api.nvim_win_get_cursor(0)[1]
  return l, l
end

function M.add()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = rel_path(bufnr)
  if not path then
    vim.notify("review-lite: buffer not in a git repo", vim.log.levels.WARN)
    return
  end
  local ls, le = selection_range()
  local context = vim.api.nvim_buf_get_lines(bufnr, ls - 1, ls, false)[1] or ""
  ui.multiline_input("New comment", "", function(body)
    if not body or body:match("^%s*$") then return end
    state[path] = state[path] or {}
    table.insert(state[path], {
      id = uuid(),
      type = "comment",
      line_start = ls,
      line_end = le,
      context = context,
      body = body,
      created_at = os.time(),
    })
    persist()
    render_buf(bufnr)
  end)
end

local function comment_at_cursor(bufnr)
  local path = rel_path(bufnr)
  if not path or not state[path] then return nil, nil, nil end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  for i, c in ipairs(state[path]) do
    if line >= (c.line_start or 1) and line <= (c.line_end or c.line_start or 1) then
      return path, i, c
    end
  end
  return nil, nil, nil
end

function M.edit()
  local bufnr = vim.api.nvim_get_current_buf()
  local path, idx, c = comment_at_cursor(bufnr)
  if not c then return vim.notify("review-lite: no comment at cursor") end
  ui.multiline_input("Edit comment", c.body, function(body)
    if not body then return end
    state[path][idx].body = body
    persist()
    render_buf(bufnr)
  end)
end

function M.delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local path, idx, c = comment_at_cursor(bufnr)
  if not c then return vim.notify("review-lite: no comment at cursor") end
  table.remove(state[path], idx)
  if #state[path] == 0 then state[path] = nil end
  persist()
  render_buf(bufnr)
end

local function jump(dir)
  local bufnr = vim.api.nvim_get_current_buf()
  local path = rel_path(bufnr)
  if not path or not state[path] then return end
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local lines = {}
  for _, c in ipairs(state[path]) do table.insert(lines, c.line_start or 1) end
  table.sort(lines)
  local target
  if dir == 1 then
    for _, l in ipairs(lines) do if l > cur then target = l; break end end
  else
    for i = #lines, 1, -1 do if lines[i] < cur then target = lines[i]; break end end
  end
  if target then vim.api.nvim_win_set_cursor(0, { target, 0 }) end
end

function M.next() jump(1) end
function M.prev() jump(-1) end

function M.list()
  local root = storage.git_root()
  if not root then return end
  local items = {}
  for path, list in pairs(state) do
    for _, c in ipairs(list) do
      table.insert(items, {
        filename = root .. "/" .. path,
        lnum = c.line_start or 1,
        end_lnum = c.line_end or c.line_start or 1,
        text = (c.body or ""):gsub("\n.*", ""),
      })
    end
  end
  table.sort(items, function(a, b)
    if a.filename == b.filename then return a.lnum < b.lnum end
    return a.filename < b.filename
  end)
  vim.fn.setqflist({}, " ", { title = "Review comments", items = items })
  vim.cmd("copen")
end

function M.export()
  local root = storage.git_root()
  if not root then return end
  local text = export.render(state, root)
  vim.fn.setreg("+", text)
  vim.fn.setreg("*", text)
  vim.notify("review-lite: exported to clipboard")
end

function M.preview()
  local root = storage.git_root()
  if not root then return end
  local text = export.render(state, root)
  vim.cmd("vsplit")
  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n", { plain = true }))
  vim.api.nvim_set_option_value("modified", false, { buf = buf })
end

function M.clear()
  state = {}
  storage.clear()
  render_all()
end

function M.setup(opts)
  opts = opts or {}
  marks.setup()
  ui.configure(opts.ui or {})
  state = storage.load()

  local aug = vim.api.nvim_create_augroup("ReviewLite", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    group = aug,
    callback = function(ev) render_buf(ev.buf) end,
  })

  local cmd = vim.api.nvim_create_user_command
  cmd("ReviewAdd", M.add, { range = true })
  cmd("ReviewEdit", M.edit, {})
  cmd("ReviewDelete", M.delete, {})
  cmd("ReviewList", M.list, {})
  cmd("ReviewExport", M.export, {})
  cmd("ReviewPreview", M.preview, {})
  cmd("ReviewClear", M.clear, {})
  cmd("ReviewNext", M.next, {})
  cmd("ReviewPrev", M.prev, {})

  local km = opts.keymaps or {}
  local function resolve(key, fallback_lhs, fallback_desc)
    local v = km[key]
    if v == nil then return fallback_lhs, fallback_desc end
    if type(v) == "table" then return v[1], v.desc or fallback_desc end
    return v, fallback_desc
  end
  local function map(mode, key, rhs, fallback_lhs, fallback_desc)
    local lhs, desc = resolve(key, fallback_lhs, fallback_desc)
    if lhs then vim.keymap.set(mode, lhs, rhs, { desc = desc }) end
  end
  map({ "n", "x" }, "add", M.add, "<leader>ca", "Review: add comment")
  map("n", "edit", M.edit, "<leader>ce", "Review: edit comment")
  map("n", "delete", M.delete, "<leader>cd", "Review: delete comment")
  map("n", "list", M.list, "<leader>cl", "Review: list comments")
  map("n", "next", M.next, "]n", "Review: next comment")
  map("n", "prev", M.prev, "[n", "Review: prev comment")
  map("n", "export", M.export, nil, "Review: copy markdown to clipboard")
  map("n", "preview", M.preview, nil, "Review: preview markdown in split")
  map("n", "clear", M.clear, nil, "Review: clear all comments")

  vim.schedule(render_all)
end

return M
