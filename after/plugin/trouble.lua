vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  {silent = true, noremap = true}
)

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

