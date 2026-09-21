return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>mp",
      function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
        -- save so linters see updated file on disk → diagnostics refresh
        vim.cmd("silent! write")
      end,
      mode = { "n", "v" },
      desc = "Format file or range (in visual mode)",
    },
  },
  config = function()
    local conform = require("conform")

    local function has_biome(ctx)
      return vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, path = ctx.dirname })[1] ~= nil
    end

    local function js_formatters(bufnr)
      local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      if has_biome({ dirname = dirname }) then
        return { "biome-check" }
      end
      return { "prettier" }
    end

    conform.setup({
      timeout_ms = 2000,
      formatters_by_ft = {
        javascript = js_formatters,
        typescript = js_formatters,
        javascriptreact = js_formatters,
        typescriptreact = js_formatters,
        svelte = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = js_formatters,
        jsonc = js_formatters,
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format" },
      },
      -- format_on_save = {
      --   lsp_fallback = false,
      --   async = false,
      --   timeout_ms = 1000,
      -- },
    })
  end,
}
