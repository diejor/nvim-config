return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
        keys = {
            { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<C-p>",      "<cmd>Telescope git_files<cr>",  desc = "Find git files" },
            { "<leader>ps", "<cmd>Telescope live_grep<cr>",  desc = "Grep project" },
            { "<leader>pb", "<cmd>Telescope buffers<cr>",    desc = "Find buffers" },
            { "<leader>ph", "<cmd>Telescope help_tags<cr>",  desc = "Find help" },
        },
        opts = {},
    },

    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
            { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix" },
        },
        opts = { icons = false },
    },

    {
        "mbbill/undotree",
        cmd = { "UndotreeToggle", "UndotreeShow" },
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
        },
    },

    {
        "aserowy/tmux.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
