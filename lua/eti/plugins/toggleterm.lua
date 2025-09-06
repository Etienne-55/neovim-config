return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
  },
  config = function()
    require("toggleterm").setup()
    
    -- Make <leader>tt work from terminal mode
    vim.keymap.set('t', '<leader>tt', '<cmd>ToggleTerm<cr>', { desc = "Toggle Terminal" })
  end,
}
