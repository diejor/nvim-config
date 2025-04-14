vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pt", vim.cmd.Ex)

vim.keymap.set("n", "<leader>co", ':Vex $HOME/.config/nvim<CR>') 

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("v", "y", '"+y')

vim.keymap.set("n", "<leader>/", function()
  local count = vim.v.count
  vim.cmd.norm((count > 0 and count or "") .. "gcc")
end, { desc = "Toggle line comment" })

vim.keymap.set("v", "<leader>/", function()
  local count = vim.v.count
  vim.cmd.norm((count > 0 and count or "") .. "gc")
end, { desc = "Toggle comment (visual)" })

vim.keymap.set("o", "<leader>/", function()
  local count = vim.v.count
  vim.cmd.norm((count > 0 and count or "") .. "gc")
end, { desc = "Toggle comment (operator-pending)" })

vim.keymap.set("x", "<leader>/", function()
  local count = vim.v.count
  vim.cmd.norm((count > 0 and count or "") .. "gc")
end, { desc = "Toggle comment (visual)" })
