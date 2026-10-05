return {
  -- render headings, code blocks, tables and checkboxes inside the buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      code = { width = "block", right_pad = 2 },
      heading = { sign = false },
    },
    keys = {
      {
        "<leader>mr",
        function()
          require("render-markdown").toggle()
        end,
        ft = "markdown",
        desc = "Toggle markdown rendering",
      },
    },
  },

  -- live preview in the browser, scroll-synced with the buffer
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    -- yarn isn't in the Brewfile: use it when installed, otherwise run it through npx (comes with node)
    build = "cd app && if command -v yarn >/dev/null 2>&1; then yarn install; else npx --yes yarn install; fi",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_theme = "dark"
    end,
    keys = {
      { "<leader>mv", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Toggle markdown preview in browser" },
    },
  },
}
