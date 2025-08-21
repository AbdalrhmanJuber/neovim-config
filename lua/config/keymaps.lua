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

-- Additional LSP keybindings for better access
vim.keymap.set("n", "<leader>lh", function()
	-- Show LSP help/status
	vim.notify([[
LSP Keybindings:
  gd - Go to definition
  gD - Go to declaration  
  K - Show hover info
  gi - Go to implementation
  <C-k> - Show signature help
  <leader>rn - Rename symbol
  <leader>ca - Code actions
  gr - Show references
  <leader>f - Format buffer
  
LSP Management:
  <leader>ls - Show LSP status
  <leader>lr - Restart LSP for buffer
  <leader>lR - Restart all LSP servers
  <leader>la - Attach all LSP servers
  <leader>li - Show LspInfo
  <leader>lI - Show Mason
  
Advanced Debugging:
  <leader>ld - Diagnose LSP issues
  <leader>lc - Check server installation
  <leader>lt - Create test TypeScript project
  <leader>lrt - Reinstall TypeScript server
  <leader>lre - Reinstall ESLint server
]], vim.log.levels.INFO)
end, { desc = "Show LSP help" })

-- Advanced LSP debugging utilities
vim.keymap.set("n", "<leader>ld", function()
	local debug = require("lsp-debug")
	debug.diagnose_attachment_issues()
end, { desc = "Diagnose LSP attachment issues" })

vim.keymap.set("n", "<leader>lc", function()
	local debug = require("lsp-debug")
	debug.check_server_installation()
end, { desc = "Check LSP server installation status" })

vim.keymap.set("n", "<leader>lt", function()
	local debug = require("lsp-debug")
	local test_dir = debug.create_test_project()
	vim.cmd("edit " .. test_dir .. "/test.ts")
end, { desc = "Create test TypeScript project" })

-- Quick server reinstall for common problematic cases
vim.keymap.set("n", "<leader>lrt", function()
	local debug = require("lsp-debug")
	debug.reinstall_server("ts_ls")
end, { desc = "Reinstall TypeScript server" })

vim.keymap.set("n", "<leader>lre", function()
	local debug = require("lsp-debug")
	debug.reinstall_server("eslint")
end, { desc = "Reinstall ESLint server" })
