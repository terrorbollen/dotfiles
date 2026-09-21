local M = {}

local function read_lines(abs_path, from, to)
  local f = io.open(abs_path, "r")
  if not f then return {} end
  local out, i = {}, 0
  for line in f:lines() do
    i = i + 1
    if i >= from and i <= to then table.insert(out, line) end
    if i > to then break end
  end
  f:close()
  return out
end

function M.render(comments_by_file, git_root)
  local parts = { "# Review comments", "" }
  local files = vim.tbl_keys(comments_by_file)
  table.sort(files)
  for _, path in ipairs(files) do
    local list = comments_by_file[path]
    if list and #list > 0 then
      table.insert(parts, "## " .. path)
      table.insert(parts, "")
      for _, c in ipairs(list) do
        local ls, le = c.line_start or 1, c.line_end or c.line_start or 1
        table.insert(parts, string.format("### L%d-%d · %s", ls, le, c.type or "note"))
        table.insert(parts, "")
        table.insert(parts, c.body or "")
        table.insert(parts, "")
        local snippet = read_lines(git_root .. "/" .. path, ls, le)
        if #snippet > 0 then
          local ft = vim.filetype.match({ filename = path }) or ""
          table.insert(parts, "```" .. ft)
          for _, l in ipairs(snippet) do table.insert(parts, l) end
          table.insert(parts, "```")
          table.insert(parts, "")
        end
      end
    end
  end
  return table.concat(parts, "\n")
end

return M
