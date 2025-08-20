-- init.lua

-- Editor settings
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
vim.opt.timeoutlen = 500
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 200
vim.keymap.set("n", "t", function()
	local char = vim.fn.getcharstr() -- get next character
	vim.cmd("normal! v") -- enter visual mode
	vim.cmd("normal! t" .. char) -- perform t<char> motion
end, { noremap = true })
vim.keymap.set("n", "T", function()
	local char = vim.fn.getcharstr()
	vim.cmd("normal! vT" .. char)
end, { noremap = true })
-- Ensure sessionoptions include localoptions for auto-session
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,localoptions"

-- Enable true color support
vim.cmd("set termguicolors")

-- Clipboard keymaps
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to clipboard" })
vim.keymap.set("n", "<leader>y", ":%y+<CR>", { desc = "Yank entire buffer to clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste over selection from clipboard" })

vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", { noremap = true, silent = true })
-- Bootstrap lazy.nvim
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
local plugins = {
	-- Mason
	{
		"williamboman/mason.nvim",
		lazy = false, -- Load immediately
		priority = 1000,
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- Mason LSP config bridge
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false, -- Load immediately
		priority = 999,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"tailwindcss",
					"cssls",
					"html",
					"clangd",
				},
				automatic_installation = true,
			})
		end,
	},

	-- LuaSnip
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Completion sources
	{
		"hrsh7th/cmp-nvim-lsp",
		lazy = true,
	},
	{
		"hrsh7th/cmp-buffer",
		lazy = true,
	},
	{
		"hrsh7th/cmp-path",
		lazy = true,
	},
	{
		"hrsh7th/cmp-cmdline",
		lazy = true,
	},
	{
		"saadparwaiz1/cmp_luasnip",
		lazy = true,
	},
	{
		"onsails/lspkind-nvim",
		lazy = true,
	},

	-- Completion engine
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind-nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			-- Setup completion
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", max_item_count = 20 },
					{ name = "luasnip", max_item_count = 10 },
				}, {
					{ name = "buffer", max_item_count = 5 },
					{ name = "path", max_item_count = 5 },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			})

			-- Setup completion for search
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Setup completion for command line
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	-- LSP Configuration (FIXED - simpler approach without mason-lspconfig handlers)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Enhanced capabilities for better completion
			capabilities.textDocument.completion.completionItem = {
				documentationFormat = { "markdown", "plaintext" },
				snippetSupport = true,
				preselectSupport = true,
				insertReplaceSupport = true,
				labelDetailsSupport = true,
				deprecatedSupport = true,
				commitCharactersSupport = true,
				tagSupport = { valueSet = { 1 } },
				resolveSupport = {
					properties = {
						"documentation",
						"detail",
						"additionalTextEdits",
					},
				},
			}

			local on_attach = function(client, bufnr)
				-- Enable completion triggered by <c-x><c-o>
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- Mappings
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
			end
			-- C/C++ LSP
			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "clangd", "--background-index", "--clang-tidy" },
				filetypes = { "c", "cpp", "objc", "objcpp" },
			})

			-- Manual LSP server setup (more reliable than mason handlers)
			-- Lua LSP
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			-- TypeScript LSP
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Tailwind CSS LSP
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					tailwindCSS = {
						classAttributes = { "class", "className", "ngClass" },
						experimental = {
							classRegex = {
								"tw`([^`]*)",
								'tw="([^"]*)',
								'tw={"([^"}]*)',
							},
						},
					},
				},
				filetypes = {
					"html",
					"css",
					"scss",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"vue",
				},
			})

			-- CSS LSP
			lspconfig.cssls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- HTML LSP
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
		end,
	},

	-- Emmet
	{
		"mattn/emmet-vim",
		ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact" },
	},

	-- Auto-tag
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},

	-- Copilot
	{
		"github/copilot.vim",
		lazy = false,
		event = "InsertEnter",
		config = function()
			-- Disable default tab mapping to avoid conflicts
			vim.g.copilot_no_tab_map = true

			-- Custom keymaps for Copilot
			vim.keymap.set("i", "<C-Z>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})

			-- Keymaps to enable/disable Copilot
			vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", {
				desc = "Enable Copilot",
				silent = true,
			})

			vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", {
				desc = "Disable Copilot",
				silent = true,
			})

			-- Alternative: Toggle function (optional)
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

			-- Enable Copilot for specific filetypes
			vim.g.copilot_filetypes = {
				["*"] = false,
				["javascript"] = true,
				["typescript"] = true,
				["lua"] = true,
				["rust"] = true,
				["c"] = true,
				["c#"] = true,
				["c++"] = true,
				["go"] = true,
				["python"] = true,
				["html"] = true,
				["css"] = true,
				["scss"] = true,
				["json"] = true,
				["yaml"] = true,
				["markdown"] = true,
			}
		end,
	},

	-- Color schemes
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1001,
		lazy = false,
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
			-- vim.cmd.colorscheme("solarized-osaka")
			vim.api.nvim_set_hl(0, "MatchParen", { fg = "#B58900", bg = nil, underline = true, bold = false })
		end,
	},
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
				extensions = {
					file_browser = {
						hijack_netrw = true,
						mappings = {
							["n"] = {
								["m"] = fb_actions.move,
							},
							["i"] = {
								["<C-m>"] = fb_actions.move,
							},
						},
					},
				},
			})
			telescope.load_extension("file_browser")
		end,
	},
	-- Web dev icons
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},

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

	-- Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ lsp_fallback = true })
				end,
				desc = "[F]ormat file",
			},
		},
		opts = {
			formatters_by_ft = {
				html = { "prettier" },
				css = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "black" },
				["cpp"] = { "clang_format" }, -- use "cpp" instead of "c++"
				c = { "clang_format" },
				["*"] = { "trim_whitespace" },
			},
		},
	},

	-- Tailwind tools
	{
		"luckasRanarison/tailwind-tools.nvim",
		ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact" },
		config = function()
			require("tailwind-tools").setup({
				color_enabled = true,
				color_mode = "background",
			})
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
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
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{ "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		},
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
	},
	{
		"leafOfTree/vim-matchtag",
		ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact" },
		config = function()
			vim.g.vim_matchtag_enable_by_default = 1
			vim.g.vim_matchtag_files = "*.html,*.xml,*.js,*.jsx,*.ts,*.tsx"

			-- Configure to highlight only tag names
			vim.g.vim_matchtag_both = 0 -- Don't highlight both tags simultaneously
			vim.g.vim_matchtag_highlight_cursor_on = 1 -- Only highlight when cursor is on tag

			-- Subtle cyan highlight that works well with solarized-osaka
			vim.cmd([[
			augroup vim_matchtag_highlight
				autocmd!
				autocmd ColorScheme * hi MatchTag cterm=bold gui=bold guifg=#2aa198 guibg=NONE
			augroup END
		]])
		end,
	},
}

-- Initialize plugins with performance optimizations
require("lazy").setup(plugins, {
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Essential keymaps
vim.keymap.set("n", "<leader>s", function()
	os.execute('tasklist | findstr /I "live-server" || start cmd /c live-server')
end)

vim.keymap.set("n", "<leader>ks", function()
	os.execute("taskkill /IM node.exe /F")
end, { desc = "Kill all Node.js processes (e.g., live-server)" })

-- Additional performance optimizations
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.fn.line("$") > 5000 then
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.syntax = "off"
		end
	end,
})
vim.g.user_emmet_leader_key = "<C-y>"
vim.defer_fn(function()
	vim.cmd([[
		hi! clear MatchTag
		hi! MatchTag cterm=bold gui=bold guifg=#2aa198 guibg=#073642
		hi! link MatchParen MatchTag
	]])
end, 200)
vim.cmd.colorscheme("catppuccin-mocha")
