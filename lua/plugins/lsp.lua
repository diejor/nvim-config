-- Settings live in lsp/<name>.lua, which Neovim reads off the runtimepath and
-- merges over nvim-lspconfig's defaults.
local servers = { "lua_ls", "clangd", "ts_ls", "ltex" }

return {
    {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
        opts = {},
        keys = {
            { "<leader>M", "<cmd>Mason<cr>", desc = "Mason" },
        },
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            -- Applies to every server; blink does not register these itself.
            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
            })

            require("mason-lspconfig").setup({
                ensure_installed = servers,
                -- Otherwise it enables every installed server, including
                -- rust_analyzer, which conflicts with rustaceanvim.
                automatic_enable = false,
            })

            vim.lsp.enable(servers)

            -- Extras only; K, grn, gra, grr, gri and gO are Neovim built-ins.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("diejor_lsp", { clear = true }),
                callback = function(args)
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
                    end
                    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "Workspace symbol")
                    map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action")
                    map("n", "<leader>vrr", vim.lsp.buf.references, "References")
                    map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename")
                    map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")
                end,
            })

            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                signs = true,
                underline = true,
                severity_sort = true,
                float = { border = "rounded", source = true },
            })
        end,
    },
}
