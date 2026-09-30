return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    search = {
      -- defaults (a list here replaces them) plus the Claude terminal: no labels in it
      -- unless it's the window being searched, which flash always keeps
      exclude = {
        "notify",
        "cmp_menu",
        "noice",
        "flash_prompt",
        "snacks_terminal",
        function(win) return not vim.api.nvim_win_get_config(win).focusable end,
      },
    },
    modes = {
      search = {
        enabled = true,
      },
      -- char mode hijacks f/F/t/T by default; disable to keep native motions
      char = {
        enabled = false,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "z", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
