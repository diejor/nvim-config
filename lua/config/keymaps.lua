local map = vim.keymap.set

map("n", "<leader>pt", vim.cmd.Ex, { desc = "Open file explorer" })
map("n", "<leader>co", function()
    vim.cmd.edit(vim.fn.stdpath("config"))
end, { desc = "Open nvim config" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("v", "y", '"+y', { desc = "Yank to system clipboard" })

-- Alias for the built-in gcc/gc.
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

map("n", "<leader>vd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
