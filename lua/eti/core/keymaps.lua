vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- registers: only visual d (and y) copy; normal-mode d/D delete into the black hole
keymap.set("n", "d", '"_d') -- dd, dw, d$... don't overwrite the clipboard
keymap.set("n", "D", '"_D')

-- move selected lines; in read-only buffers (Claude terminal, help...) keep the native
-- key, so selecting with J / K before a yank still works there
local function move_lines(key, cmd)
  keymap.set("x", key, function() return vim.bo.modifiable and cmd or key end, { expr = true, silent = true })
end
move_lines("J", ":m '>+1<CR>gv=gv") -- move selected lines down
move_lines("K", ":m '<-2<CR>gv=gv") -- move selected lines up
move_lines("<M-Down>", ":m '>+1<CR>gv=gv") -- same, with alt+arrows (plain arrows extend the selection)
move_lines("<M-Up>", ":m '<-2<CR>gv=gv")


-- half-page scroll keeps the cursor centered on screen
keymap.set({ "n", "x" }, "<C-d>", "<C-d>zz")
keymap.set({ "n", "x" }, "<C-u>", "<C-u>zz")
keymap.set({ "n", "x" }, "<C-Down>", "<C-d>zz") -- same, with ctrl+arrows
keymap.set({ "n", "x" }, "<C-Up>", "<C-u>zz")
-- alt+arrows too, but only in normal mode: in visual mode they move the selected lines (above)
keymap.set("n", "<M-Down>", "<C-d>zz")
keymap.set("n", "<M-Up>", "<C-u>zz")
-- page keys (fn+arrows on a mac, shift+arrows) would leave the cursor on the
-- top/bottom line; make them the same centered half-page scroll
for _, key in ipairs({ "<PageDown>", "<S-Down>" }) do
  keymap.set({ "n", "x" }, key, "<C-d>zz")
end
for _, key in ipairs({ "<PageUp>", "<S-Up>" }) do
  keymap.set({ "n", "x" }, key, "<C-u>zz")
end

-- search: keep the match centered; <Esc> clears the highlight
keymap.set("n", "n", "nzz")
keymap.set("n", "N", "Nzz")
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

keymap.set("n", "<leader>T", vim.treesitter.inspect_tree, { desc = "Inspect Treesitter tree" })
