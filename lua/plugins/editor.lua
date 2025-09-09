-- Editor enhancement plugins (WITH treesitter working on Windows)
return {
	-- Autopairs with treesitter integration
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")

			autopairs.setup({
				check_ts = true, -- treesitter integration
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" },
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0,
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})

			-- Add custom rule for angle brackets
			local Rule = require("nvim-autopairs.rule")
			autopairs.add_rules({
				Rule("<", ">"):with_pair(function(opts)
					-- Only auto-close in specific contexts where it makes sense
					local line = opts.line
					local col = opts.col
					local char = line:sub(col - 1, col - 1)
					-- Avoid auto-closing after certain characters
					return not vim.tbl_contains({ "=", "<", ">" }, char)
				end),
			})

			-- Integration with nvim-cmp if you're using it
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-- Keep vim-polyglot as fallback for languages treesitter doesn't support
	{
		"sheerun/vim-polyglot",
		event = { "BufReadPost", "BufNewFile" },
		init = function()
			-- Disable for languages that treesitter handles well
			vim.g.polyglot_disabled = {
				"lua",
				"html",
				"css",
				"javascript",
				"typescript",
				"json",
				"yaml",
				"markdown",
				"c",
				"vim",
			}
		end,
	},

	-- Keep vim-closetag as backup for treesitter auto-tag
	{
		"alvan/vim-closetag",
		ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
		config = function()
			vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.js,*.ts,*.vue,*.svelte"
			vim.g.closetag_xhtml_filenames = "*.xhtml,*.jsx,*.tsx,*.vue"
			vim.g.closetag_filetypes =
				"html,xhtml,phtml,javascript,typescript,javascriptreact,typescriptreact,vue,svelte"
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

	-- Enhanced matching with treesitter support
	{
		"andymass/vim-matchup",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_surround_enabled = 1
			-- Integrate with treesitter
			vim.g.matchup_treesitter_enabled = 1
		end,
	},

	-- Treesitter-based rainbow delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},

	-- Rest of your editor plugins...
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
				scope = {
					enabled = true, -- Enable scope highlighting with treesitter
					show_start = true,
					show_end = true,
				},
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

	-- Your other plugins remain the same...
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
