local M = {}

local data_dir = vim.fn.stdpath("data") .. "/review-lite"

local function git(cmd)
  local h = io.popen(cmd .. " 2>/dev/null")
  if not h then return nil end
  local out = h:read("*a")
  h:close()
  if not out or out == "" then return nil end
  return (out:gsub("%s+$", ""))
end

local function hash(str)
  local h = 0
  for i = 1, #str do h = ((h * 31) + string.byte(str, i)) % 2147483647 end
  return string.format("%x", h)
end

function M.git_root() return git("git rev-parse --show-toplevel") end

local function storage_path()
  local root = M.git_root()
  if not root then return nil end
  local branch = git("git rev-parse --abbrev-ref HEAD") or "detached"
  local safe = branch:gsub("[^%w%-_]", "_")
  pcall(vim.fn.mkdir, data_dir, "p")
  return string.format("%s/%s-%s.json", data_dir, hash(root), safe)
end

function M.load()
  local p = storage_path()
  if not p then return {} end
  local f = io.open(p, "r")
  if not f then return {} end
  local raw = f:read("*a"); f:close()
  if not raw or raw == "" then return {} end
  local ok, data = pcall(vim.fn.json_decode, raw)
  return (ok and data) or {}
end

function M.save(data)
  local p = storage_path()
  if not p then return end
  local f = io.open(p, "w")
  if not f then return end
  f:write(vim.fn.json_encode(data))
  f:close()
end

function M.clear()
  local p = storage_path()
  if p then os.remove(p) end
end

return M
