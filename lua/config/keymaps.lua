-- All keymaps in one place

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
  vim.cmd("%d")         -- delete all lines
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

vim.keymap.set("n", "<leader>ks", function()
	os.execute("taskkill /IM node.exe /F")
end, { desc = "Kill all Node.js processes (e.g., live-server)" })


vim.keymap.set("n", "<leader>tp", function()
  local file_dir = vim.fn.expand("%:p:h")
  local cmd = string.format('wt -w 0 sp -p "PowerShell" -d "%s"', file_dir)
  os.execute(cmd)
end, { desc = "Open PowerShell 7 vertical split pane in Windows Terminal" })
