return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  init = function()
    local ensure_installed = {
      "elixir",
      "terraform",
      "glimmer",
      "go",
      "gomod",
      "gosum",
      "python",
      "json",
      "javascript",
      "typescript",
      "tsx",
      "helm",
      "yaml",
      "html",
      "css",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "query",
      "vimdoc",
      "c",
    }

    vim.api.nvim_create_autocmd("PackChanged", {
      callback = function()
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
      end,
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

    local ensure_installed = {
      "elixir", "terraform", "glimmer", "go", "gomod", "gosum",
      "python", "json", "javascript", "typescript", "tsx", "helm",
      "yaml", "html", "css", "prisma", "markdown", "markdown_inline",
      "svelte", "graphql", "bash", "lua", "vim", "dockerfile",
      "query", "vimdoc", "c",
    }

    local installed = require("nvim-treesitter.config").get_installed()
    local to_install = vim.iter(ensure_installed)
      :filter(function(p)
        return not vim.tbl_contains(installed, p)
      end)
      :totable()
    if #to_install > 0 then
      require("nvim-treesitter").install(to_install)
    end
  end,
}
