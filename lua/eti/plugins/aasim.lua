return {
  'Aasim-A/scrollEOF.nvim',
  event = { 'CursorMoved', 'WinScrolled' },
  opts = {
    -- Number of lines to show after EOF
    pattern = '*', -- Apply to all filetypes
    insert_mode = false, -- Disable in insert mode
  },
}
