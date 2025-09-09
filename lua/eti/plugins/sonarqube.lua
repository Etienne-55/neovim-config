-- ~/.config/nvim/lua/plugins/sonarlint.lua
return {
  "https://gitlab.com/schrieveslaach/sonarlint.nvim",
  ft = { "go", "javascript", "typescript", "python", "java" }, -- only load for these filetypes
  config = function()
    -- Set JAVA_HOME for SonarLint (Apple Silicon Homebrew path)
    vim.env.JAVA_HOME = "/opt/homebrew/opt/openjdk@17"
    vim.env.PATH = "/opt/homebrew/opt/openjdk@17/bin:" .. vim.env.PATH
    
    require("sonarlint").setup({
      server = {
        cmd = {
          "/opt/homebrew/opt/openjdk@17/bin/java",
          "-jar",
          vim.fn.expand("~/.local/share/nvim/mason/packages/sonarlint-language-server/extension/server/sonarlint-ls.jar"),
          "-stdio",
          "-analyzers",
          vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonargo.jar"),
        }
      },
      filetypes = {
        go = "go",
        javascript = "js",
        typescript = "ts",
        python = "python",
        java = "java"
      }
    })
  end,
}
