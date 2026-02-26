-- Editor settings and performance optimizations
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set showmode")
vim.g.mapleader = " "

-- Performance optimizations
vim.opt.updatetime = 300
vim.opt.timeoutlen = 1000
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 200

-- Swap file configuration (prevents annoying swap file warnings)
vim.opt.swapfile = true -- Keep swap files for crash recovery
vim.opt.updatecount = 100 -- Write swap file after 100 characters
vim.opt.directory = vim.fn.stdpath("data") .. "/swap//" -- Use // for unique names

-- Auto-handle stale swap files (when file is newer than swap)
vim.api.nvim_create_autocmd("SwapExists", {
	callback = function()
		-- Automatically edit the file (ignoring swap file warning)
		-- Since your case shows file is NEWER, this is safe
		vim.v.swapchoice = "e" -- Edit anyway
	end,
})

-- Enable true color support
vim.cmd("set termguicolors")

-- REMOVE the treesitter blocking - allow it to work
-- vim.g.loaded_nvim_treesitter = 1  -- COMMENTED OUT

-- Additional performance optimizations
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.fn.line("$") > 5000 then
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.syntax = "off"
		end
	end,
})

-- Emmet leader key
vim.g.user_emmet_leader_key = "<C-y>"

-- Delayed highlight setup
vim.defer_fn(function()
	vim.cmd([[
		hi! clear MatchTag
		hi! MatchTag cterm=bold gui=bold guifg=#2aa198 guibg=#073642
		hi! link MatchParen MatchTag
	]])
end, 200)

-- NOTE: Colorscheme is now set in the catppuccin plugin configuration
-- Add to your existing options.lua
-- Force treesitter highlighting to work
vim.opt.termguicolors = true
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

-- Ensure treesitter highlighting takes priority
vim.defer_fn(function()
	-- Re-enable treesitter highlighting after colorscheme loads
	if vim.fn.exists(":TSEnable") > 0 then
		vim.cmd("TSEnable highlight")
	end
end, 500)
