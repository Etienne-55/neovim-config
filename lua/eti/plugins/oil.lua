return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false, -- needed so oil can take over directory buffers (e.g. `nvim .`)
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      watch_for_changes = true,
      keymaps = {
        ["q"] = { "actions.close", mode = "n" },
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == ".DS_Store" or name == ".."
        end,
      },
      float = {
        padding = 4,
        max_width = 100,
        max_height = 30,
      },
    })

    vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory (oil)" })
    vim.keymap.set("n", "<leader>-", function() require("oil").toggle_float() end, { desc = "Toggle oil in float" })
  end,
}
