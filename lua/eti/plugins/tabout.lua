return {
  "abecodes/tabout.nvim",
  -- loaded at startup so its global <Tab> exists before nvim-cmp captures it as the fallback
  -- (cmp's <Tab> jumps snippet placeholders first, then falls back to tabout)
  lazy = false,
  opts = {
    completion = false, -- nvim-cmp handles its own menu
  },
}
