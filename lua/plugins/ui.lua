-- UI related plugins (colorschemes, statusline, file explorer)
return {
	-- Color schemes

{
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- Options: latte, frappe, macchiato, mocha
      transparent_background = false,
      term_colors = true,
      integrations = {
        treesitter = true,
        native_lsp = { enabled = true },
        telescope = true,
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        which_key = true,
        indent_blankline = { enabled = true },
        notify = true,
        mini = true,
      },
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
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			-- vim.cmd("colorscheme rose-pine")
		end,
	},
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
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
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"catppuccin/nvim",
		},
		config = function()
			local colors = require("catppuccin.palettes").get_palette("frappe")

			-- Custom components
			local function lsp_status()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					return ""
				end
				return " LSP"
			end

			local function recording_status()
				local reg = vim.fn.reg_recording()
				if reg == "" then
					return ""
				end
				return "録 " .. reg
			end

			local function search_count()
				if vim.v.hlsearch == 0 then
					return ""
				end
				local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
				if not ok or next(result) == nil then
					return ""
				end
				local denominator = math.min(result.total, result.maxcount)
				return string.format(" %d/%d", result.current, denominator)
			end

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "catppuccin",
					component_separators = "",
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = { "alpha", "dashboard", "NvimTree", "Outline" },
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = true,
					refresh = {
						statusline = 100,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(str)
								local mode_map = {
									["NORMAL"] = "󰰓 NORMAL",
									["INSERT"] = "󰰅 INSERT",
									["VISUAL"] = "󰰤 VISUAL",
									["V-LINE"] = "󰰤 V-LINE",
									["V-BLOCK"] = "󰰤 V-BLOCK",
									["COMMAND"] = "󰘳 COMMAND",
									["SELECT"] = "󰰤 SELECT",
									["REPLACE"] = "󰯹 REPLACE",
									["TERMINAL"] = "󰆍 TERMINAL",
								}
								return mode_map[str] or str
							end,
							separator = { right = "" },
							padding = { left = 1, right = 1 },
						},
					},
					lualine_b = {
						{
							"branch",
							icon = "󰊢",
							fmt = function(str)
								if string.len(str) > 20 then
									return string.sub(str, 1, 17) .. "..."
								end
								return str
							end,
							color = { fg = colors.lavender, gui = "bold" },
						},
					},
					lualine_c = {
						{
							"diff",
							symbols = {
								added = "󰐕 ",
								modified = "󰑕 ",
								removed = "󰍵 ",
							},
							diff_color = {
								added = { fg = colors.green },
								modified = { fg = colors.peach },
								removed = { fg = colors.red },
							},
							padding = { left = 1, right = 1 },
						},
						{
							"diagnostics",
							sources = { "nvim_diagnostic", "nvim_lsp" },
							symbols = {
								error = "󰅚 ",
								warn = "󰀪 ",
								info = "󰋽 ",
								hint = "󰌶 ",
							},
							diagnostics_color = {
								error = { fg = colors.red },
								warn = { fg = colors.yellow },
								info = { fg = colors.blue },
								hint = { fg = colors.teal },
							},
							update_in_insert = false,
						},
						{
							"filename",
							path = 1,
							symbols = {
								modified = " 󰷥",
								readonly = " 󰌾",
								unnamed = "󰟢 [No Name]",
								newfile = " 󰎔",
							},
							color = { fg = colors.text },
							separator = "",
						},
					},
					lualine_x = {
						{
							search_count,
							color = { fg = colors.sky },
						},
						{
							recording_status,
							color = { fg = colors.red, gui = "bold" },
						},
						{
							lsp_status,
							color = { fg = colors.green },
						},
						{
							"encoding",
							fmt = string.upper,
							cond = function()
								return vim.bo.fileencoding ~= "utf-8"
							end,
							color = { fg = colors.subtext1 },
						},
						{
							"fileformat",
							symbols = {
								unix = "󰻀",
								dos = "󰍲",
								mac = "󰀵",
							},
							cond = function()
								return vim.bo.fileformat ~= "unix"
							end,
							color = { fg = colors.subtext1 },
						},
						{
							"filetype",
							colored = true,
							icon_only = false,
							icon = { align = "right" },
							color = { fg = colors.subtext0 },
						},
					},
					lualine_y = {
						{
							"progress",
							fmt = function()
								return "%P/%L"
							end,
							color = { fg = colors.peach },
						},
					},
					lualine_z = {
						{
							"location",
							fmt = function()
								return "󰉸 %l:%-2c"
							end,
							separator = { left = "" },
							padding = { left = 1, right = 1 },
						},
					},
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							color = { fg = colors.overlay1 },
						},
					},
					lualine_x = {
						{
							"location",
							color = { fg = colors.overlay1 },
						},
					},
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {
					"nvim-tree",
					"lazy",
					"mason",
					"trouble",
					"quickfix",
					"nvim-dap-ui",
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
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
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
