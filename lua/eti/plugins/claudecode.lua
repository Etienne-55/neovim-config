-- Sends keys or a slash command into the running Claude session and focuses it,
-- so model / effort / sandbox can be changed without restarting the conversation.
local function send_to_claude(text, submit)
  local terminal = require("claudecode.terminal")
  if not terminal.get_active_terminal_bufnr() then
    vim.notify("Claude isn't running, <leader>cc to start it", vim.log.levels.WARN)
    return
  end
  terminal.send_to_terminal(text, { submit = submit, focus = true })
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
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.35,
        -- Keys for when the cursor is inside Claude, where the <leader> maps below
        -- don't apply. Model, thinking and permission mode already have Option+P,
        -- Option+T and Shift+Tab in Claude itself.
        snacks_win_opts = {
          keys = {
            term_normal = false, -- let Esc / Esc Esc reach Claude (cancel, rewind); <C-\><C-n> still works
            claude_hide = { "<C-q>", function(self) self:hide() end, mode = "t", desc = "Hide Claude" },
            claude_sandbox = { "<M-s>", function() send_to_claude("/sandbox", true) end, mode = "t", desc = "Claude sandbox" },
            claude_effort = { "<M-e>", function() send_to_claude("/effort", true) end, mode = "t", desc = "Claude effort" },
          },
        },
      },
    }
  end,
  keys = {
    { "<leader>c", nil, desc = "Claude Code" },
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last conversation" },
    { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume a conversation" },
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
