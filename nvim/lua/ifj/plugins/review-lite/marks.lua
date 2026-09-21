local M = {}

local ns = vim.api.nvim_create_namespace("review-lite")
local sign_group = "ReviewLite"

local ICONS = {
  note = { text = "N", hl = "DiagnosticInfo" },
  suggestion = { text = "S", hl = "DiagnosticHint" },
  issue = { text = "I", hl = "DiagnosticWarn" },
  praise = { text = "P", hl = "DiagnosticOk" },
}

function M.setup()
  for name, def in pairs(ICONS) do
    vim.fn.sign_define("ReviewLite_" .. name, { text = def.text, texthl = def.hl })
  end
end

-- Best-effort re-anchor: if stored line still matches `context`, use it;
-- otherwise search buffer for first occurrence of context.
local function resolve_line(bufnr, comment)
  local total = vim.api.nvim_buf_line_count(bufnr)
  local ls = math.min(comment.line_start or 1, total)
  local cur = vim.api.nvim_buf_get_lines(bufnr, ls - 1, ls, false)[1] or ""
  if cur == comment.context then return ls end
  if comment.context and comment.context ~= "" then
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, l in ipairs(lines) do
      if l == comment.context then return i end
    end
  end
  return ls
end

function M.render(bufnr, path, all_comments)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  vim.fn.sign_unplace(sign_group, { buffer = bufnr })
  local list = all_comments[path]
  if not list then return end
  for _, c in ipairs(list) do
    local line = resolve_line(bufnr, c)
    pcall(vim.fn.sign_place, 0, sign_group, "ReviewLite_" .. (c.type or "note"), bufnr, { lnum = line, priority = 10 })
    local hl_end = math.min((c.line_end or line) - 1, vim.api.nvim_buf_line_count(bufnr) - 1)
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line - 1, 0, {
      end_row = hl_end,
      hl_group = "CursorLine",
      hl_eol = true,
      priority = 100,
      virt_text = { { "  " .. (c.body or ""):gsub("\n.*", ""), "Comment" } },
      virt_text_pos = "eol",
    })
  end
end

return M
