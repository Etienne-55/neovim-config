return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      -- Your existing opts here
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      
      -- Quick toggle for CopilotChat window
      vim.keymap.set("n", "<leader>cc", function()
        require("CopilotChat").toggle()
      end, { desc = "Toggle CopilotChat" })
      
      -- Toggle autocomplete (GitHub Copilot suggestions)
      vim.keymap.set("n", "<leader>ca", function()
        if vim.g.copilot_enabled == nil or vim.g.copilot_enabled == 1 then
          vim.cmd("Copilot disable")
          vim.g.copilot_enabled = 0
          print("Copilot autocomplete disabled")
        else
          vim.cmd("Copilot enable")
          vim.g.copilot_enabled = 1
          print("Copilot autocomplete enabled")
        end
      end, { desc = "Toggle Copilot autocomplete" })
      
      -- Alternative: More explicit toggle with status checking
      vim.keymap.set("n", "<leader>ct", function()
        vim.cmd("Copilot status")
      end, { desc = "Check Copilot status" })
    end,
  },
}
