-- The `main` branch is the current rewrite; `master` is frozen upstream.
-- Parsers are installed by nvim-treesitter, highlighting is started by Neovim.
local ensure_installed = {
    "c", "cpp", "rust", "lua", "python", "javascript", "typescript", "tsx",
    "latex", "bibtex", "json", "toml", "yaml", "markdown",
    "markdown_inline", "bash", "fish", "vim", "vimdoc", "query", "diff",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("nvim-treesitter").setup({})

        local installed = require("nvim-treesitter.config").get_installed("parsers")
        local missing = vim.tbl_filter(function(lang)
            return not vim.tbl_contains(installed, lang)
        end, ensure_installed)
        if #missing > 0 then
            require("nvim-treesitter").install(missing)
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("diejor_treesitter", { clear = true }),
            desc = "Start treesitter highlighting and indent",
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if not (lang and vim.treesitter.language.add(lang)) then
                    return
                end
                vim.treesitter.start(args.buf, lang)
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
