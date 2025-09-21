return {
  "mfussenegger/nvim-dap",
  dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
  {
    "mxsdev/nvim-dap-vscode-js",
  },
  config = function()


    local dap = require("dap")
    local dapui = require("dapui")

    vim.keymap.set("n", "<leader>b", "<CMD>DapToggleBreakpoint<CR>", { desc = "Toogle breakpoint" })
    vim.keymap.set("n", "<leader>dn", dap.continue, { desc = "Dap continue" })

    require("dap").setup({})
    require("dapui").setup({})

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end


    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        -- 💀 Make sure to update this path to point to your installation
        args = { "~/Downloads/vscode-js-debug-1.104.0/src/dapDebugServer.ts", "${port}" },
      },
    }
    dap.configurations.typescriptreact = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    }
  end,
}
