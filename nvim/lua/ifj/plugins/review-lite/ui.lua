local M = {}

local cfg = { save_key = "ZZ", cancel_key = "<Esc>" }

function M.configure(opts)
  cfg.save_key = opts.save_key or cfg.save_key
  cfg.cancel_key = opts.cancel_key or cfg.cancel_key
end

-- Multi-line input via scratch buffer. on_done receives the string or nil on cancel.
function M.multiline_input(title, initial, on_done)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(initial or "", "\n", { plain = true }))
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.max(6, math.floor(vim.o.lines * 0.3))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = string.format(" %s  %s save · %s cancel ", title, cfg.save_key, cfg.cancel_key),
    title_pos = "center",
  })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  local function close(save)
    local text
    if save then
      text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    end
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    on_done(text)
  end
  vim.keymap.set("n", cfg.save_key, function() close(true) end, { buffer = buf })
  vim.keymap.set("n", cfg.cancel_key, function() close(false) end, { buffer = buf })
  vim.cmd("startinsert")
end

return M
