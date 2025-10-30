---@type vim.lsp.Config
return {
  on_attach = function(_, buffer)
    if vim.bo[buffer].filetype == "helm" then
      vim.schedule(function()
        vim.cmd("LspStop ++force yamlls")
      end)
    end
  end,
}
