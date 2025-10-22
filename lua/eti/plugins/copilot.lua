return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = 'claude-sonnet-4.5',
      -- Your existing opts here
      --
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      
      -- Quick toggle for CopilotChat window
      vim.keymap.set("n", "<leader>cc", function()
        require("CopilotChat").toggle()
      end, { desc = "Toggle CopilotChat" })
    end,
  },
}

