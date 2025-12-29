-- All keymaps in one place
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Custom text object keymaps
vim.keymap.set("n", "t", function()
	local char = vim.fn.getcharstr()
	vim.cmd("normal! v")
	vim.cmd("normal! t" .. char)
end, { noremap = true })

vim.keymap.set("n", "T", function()
	local char = vim.fn.getcharstr()
	vim.cmd("normal! vT" .. char)
end, { noremap = true })

-- Clipboard keymaps
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to clipboard" })
vim.keymap.set("n", "<leader>y", ":%y+<CR>", { desc = "Yank entire buffer to clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste over selection from clipboard" })

-- Replace entire buffer with clipboard contents
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("%d") -- delete all lines
	vim.cmd('normal! "+P') -- paste clipboard
end, { desc = "Replace entire file with clipboard contents" })

-- Insert mode navigation
vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", { noremap = true, silent = true })
-- Development server keymaps
vim.keymap.set("n", "<leader>s", function()
	os.execute('tasklist | findstr /I "live-server" || start cmd /c live-server')
end)

-- LSP and formatting keymaps (global)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })


vim.keymap.set("n", "<leader>tp", function()
  local file_dir = vim.fn.expand("%:p:h")
  local cmd = string.format('wt -w 0 sp -H -p "PowerShell" -d "%s"', file_dir)
  os.execute(cmd)
end, { desc = "Open PowerShell 7 horizontal split pane in Windows Terminal" })

vim.keymap.set("n", "<leader>sr", function()
	local old = vim.fn.input("Find: ")
	if old == "" then
		return
	end
	local new = vim.fn.input("Replace with: ")

	-- File types to search
	local file_pattern = "**/*.{html,css,js,ts}"
	local files = vim.fn.glob(file_pattern, 0, 1)

	local filtered_files = {}
	for _, f in ipairs(files) do
		if not f:match("node_modules") and not f:match("/%.") then
			table.insert(filtered_files, f)
		end
	end

	if #filtered_files == 0 then
		print("No files found to replace text in.")
		return
	end

	-- Process each file individually
	local count = 0
	for _, file in ipairs(filtered_files) do
		vim.cmd("edit " .. file)
		-- Use a different separator to avoid conflicts
		local result = vim.fn.search(old)
		if result > 0 then
			vim.cmd("silent! %substitute#" .. vim.fn.escape(old, "#\\") .. "#" .. vim.fn.escape(new, "#\\") .. "#ge")
			vim.cmd("update")
			count = count + 1
		end
	end

	print("Replacement complete in " .. count .. " files.")
end, { desc = "Search & replace across project (HTML/CSS/JS)" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<leader>w", "<C-w>w", { desc = "Cycle through windows" })

-- Enable / Disable / Toggle
vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", {
	desc = "Enable Copilot",
	silent = true,
})
vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", {
	desc = "Disable Copilot",
	silent = true,
})
vim.keymap.set("n", "<leader>ct", function()
	if vim.g.copilot_enabled == false then
		vim.cmd("Copilot enable")
		print("Copilot enabled")
	else
		vim.cmd("Copilot disable")
		print("Copilot disabled")
	end
end, {
	desc = "Toggle Copilot",
	silent = true,
})
