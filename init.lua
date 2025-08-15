require("eti.core")
require("eti.lazy")

-- neovim
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')

vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- obsidian
vim.opt.conceallevel = 2

-- zen mode 
vim.keymap.set("n", "<Space>zz", function()
  require("zen-mode").toggle()
end, { desc = "Toggle Zen Mode" })

-- treesitter
vim.keymap.set('n', '<Space>T', vim.treesitter.inspect_tree, { 
desc = 'Inspect Treesitter tree' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { 
desc = 'Clear search highlighting' })
