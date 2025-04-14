vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.shortmess:append("c")

local function tab_complete()
  if vim.fn.pumvisible() == 1 then return "<Down>" end
  local col = vim.fn.col(".") - 1
  local is_whitespace = (col == 0) or vim.fn.getline("."):sub(col, col):match("%s")
  if is_whitespace then return "<Tab>" end
  if vim.bo.omnifunc == "v:lua.vim.lsp.omnifunc" then return "<C-x><C-o>" end
  return "<C-x><C-n>"
end

local function tab_prev() if vim.fn.pumvisible() == 1 then return "<Up>" else return "<Tab>" end end

vim.keymap.set("i", "<Tab>", tab_complete, { expr = true })
vim.keymap.set("i", "<S-Tab>", tab_prev, { expr = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, remap = false }
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
    vim.keymap.set("n", "<leader>vws", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", opts)
    vim.keymap.set("n", "<leader>vd", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
    vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
    vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
    vim.keymap.set("n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
    vim.keymap.set("n", "<leader>vrr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
    vim.keymap.set("n", "<leader>vrn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    vim.keymap.set("i", "<C-h>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    vim.keymap.set("n", "<leader>ff", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
  end,
})

