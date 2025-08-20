-- UI related plugins (colorschemes, statusline, file explorer)
return {
	-- Color schemes
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1001,
		lazy = false,
		config = function()
			-- Set the colorscheme after the plugin loads
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
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
