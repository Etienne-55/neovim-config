-- words (incl. dashed css classes) from loaded buffers, current buffer first
local function buffer_words()
  local words, seen = {}, {}
  local bufs = vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
  table.insert(bufs, 1, vim.api.nvim_get_current_buf())
  for _, buf in ipairs(bufs) do
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      for w in line:gmatch("[%w_][%w_%-]*[%w_]") do
        if #w >= 3 and not seen[w] then
          seen[w] = true
          words[#words + 1] = w
        end
      end
    end
  end
  return words
end

-- popup with words matching what's typed in the input: prefix matches first, then substring
local function attach_suggestions(win, words, default)
  local buf, skip = win.buf, default -- skip: text we set ourselves (default, accepted item, history), not typed
  vim.bo[buf].completeopt = "menuone,noselect"
  for _, name in ipairs({ "hist_up", "hist_down" }) do
    local hist = win.opts.actions[name]
    win.opts.actions[name] = function(self)
      vim.schedule(function() -- <up>/<down> are expr maps now, which can't edit the buffer
        hist(self)
        skip = self:text()
      end)
    end
  end
  local function suggest()
    local line, col = vim.api.nvim_get_current_line(), vim.fn.col(".") - 1
    if line == skip or vim.fn.complete_info({ "selected" }).selected ~= -1 then return end
    local base = line:sub(1, col):match("[%w_%-]*$")
    local lbase, prefix, sub = base:lower(), {}, {}
    if #base > 0 then
      for _, w in ipairs(words) do
        local i = w ~= base and w:lower():find(lbase, 1, true)
        if i == 1 then prefix[#prefix + 1] = w elseif i then sub[#sub + 1] = w end
      end
    end
    vim.fn.complete(col - #base + 1, vim.list_slice(vim.list_extend(prefix, sub), 1, 50))
  end
  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, { buffer = buf, callback = suggest })
  vim.api.nvim_create_autocmd("CompleteDone", {
    buffer = buf,
    callback = function()
      if vim.v.event.reason == "accept" then skip = vim.api.nvim_get_current_line() end
    end,
  })
end

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
        local words = buffer_words()
        Snacks.input({
          prompt = "Replace '" .. word .. "' with: ",
          default = word,
          win = {
            on_buf = function(win) attach_suggestions(win, words, word) end,
            keys = {
              i_up = { "<up>", { "cmp_select_prev", "hist_up" }, mode = { "i", "n" }, expr = true },
              i_down = { "<down>", { "cmp_select_next", "hist_down" }, mode = { "i", "n" }, expr = true },
            },
          },
        }, function(repl)
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
