local ensure_installed = {
  "elixir", "terraform", "glimmer", "go", "gomod", "gosum",
  "python", "json", "javascript", "typescript", "tsx", "helm",
  "yaml", "html", "css", "prisma", "markdown", "markdown_inline",
  "svelte", "graphql", "bash", "lua", "vim", "dockerfile",
  "query", "vimdoc", "c",
}

local function install_missing()
  local ok, ts = pcall(require, "nvim-treesitter")
  if not ok then
    return
  end
  local installed = require("nvim-treesitter.config").get_installed()
  local to_install = vim.iter(ensure_installed)
    :filter(function(p)
      return not vim.tbl_contains(installed, p)
    end)
    :totable()
  if #to_install > 0 then
    ts.install(to_install)
  end
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  init = function()
    vim.api.nvim_create_autocmd("PackChanged", {
      callback = install_missing,
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
  config = function()
    require("nvim-treesitter").setup()
    install_missing()
  end,
}
