local augroup = vim.api.nvim_create_augroup("diejor", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "Highlight yanked text",
    callback = function()
        vim.hl.on_yank()
    end,
})

-- BufReadCmd claims the read, so no binary buffer is ever created.
vim.api.nvim_create_autocmd("BufReadCmd", {
    group = augroup,
    pattern = "*.pdf",
    desc = "Open PDFs in zathura",
    callback = function(args)
        vim.fn.jobstart({ "zathura", args.file }, { detach = true })
        vim.schedule(function()
            vim.api.nvim_buf_delete(args.buf, { force = true })
        end)
    end,
})
