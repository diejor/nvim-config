local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = true

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"

opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.scrolloff = 8
-- Always reserved, so text doesn't shift when diagnostics appear.
opt.signcolumn = "yes"
opt.colorcolumn = "80"

opt.splitright = true
opt.splitbelow = true

opt.updatetime = 50
opt.isfname:append("@-@")

opt.background = "dark"

-- Builtin scheme that follows the terminal palette.
vim.cmd.colorscheme("lunaperche")
