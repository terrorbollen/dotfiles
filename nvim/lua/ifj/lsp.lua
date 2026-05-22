vim.lsp.document_color.enable(false)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local function opts(desc)
      return { buffer = ev.buf, silent = true, desc = desc }
    end


    vim.keymap.set("n", "gR", function() Snacks.picker.lsp_references() end, opts("Show LSP references"))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
    vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, opts("Show LSP definitions"))
    vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, opts("Show LSP implementations"))
    vim.keymap.set("n", "<leader>gt", function() Snacks.picker.lsp_type_definitions() end, opts("Show LSP type definitions"))
    vim.keymap.set("n", "<leader>ci", function() Snacks.picker.lsp_incoming_calls() end, opts("Show incoming calls"))
    vim.keymap.set("n", "<leader>co", function() Snacks.picker.lsp_outgoing_calls() end, opts("Show outgoing calls"))
    vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts("See available code actions"))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Smart rename"))
    vim.keymap.set("n", "<leader>D", function() Snacks.picker.diagnostics_buffer() end, opts("Show buffer diagnostics"))
    vim.keymap.set("n", "<leader>W", function() Snacks.picker.diagnostics() end, opts("Show workspace diagnostics"))
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts("Show line diagnostics"))

    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts("Go to previous diagnostic"))

    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts("Go to next diagnostic"))

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Show documentation for what is under cursor"))
    vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts("Restart LSP"))

    vim.keymap.set("n", "gv", function()
      vim.cmd("vsplit")
      vim.lsp.buf.definition()
    end, opts("Go to definition in vertical split"))

    vim.keymap.set("n", "gh", function()
      vim.cmd("split")
      vim.lsp.buf.definition()
    end, opts("Go to definition in horizontal split"))
  end,
})

local severity = vim.diagnostic.severity

vim.diagnostic.config({
  virtual_lines = false,
  virtual_text = {
    severity = { min = severity.ERROR },
    prefix = "●",
    format = function(diagnostic)
      local msg = diagnostic.message
      if #msg > 60 then
        return msg:sub(1, 57) .. "…"
      end
      return msg
    end,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [severity.ERROR] = "󰅚 ",
      [severity.WARN] = "󰀪 ",
      [severity.INFO] = "󰋽 ",
      [severity.HINT] = "󰌶 ",
    },
    numhl = {
      [severity.ERROR] = "ErrorMsg",
      [severity.WARN] = "WarningMsg",
    },
  },
})

-- muted virtual text: dimmed red fg, no background
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#6e3535", italic = true })
  end,
})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#6e3535", italic = true })
