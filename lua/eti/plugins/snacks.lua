return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true }, -- nicer vim.ui.input (replaces dressing.nvim)
    picker = { enabled = true, ui_select = true }, -- nicer vim.ui.select (replaces dressing.nvim)
    lazygit = { enabled = true }, -- floating lazygit window
  },
  keys = {
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Open lazygit" },
  },
}
