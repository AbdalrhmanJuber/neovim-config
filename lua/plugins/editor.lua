-- Editor enhancement plugins (No treesitter - Windows reliable setup)
return {
	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = false, -- Disable treesitter integration
				ts = false, -- Disable treesitter completely for autopairs
			})
		end,
	},

	-- COMPLETELY DISABLE treesitter to avoid all Windows issues
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = false,
	},
	{
		"windwp/nvim-ts-autotag", 
		enabled = false,
	},

	-- Use vim-polyglot for comprehensive syntax highlighting
	{
		"sheerun/vim-polyglot",
		event = { "BufReadPost", "BufNewFile" },
		init = function()
			-- Enable all languages - polyglot is very reliable
			vim.g.polyglot_disabled = {}
		end,
		config = function()
			-- Enhanced HTML/CSS/JS highlighting
			vim.g.html_indent_script1 = "inc"
			vim.g.html_indent_style1 = "inc"
			vim.g.css_indent_script = 1
			vim.g.javascript_plugin_jsdoc = 1
			vim.g.typescript_plugin_jsdoc = 1
		end,
	},

	-- Reliable auto-closing tags for HTML/JSX
	{
		"alvan/vim-closetag",
		ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
		config = function()
			vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.js,*.ts,*.vue,*.svelte"
			vim.g.closetag_xhtml_filenames = "*.xhtml,*.jsx,*.tsx,*.vue"
			vim.g.closetag_filetypes = "html,xhtml,phtml,javascript,typescript,javascriptreact,typescriptreact,vue,svelte"
			vim.g.closetag_xhtml_filetypes = "xhtml,jsx,tsx,vue"
			vim.g.closetag_emptyTags_caseSensitive = 1
			vim.g.closetag_regions = {
				["typescript.tsx"] = "jsxRegion,tsxRegion",
				["javascript.jsx"] = "jsxRegion",
				["typescriptreact"] = "jsxRegion",
				["javascriptreact"] = "jsxRegion",
			}
			vim.g.closetag_shortcut = ">"
			vim.g.closetag_close_shortcut = "<leader>>"
		end,
	},

	-- Enhanced matching with matchup (better than built-in matchparen)
	{
		"andymass/vim-matchup",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_surround_enabled = 1
		end,
	},

	-- Rainbow parentheses (works without treesitter) - FIXED SYNTAX
	{
		"frazrepo/vim-rainbow",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			vim.g.rainbow_active = 1
			vim.g.rainbow_conf = {
				guifgs = { "#f38ba8", "#a6e3a1", "#89b4fa", "#f9e2af", "#cba6f7" },
				ctermfgs = { "lightblue", "lightyellow", "lightcyan", "lightmagenta" },
				guis = { "" },
				cterms = { "" },
				operators = "_,_",
				parentheses = { "start=/(/ end=/)/ fold", "start=/\\[/ end=/\\]/ fold", "start=/{/ end=/}/ fold" },
				separately = {
					["*"] = {},
					["markdown"] = { parentheses_options = "containedin=markdownCode contained" }, -- FIXED: = instead of :
				}
			}
		end,
	},

	-- Indentation guides (works great without treesitter)
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = { enabled = false },
				exclude = {
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"neo-tree",
						"Trouble",
						"trouble",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
						"lazyterm",
					},
				},
			})
		end,
	},

	-- Smooth scrolling
	{
		"karb94/neoscroll.nvim",
		event = "WinScrolled",
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "<C-f>", "<C-b>", "zt", "zz", "zb" },
				easing_function = "quadratic",
				performance_mode = true,
			})
		end,
	},

	-- Last place
	{
		"ethanholz/nvim-lastplace",
		event = "BufReadPost",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn" },
				lastplace_open_folds = true,
			})
		end,
	},

	-- Auto-save
	{
		"Pocco81/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" },
		config = function()
			require("auto-save").setup({
				enabled = true,
				debounce_delay = 1000,
				execution_message = {
					message = function()
						return ("AutoSave: " .. vim.fn.strftime("%H:%M:%S"))
					end,
					dim = 0.18,
					cleaning_interval = 2500,
				},
				conditions = {
					exists = true,
					modifiable = true,
					filename_is_not = {},
					filetype_is_not = {},
				},
				write_all_buffers = false,
				on_off_commands = true,
				clean_command_line_interval = 0,
			})
		end,
	},

	-- Enhanced comment functionality
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("Comment").setup({
				padding = true,
				sticky = true,
				ignore = nil,
				toggler = {
					line = "gcc",
					block = "gbc",
				},
				opleader = {
					line = "gc",
					block = "gb",
				},
				extra = {
					above = "gcO",
					below = "gco",
					eol = "gcA",
				},
				mappings = {
					basic = true,
					extra = true,
				},
			})
		end,
	},
}
