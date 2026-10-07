return {
  {
    "alec-gibson/nvim-tetris",
    cmd = "Tetris",
    config = function()
      -- The board is drawn with "██" blocks; their fg colour is the background.
      -- The plugin re-applies these on every :Tetris, so patch the source table.
      local colours = require("nvim-tetris.const").colours
      colours.TetrisBackground = { guifg = "#292e42", ctermfg = "DarkGray" }
      colours.TetrisHeader = { guifg = "#7aa2f7", ctermfg = "Blue" }
    end,
  },

  {
    "tamton-aquib/zone.nvim",
    event = "VeryLazy",
    config = function()
      require("zone").setup {
        style = "treadmill",
        after = 30, -- seconds idle before the screensaver starts
        exclude_filetypes = { "TelescopePrompt", "NvimTree", "snacks_dashboard", "lazy", "oil", "tetris" },
      }
    end,
  },
}
