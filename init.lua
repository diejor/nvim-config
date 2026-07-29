-- Leader must be set before lazy.nvim loads, so that plugin `keys` specs
-- resolve against the right prefix.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
