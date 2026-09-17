-- Reload buffers changed on disk (e.g. by Claude in the terminal split).
-- FocusGained never fires for edits made from a terminal inside nvim, so poll too.
vim.opt.autoread = true

local group = vim.api.nvim_create_augroup("eti_autoreload", { clear = true })

local function checktime()
  if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
    vim.cmd("silent! checktime")
  end
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "WinEnter", "TermLeave", "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = checktime,
})

-- poll every second so a buffer you're only looking at updates while Claude works
local timer = vim.uv.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(checktime))

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO)
  end,
})
