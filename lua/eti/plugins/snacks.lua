return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true }, -- nicer vim.ui.input (replaces dressing.nvim)
    picker = { enabled = true, ui_select = true }, -- nicer vim.ui.select (replaces dressing.nvim)
    lazygit = { enabled = true }, -- floating lazygit window
  },
  keys = {
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Open lazygit" },
    { "<leader>rf", function() Snacks.rename.rename_file() end, desc = "Rename current file (LSP-aware)" },
    { "<leader>tn", function() Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle() end, desc = "Toggle relative line numbers" },
    {
      "<leader>rw",
      function()
        local word, whole
        if vim.fn.mode():match("[vV]") then
          vim.cmd('noautocmd normal! "vy')
          word, whole = vim.fn.getreg("v"), false
        else
          word, whole = vim.fn.expand("<cword>"), true
        end
        if word == "" then return end
        vim.ui.input({ prompt = "Replace '" .. word .. "' with: ", default = word }, function(repl)
          if not repl or repl == word then return end
          local pat = "\\V" .. vim.fn.escape(word, "\\/"):gsub("\n", "\\n")
          if whole then pat = "\\V\\<" .. pat:sub(3) .. "\\>" end
          local view = vim.fn.winsaveview()
          vim.cmd("keeppatterns %s/" .. pat .. "/" .. vim.fn.escape(repl, "\\/&~") .. "/ge")
          vim.fn.winrestview(view)
        end)
      end,
      mode = { "n", "x" },
      desc = "Replace word/selection in file",
    },
  },
}
