return {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
        vim.g.copilot_no_tab_map = true
    end,
    config = function()
        vim.keymap.set("i", "<C-l>", 'copilot#Accept("")', {
            expr = true,
            replace_keycodes = false,
            desc = "Copilot accept",
        })
        vim.keymap.set("i", "<C-;>", "<Plug>(copilot-accept-word)", { desc = "Copilot accept word" })
    end,
}
