-- UI related plugins (colorschemes, statusline, file explorer)
return {
	-- Color schemes

 {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,         -- load immediately (so other plugins can read its highlights)
    priority = 1000,      -- high priority so it sets before others
    -- You can also set build = ":CatppuccinCompile" if you use compiled cache
    opts = function()
      local transparent = vim.g.transparent_background or false

      return {
        flavour = "mocha", -- default; we’ll override dynamically at load
        background = {
          light = "macchiato", -- changed from "latte"
          dark = "mocha",
        },
        transparent_background = transparent,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments      = { "italic" },
          conditionals  = { "italic" },
          functions     = { "bold" },
          keywords      = { "italic" },
          types         = { "italic" },
          -- leave others empty to inherit defaults
        },
        color_overrides = {
          -- Example of subtle darkening or brand alignment
          mocha = {
            -- You can uncomment & tweak if you want a *slightly* darker base:
            -- base = "#0F0F17",
            -- mantle = "#0C0C13",
            -- crust = "#09090F",
          },
        },
        custom_highlights = function(colors)
          -- Utility (exposed by catppuccin >= v1.7)
          local u_ok, u = pcall(require, "catppuccin.utils.colors")
          local darken = function(c, pct, base)
            if u_ok then return u.darken(c, pct, base) end
            return c
          end

          local transparent = vim.g.transparent_background or false
          local float_bg = transparent and "NONE" or colors.mantle
          local subtle = darken(colors.surface0, 0.55, colors.base)

          return {
            NormalFloat         = { bg = float_bg },
            FloatBorder         = { fg = colors.surface2, bg = float_bg },
            FloatTitle          = { fg = colors.lavender, bold = true },
            WinSeparator        = { fg = colors.surface1, bg = "NONE" },
            CursorLine          = { bg = darken(colors.surface0, 0.60, colors.base) },
            CursorLineNr        = { fg = colors.yellow, style = { "bold" } },
            LineNr              = { fg = colors.overlay0 },
            Visual              = { bg = darken(colors.lavender, 0.25, colors.base) },
            MatchParen          = { bg = colors.surface1, style = { "bold" } },
            Search              = { bg = colors.peach, fg = colors.crust, style = { "bold" } },
            IncSearch           = { bg = colors.yellow, fg = colors.crust, style = { "bold" } },
            Pmenu               = { bg = float_bg, fg = colors.text },
            PmenuSel            = { bg = colors.surface1, fg = colors.text, bold = true },
            PmenuSbar           = { bg = colors.surface0 },
            PmenuThumb          = { bg = colors.surface2 },
            DiagnosticUnnecessary      = { fg = colors.overlay1, style = { "italic" } },
            DiagnosticUnderlineError   = { sp = colors.red, undercurl = true },
            DiagnosticUnderlineWarn    = { sp = colors.peach, undercurl = true },
            DiagnosticUnderlineInfo    = { sp = colors.sky, undercurl = true },
            DiagnosticUnderlineHint    = { sp = colors.teal, undercurl = true },
            DiagnosticVirtualTextHint  = { fg = colors.teal },
            DiagnosticVirtualTextInfo  = { fg = colors.sky },
            DiagnosticVirtualTextWarn  = { fg = colors.peach },
            DiagnosticVirtualTextError = { fg = colors.red },
            TreesitterContext          = { bg = subtle },
            TreesitterContextLineNumber= { fg = colors.lavender, style = { "bold" } },

            -- Git signs
            GitSignsAdd    = { fg = colors.green },
            GitSignsChange = { fg = colors.peach },
            GitSignsDelete = { fg = colors.red },

            -- Telescope polish
            TelescopeSelection      = { bg = colors.surface0, style = { "bold" } },
            TelescopeMatching       = { fg = colors.flamingo, style = { "bold" } },
            TelescopePromptBorder   = { fg = colors.surface2, bg = float_bg },
            TelescopeResultsBorder  = { fg = colors.surface2, bg = float_bg },
            TelescopePreviewBorder  = { fg = colors.surface2, bg = float_bg },
            TelescopePromptNormal   = { bg = float_bg },
            TelescopeResultsNormal  = { bg = float_bg },
            TelescopePreviewNormal  = { bg = float_bg },
            TelescopePromptTitle    = { fg = colors.mauve, style = { "bold" } },
            TelescopeResultsTitle   = { fg = colors.blue, style = { "bold" } },
            TelescopePreviewTitle   = { fg = colors.green, style = { "bold" } },

            -- Indentation guides
            IblIndent = { fg = colors.surface1 },
            IblScope  = { fg = colors.lavender },

            -- Lualine (if not using catppuccin's extension)
            StatusLine        = { bg = colors.surface0, fg = colors.text },
            StatusLineNC      = { bg = colors.surface0, fg = colors.overlay1 },
            WinBar            = { fg = colors.subtext1 },
            WinBarNC          = { fg = colors.overlay1 },

            -- Mini plugins examples
            MiniIndentscopeSymbol = { fg = colors.lavender, nocombine = true },

            -- WhichKey accent
            WhichKey          = { fg = colors.mauve, style = { "bold" } },
            WhichKeyGroup     = { fg = colors.blue },
            WhichKeyDesc      = { fg = colors.sky },
            WhichKeySeparator = { fg = colors.overlay1 },
            WhichKeyFloat     = { bg = float_bg },

            -- Floating diagnostics
            DiagnosticFloatTitle = { fg = colors.lavender, bold = true },

            -- Make comments a hair dimmer but readable
            Comment = { fg = colors.overlay1, style = { "italic" } },
          }
        end,
        integrations = {
          cmp = true,
            gitsigns = true,
            treesitter = true,
            treesitter_context = true,
            nvimtree = true,
            neotree = true,
            telescope = {
              enabled = true,
              style = "nvchad",
            },
            mason = true,
            which_key = true,
            lsp_trouble = true,
            notify = true,
            noice = true,
            fidget = true,
            harpoon = true,
            leap = true,
            nvim_surround = true,
            mini = {
              enabled = true,
              indentscope_color = "", -- inherits
            },
            illuminate = true,
            indent_blankline = {
              enabled = true,
              scope_color = "lavender",
              colored_indent_levels = false,
            },
            navic = {
              enabled = true,
              custom_bg = "NONE",
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
            -- Add or remove integrations to match your setup
        },
      }
    end,
    config = function(_, opts)
      local ok, cat = pcall(require, "catppuccin")
      if not ok then
        vim.notify("[catppuccin] failed to load", vim.log.levels.ERROR)
        return
      end

      ---------------------------------------------------------------------------
      -- Helpers
      ---------------------------------------------------------------------------
      local function macos_appearance()
        if vim.fn.has("mac") == 1 then
          local out = vim.fn.systemlist([[defaults read -g AppleInterfaceStyle 2>/dev/null]])
          if out and #out > 0 then
            return "dark"
          end
          return "light"
        end
      end

      local function flavour_by_time()
        local hour = tonumber(os.date("%H"))
        return (hour >= 7 and hour < 18) and "macchiato" or "mocha" -- changed from "latte"
      end

      local function decide_flavour()
        -- Priority: explicit env > macOS mode > time
        local env = vim.env.NVIM_THEME_FLAVOUR
        if env == "mocha" or env == "latte" or env == "frappe" or env == "macchiato" then
          return env
        end
        local mac_mode = macos_appearance()
        if mac_mode == "dark" then
          return "mocha"
        elseif mac_mode == "light" then
          return "macchiato" -- changed from "latte"
        end
        return flavour_by_time()
      end

      local function apply(flavour)
        flavour = flavour or decide_flavour()
        vim.g.catppuccin_flavour = flavour
        opts.flavour = flavour
        cat.setup(opts)
        local cs_ok, err = pcall(vim.cmd.colorscheme, "catppuccin-" .. flavour)
        if not cs_ok then
          vim.notify("[catppuccin] colorscheme load error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      ---------------------------------------------------------------------------
      -- Initial load
      ---------------------------------------------------------------------------
      apply()

      ---------------------------------------------------------------------------
      -- User Commands
      ---------------------------------------------------------------------------
      vim.api.nvim_create_user_command("CatppuccinToggle", function()
        local cur = vim.g.catppuccin_flavour or opts.flavour
        -- toggle dark <-> "light" (macchiato)
        local next_map = { mocha = "macchiato", macchiato = "mocha", frappe = "mocha", latte = "mocha" }
        local nxt = next_map[cur] or "mocha"
        apply(nxt)
        vim.notify("Catppuccin flavour -> " .. nxt)
      end, { desc = "Toggle Catppuccin flavour (dark/light)" })

      vim.api.nvim_create_user_command("CatppuccinTransparentToggle", function()
        opts.transparent_background = not opts.transparent_background
        vim.g.transparent_background = opts.transparent_background
        apply(vim.g.catppuccin_flavour)
        vim.notify("Catppuccin transparency -> " .. tostring(opts.transparent_background))
      end, { desc = "Toggle Catppuccin transparency" })

      vim.api.nvim_create_user_command("CatppuccinReload", function()
        apply()
        vim.notify("Catppuccin reloaded with computed flavour")
      end, { desc = "Recompute and reload Catppuccin flavour" })

      ---------------------------------------------------------------------------
      -- Autocommands
      ---------------------------------------------------------------------------
      local grp = vim.api.nvim_create_augroup("CatppuccinDynamic", { clear = true })

      -- Refresh flavour on gaining focus (detect OS theme change on macOS)
      vim.api.nvim_create_autocmd("FocusGained", {
        group = grp,
        callback = function()
          local new = decide_flavour()
          if new ~= vim.g.catppuccin_flavour then
            apply(new)
          end
        end,
      })

      -- Periodic check on VimEnter (e.g., if you start at boundary times)
      vim.api.nvim_create_autocmd("VimEnter", {
        group = grp,
        callback = function()
          local new = decide_flavour()
            if new ~= vim.g.catppuccin_flavour then
              apply(new)
            end
        end,
      })

      -- Optional: adapt if user manually changes &background
      vim.api.nvim_create_autocmd("OptionSet", {
        group = grp,
        pattern = "background",
        callback = function()
          local bg = vim.o.background
          local target = (bg == "light") and "macchiato" or "mocha" -- changed from "latte"
          if target ~= vim.g.catppuccin_flavour then
            apply(target)
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
	dependencies = { 
		"nvim-tree/nvim-web-devicons",
		"catppuccin/nvim"
	},
	config = function()
		local colors = require("catppuccin.palettes").get_palette("frappe")
		
		-- Custom components
		local function lsp_status()
			local clients = vim.lsp.get_active_clients({ bufnr = 0 })
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
							removed = "󰍵 " 
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
							hint = "󰌶 " 
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
					}
				},
				lualine_x = { 
					{
						"location",
						color = { fg = colors.overlay1 },
					}
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
				"nvim-dap-ui"
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
