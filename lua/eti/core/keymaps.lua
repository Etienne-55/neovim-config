vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- registers: only visual d (and y) copy; normal-mode d/D delete into the black hole
keymap.set("n", "d", '"_d') -- dd, dw, d$... don't overwrite the clipboard
keymap.set("n", "D", '"_D')

-- move selected lines; in read-only buffers (Claude terminal, help...) keep the native
-- key, so selecting with arrows / J / K before a yank still works there
local function move_lines(key, cmd)
  keymap.set("x", key, function() return vim.bo.modifiable and cmd or key end, { expr = true })
end
move_lines("J", ":m '>+1<CR>gv=gv") -- move selected lines down
move_lines("K", ":m '<-2<CR>gv=gv") -- move selected lines up
move_lines("<Down>", ":m '>+1<CR>gv=gv") -- same, with arrows
move_lines("<Up>", ":m '<-2<CR>gv=gv")

