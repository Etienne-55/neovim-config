-- Transparently decrypt/encrypt *.gpg, *.pgp and *.asc files via the system gpg.
-- Disables swap, undofile, shada and backups for those buffers so plaintext never hits disk.
-- For PGP text in any other buffer (e.g. a .txt), use <leader>pd / :PgpDecrypt.
local function decrypt(lines)
	local res = vim.system({ "gpg", "--decrypt" }, { stdin = table.concat(lines, "\n") .. "\n" }):wait()
	if res.code ~= 0 then
		vim.notify("gpg failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
		return
	end

	-- show plaintext in a throwaway buffer that is never written, swapped or undo-saved
	vim.cmd("botright new")
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].undofile = false
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout, "\n", { trimempty = true }))
	vim.bo[buf].modified = false
	vim.api.nvim_buf_set_name(buf, "[gpg decrypted " .. buf .. "]")
	vim.notify(vim.trim(res.stderr or ""), vim.log.levels.INFO) -- signature / key info
end

return {
	"jamessan/vim-gnupg",
	-- must be loaded before the file is read (it hooks BufReadCmd), so no lazy-loading
	lazy = false,
	init = function()
		vim.g.GPGPreferArmor = 1 -- write ASCII-armored output when re-encrypting
		vim.g.GPGPreferSign = 1 -- sign when re-encrypting
		vim.g.GPGUsePipes = 1 -- pass data to gpg via pipes, not temp files
	end,
	config = function()
		vim.api.nvim_create_user_command("PgpDecrypt", function(opts)
			decrypt(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false))
		end, { range = "%", desc = "Decrypt PGP text into a scratch buffer" })

		vim.keymap.set("n", "<leader>pd", "<cmd>PgpDecrypt<cr>", { desc = "PGP decrypt buffer" })
		vim.keymap.set("x", "<leader>pd", ":PgpDecrypt<cr>", { desc = "PGP decrypt selection" })
	end,
}
