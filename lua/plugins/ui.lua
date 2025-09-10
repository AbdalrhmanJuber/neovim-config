-- UI related plugins (colorschemes, statusline, file explorer)
return {
	-- Color schemes
{
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1001,
	lazy = false,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "mocha",
			},
			transparent_background = false, -- disables setting the background color
			show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
			term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
			dim_inactive = {
				enabled = false, -- dims the background color of inactive window
				shade = "dark",
				percentage = 0.15, -- percentage of the shade to apply to the inactive window
			},
			no_italic = false, -- Force no italic
			no_bold = false, -- Force no bold
			no_underline = false, -- Force no underline
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { "italic" }, -- Change the style of comments
				conditionals = { "italic" },
				loops = {},
				functions = { "bold" },
				keywords = { "italic" },
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = { "italic" },
				operators = {},
			},
			color_overrides = {
				mocha = {
					-- You can override specific colors here
					-- base = "#000000", -- Background
					-- mantle = "#010101",
					-- crust = "#020202",
				},
			},
			custom_highlights = function(colors)
				return {
					-- Custom highlight groups
					Comment = { fg = colors.overlay1, style = { "italic" } },
					CursorLineNr = { fg = colors.yellow, style = { "bold" } },
					LineNr = { fg = colors.overlay0 },
					-- Add more custom highlights here
				}
			end,
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = true,
				telescope = {
					enabled = true,
					style = "nvchad" -- or "classic"
				},
				mason = true,
				which_key = true,
				indent_blankline = {
					enabled = true,
					scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
					colored_indent_levels = false,
				},
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
					inlay_hints = {
						background = true,
					},
				},
				-- Add more integrations as needed
			},
		})

		-- Set the colorscheme
		vim.cmd.colorscheme("catppuccin-mocha")
		
		-- Optional: Set up some autocommands for dynamic theming
		local group = vim.api.nvim_create_augroup("CatppuccinTheme", { clear = true })
		
		-- Auto-switch based on time of day (optional)
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			callback = function()
				local hour = tonumber(os.date("%H"))
				if hour >= 6 and hour < 18 then
					-- Day time
					vim.cmd.colorscheme("catppuccin-latte")
				else
					-- Night time
					vim.cmd.colorscheme("catppuccin-mocha")
				end
			end,
		})
	end,
},
{
  "vague2k/vague.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other plugins
  config = function()
    -- NOTE: you do not need to call setup if you don't want to.
    require("vague").setup({
      -- optional configuration here
    })
    -- vim.cmd("colorscheme vague")
  end
},
 {
	"rose-pine/neovim",
	name = "rose-pine",
	config = function()
		-- vim.cmd("colorscheme rose-pine")

	end
},
	{
		"craftzdog/solarized-osaka.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("solarized-osaka").setup({
				terminal_colors = true,
				transparent = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					sidebars = "transparent",
					floats = "transparent",
				},
				sidebars = { "qf", "help" },
				day_brightness = 0.7,
				hide_inactive_statusline = false,
				dim_inactive = false,
				lualine_bold = false,
			})
			vim.api.nvim_set_hl(0, "MatchParen", { fg = "#B58900", bg = nil, underline = true, bold = false })
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},

	-- Web dev icons
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeOpen" },
		keys = {
			{ "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-web-devicons").setup({ default = true })
			require("nvim-tree").setup({
				view = { width = 30 },
				renderer = {
					highlight_git = true,
					icons = { show = { file = true, folder = true, folder_arrow = true } },
				},
				git = { enable = false },
				diagnostics = { enable = false },
			})
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "catppuccin-frappe",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = { "NvimTree", "packer" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Rainbow delimiters
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
	},

	-- Telescope - COMPLETELY disable treesitter
	{
		"nvim-telescope/telescope.nvim",
		cmd = { "Telescope" },
		keys = {
			{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fb", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "File Browser" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
		},
		tag = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local fb_actions = require("telescope").extensions.file_browser.actions

			telescope.setup({
				defaults = {
					-- COMPLETELY disable treesitter in previews
					preview = {
						treesitter = false,
						highlight_limit = 0, -- Disable highlighting entirely
					},
					-- Use basic file type detection
					file_previewer = require('telescope.previewers').vim_buffer_cat.new,
					grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
					qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
				},
				extensions = {
					file_browser = {
						hijack_netrw = true,
						mappings = {
							["n"] = { ["m"] = fb_actions.move },
							["i"] = { ["<C-m>"] = fb_actions.move },
						},
					},
				},
			})
			telescope.load_extension("file_browser")
		end,
	},
}
