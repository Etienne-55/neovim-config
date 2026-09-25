-- Runs a ClaudeCode command and starts typing if it left us in Claude (auto_insert is off
-- below, so opening wouldn't enter terminal mode by itself). Toggling it closed does nothing.
local function open_claude(cmd)
  return function()
    vim.cmd(cmd)
    local buf = require("claudecode.terminal").get_active_terminal_bufnr()
    if buf and vim.api.nvim_get_current_buf() == buf then
      vim.cmd.startinsert()
    end
  end
end

-- Sends keys or a slash command into the running Claude session and focuses it,
-- so model / effort / sandbox can be changed without restarting the conversation.
local function send_to_claude(text, submit)
  local terminal = require("claudecode.terminal")
  local buf = terminal.get_active_terminal_bufnr()
  if not buf then
    vim.notify("Claude isn't running, <leader>cc to start it", vim.log.levels.WARN)
    return
  end
  terminal.send_to_terminal(text, { submit = submit, focus = true })
  if vim.api.nvim_get_current_buf() == buf then
    vim.cmd.startinsert() -- the picker / command needs keys even if Claude was left in normal mode
  end
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel" },
  opts = function()
    local claude = vim.fn.exepath("claude")
    if claude == "" then
      claude = vim.fn.expand("~/.local/bin/claude") -- native installer location
    end

    return {
      terminal_cmd = claude,
      -- Claude's fullscreen mode draws on the alternate screen, which leaves the nvim
      -- terminal buffer without scrollback; the classic renderer keeps j/k scrolling working.
      -- It redraws relative to the last frame, so the pane width must never change (see wo).
      env = { CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN = "1" },
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.35,
        -- Snacks re-enters terminal mode on every BufEnter, which throws away the scroll
        -- position / selection you left Claude at. on_buf below brings back whichever
        -- mode you left in instead.
        auto_insert = false,
        -- Keys for when the cursor is inside Claude, where the <leader> maps below
        -- don't apply. Model, thinking and permission mode already have Option+P,
        -- Option+T and Shift+Tab in Claude itself.
        snacks_win_opts = {
          -- Keep the pty size fixed across hide/show: no inherited gutter (shifts the width),
          -- and no Snacks winbar, which the re-shown split only gets after the buffer is set,
          -- so the height blips by a row and the prompt box is redrawn one line off.
          -- No cursorline either, it highlights a line that isn't Claude's input.
          wo = { number = false, relativenumber = false, signcolumn = "no", cursorline = false, winbar = "" },
          on_buf = function(self)
            local buf = self.buf
            vim.b[buf].claude_insert = true -- a fresh session starts out typing
            vim.api.nvim_create_autocmd("BufLeave", {
              buffer = buf,
              callback = function() vim.b[buf].claude_insert = vim.fn.mode() == "t" end,
            })
            vim.api.nvim_create_autocmd("BufEnter", {
              buffer = buf,
              callback = function()
                -- Snacks enters the buffer before the job starts; open_claude handles that case
                if vim.b[buf].claude_insert and vim.bo[buf].buftype == "terminal" then
                  vim.cmd.startinsert()
                end
              end,
            })
          end,
          keys = {
            term_normal = false, -- let Esc / Esc Esc reach Claude (cancel, rewind); <C-\><C-n> still works
            claude_hide = { "<C-q>", function(self) self:hide() end, mode = "t", desc = "Hide Claude" },
            -- <C-\><C-n> gets eaten by vim-tmux-navigator's tmux binding, so jump left directly.
            -- Flag set after the jump: left while typing, so come back typing.
            claude_left = { "<C-h>", function(self)
              vim.cmd.stopinsert()
              vim.cmd.wincmd("h")
              vim.b[self.buf].claude_insert = true
            end, mode = "t", desc = "Go to left window" },
            -- same problem for scrolling: normal mode to scroll/search/yank, i to type again
            claude_normal = { "<C-n>", function() vim.cmd.stopinsert() end, mode = "t", desc = "Normal mode (scroll)" },
            claude_sandbox = { "<M-s>", function() send_to_claude("/sandbox", true) end, mode = "t", desc = "Claude sandbox" },
            claude_effort = { "<M-e>", function() send_to_claude("/effort", true) end, mode = "t", desc = "Claude effort" },
          },
        },
      },
    }
  end,
  keys = {
    { "<leader>c", nil, desc = "Claude Code" },
    { "<leader>cc", open_claude("ClaudeCode"), desc = "Toggle Claude" },
    { "<leader>cf", open_claude("ClaudeCodeFocus"), desc = "Focus Claude" },
    { "<leader>cC", open_claude("ClaudeCode --continue"), desc = "Continue last conversation" },
    { "<leader>cr", open_claude("ClaudeCode --resume"), desc = "Resume a conversation" },
    { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
    { "<leader>cb", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    { "<leader>cb", "<cmd>ClaudeCodeTreeAdd<cr>", ft = "NvimTree", desc = "Add file to Claude" },
    { "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
    { "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude diff" },

    -- quick toggles inside the running session
    { "<leader>cm", function() send_to_claude("\27p", false) end, desc = "Claude model (←/→ effort)" },
    { "<leader>ce", function() send_to_claude("/effort", true) end, desc = "Claude effort" },
    { "<leader>cs", function() send_to_claude("/sandbox", true) end, desc = "Claude sandbox" },
    { "<leader>ct", function() send_to_claude("\27t", false) end, desc = "Claude thinking on/off" },
    { "<leader>cp", function() send_to_claude("\27[Z", false) end, desc = "Claude next permission mode" },
  },
}
