return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "jay-babu/mason-nvim-dap.nvim",
        },
        keys = {
            { "<F5>",       function() require("dap").continue() end,          desc = "Debug: continue" },
            { "<F10>",      function() require("dap").step_over() end,         desc = "Debug: step over" },
            { "<F11>",      function() require("dap").step_into() end,         desc = "Debug: step into" },
            { "<F12>",      function() require("dap").step_out() end,          desc = "Debug: step out" },
            { "<leader>b",  function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Debug: conditional breakpoint" },
            { "<leader>dr", function() require("dap").repl.toggle() end,       desc = "Debug: REPL" },
            { "<leader>dl", function() require("dap").run_last() end,          desc = "Debug: run last" },
            { "<leader>dt", function() require("dap").terminate() end,         desc = "Debug: terminate" },
            { "<leader>du", function() require("dapui").toggle() end,          desc = "Debug: toggle UI" },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end,  desc = "Debug: hover", mode = { "n", "v" } },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            require("mason-nvim-dap").setup({
                ensure_installed = { "codelldb", "python", "js" },
                automatic_installation = true,
                handlers = {},
            })

            dapui.setup()
            require("nvim-dap-virtual-text").setup({})

            dap.listeners.after.event_initialized.dapui = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui = function() dapui.close() end
            dap.listeners.before.event_exited.dapui = function() dapui.close() end

            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

            local mason = vim.fn.expand("$MASON")

            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = mason .. "/bin/codelldb",
                    args = { "--port", "${port}" },
                },
            }

            local function pick_binary()
                return coroutine.create(function(co)
                    vim.ui.input({
                        prompt = "Path to executable: ",
                        default = vim.fn.getcwd() .. "/",
                        completion = "file",
                    }, function(path)
                        coroutine.resume(co, path)
                    end)
                end)
            end

            local codelldb_config = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = pick_binary,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }

            -- Rust configs come from rustaceanvim; these cover the C family.
            dap.configurations.c = codelldb_config
            dap.configurations.cpp = codelldb_config

            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { mason .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
                },
            }

            for _, ft in ipairs({ "javascript", "typescript" }) do
                dap.configurations[ft] = {
                    {
                        name = "Launch file",
                        type = "pwa-node",
                        request = "launch",
                        program = "${file}",
                        cwd = "${workspaceFolder}",
                    },
                    {
                        name = "Attach to process",
                        type = "pwa-node",
                        request = "attach",
                        processId = require("dap.utils").pick_process,
                        cwd = "${workspaceFolder}",
                    },
                }
            end
        end,
    },

    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = "mfussenegger/nvim-dap",
        config = function()
            require("dap-python").setup(vim.fn.expand("$MASON") .. "/packages/debugpy/venv/bin/python")
        end,
    },
}
