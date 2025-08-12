return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = false, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    -- Make messages disappear faster and appear smaller
    views = {
      mini = {
        size = {
          width = "auto",
          height = "auto",
          max_height = 3, -- Limit height to 3 lines
          max_width = 60, -- Limit width to 60 characters
        },
        timeout = 500, -- Messages disappear after 2 seconds (default is 4000)
        position = {
          row = -2, -- Position from bottom
          col = "100%", -- Right side
        },
      },
      notify = {
        timeout = 500, -- Notifications disappear after 2 seconds
        size = {
          max_height = 5, -- Smaller notification height
          max_width = 80, -- Smaller notification width
        },
      },
      cmdline_popup = {
        size = {
          width = 60, -- Smaller command line popup
          height = "auto",
        },
      },
    },
    -- Configure message routing to make them less intrusive
    routes = {
      -- Hide "written" messages
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
      -- Hide search count messages like "1 of 5"
      {
        filter = {
          event = "msg_show",
          kind = "search_count",
        },
        opts = { skip = true },
      },
      -- Route LSP progress to mini view (smaller)
      {
        filter = {
          event = "lsp",
          kind = "progress",
        },
        view = "mini",
      },
      -- Make other messages use mini view by default
      {
        filter = {
          event = "msg_show",
          min_height = 1,
        },
        view = "mini",
      },
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  }
}
