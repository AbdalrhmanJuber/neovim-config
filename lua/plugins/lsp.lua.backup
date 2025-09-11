-- FINAL LSP Configuration - CLEAN & MODERN (ALL SERVERS ENABLED)
return {
	-- Mason
	{
		"williamboman/mason.nvim",
		lazy = false,
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

	-- Mason LSP config bridge - INSTALLATION ONLY
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		priority = 999,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"cssls",
					"html",
					"emmet_ls",
					"tailwindcss",
					"ts_ls",
					"eslint",
					"jsonls",
					"pyright",
					"clangd",
					"bashls",
				},
				automatic_installation = false,
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

	-- Completion sources
	{ "hrsh7th/cmp-nvim-lsp", lazy = true },
	{ "hrsh7th/cmp-buffer", lazy = true },
	{ "hrsh7th/cmp-path", lazy = true },
	{ "saadparwaiz1/cmp_luasnip", lazy = true },
	{ "onsails/lspkind-nvim", lazy = true },

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
		end,
	},

	-- LSP SETUP - ALL SERVERS ENABLED
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local mason_path = vim.fn.stdpath("data") .. "/mason/bin/"

			local on_attach = function(client, bufnr)
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

				if client.name == "eslint" then
					vim.keymap.set("n", "<leader>lf", function()
						vim.cmd("EslintFixAll")
					end, { buffer = bufnr, desc = "ESLint Fix All" })
				end
			end

			-- HTML Server
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "vscode-html-language-server.CMD", "--stdio" },
				settings = {
					html = {
						format = { enable = false },
						hover = { documentation = false },
					},
				},
				root_dir = lspconfig.util.root_pattern("package.json", ".git", vim.fn.getcwd()),
			})

			-- Emmet Server
			lspconfig.emmet_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "emmet-ls.CMD", "--stdio" },
				filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact", "vue" },
				init_options = {
					html = { options = { ["bem.enabled"] = true } },
				},
				root_dir = lspconfig.util.root_pattern("package.json", ".git", vim.fn.getcwd()),
			})

			-- Tailwind Server
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "tailwindcss-language-server.CMD", "--stdio" },
				filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact" },
				root_dir = lspconfig.util.root_pattern(
					"tailwind.config.js",
					"tailwind.config.ts",
					"postcss.config.js",
					"postcss.config.ts",
					"package.json",
					".git",
					vim.fn.getcwd()
				),
			})

			-- CSS Server
			lspconfig.cssls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "vscode-css-language-server.CMD", "--stdio" },
				settings = {
					css = { validate = true, lint = { unknownAtRules = "ignore" } },
					scss = { validate = true, lint = { unknownAtRules = "ignore" } },
					less = { validate = true, lint = { unknownAtRules = "ignore" } },
				},
				filetypes = { "css", "scss", "less", "sass" },
			})

			-- TypeScript/JavaScript Server
lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  -- Force only Mason's ts_ls, not system typescript-language-server
  cmd = { mason_path .. "typescript-language-server.CMD", "--stdio" },
  -- Prevent multiple instances
  single_file_support = true,
  root_dir = lspconfig.util.root_pattern(
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
    vim.fn.getcwd()
  ),
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})
			-- ESLint Server
			lspconfig.eslint.setup({
				capabilities = capabilities,
				cmd = { mason_path .. "vscode-eslint-language-server.CMD", "--stdio" },
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
				settings = {
					codeAction = {
						disableRuleComment = { enable = true, location = "separateLine" },
						showDocumentation = { enable = true },
					},
					codeActionOnSave = { enable = false, mode = "all" },
					experimental = { useFlatConfig = false },
					format = true,
					run = "onType",
					validate = "on",
					workingDirectory = { mode = "location" },
				},
			})

			-- Lua Server
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "lua-language-server.CMD" },
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- JSON Server
			lspconfig.jsonls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "vscode-json-language-server.CMD", "--stdio" },
			})

			-- Python Server
			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "pyright-langserver.CMD", "--stdio" },
			})

			-- C/C++ Server
			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				-- Force only Mason's clangd, not system clangd
				cmd = { mason_path .. "clangd.CMD" },
				-- Add flags to prevent conflicts
				init_options = {
					clangdFileStatus = true,
					usePlaceholders = true,
					completeUnimported = true,
				},
				-- Prevent multiple instances
				single_file_support = true,
				root_dir = lspconfig.util.root_pattern(
					"compile_commands.json",
					"compile_flags.txt",
					".clangd",
					".git",
					"CMakeLists.txt",
					"Makefile"
				),
			})

			-- Bash Server
			lspconfig.bashls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { mason_path .. "bash-language-server.CMD", "start" },
			})

			-- Diagnostics and UI
			vim.diagnostic.config({
				virtual_text = { delay = 100 },
				signs = true,
				underline = false,
				update_in_insert = false,
			})

			local function disable_all_underlines()
				for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
					local hl = vim.api.nvim_get_hl(0, { name = name })
					if hl.underline then
						hl.underline = false
						vim.api.nvim_set_hl(0, name, hl)
					end
				end
			end

			disable_all_underlines()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = disable_all_underlines })
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function()
					vim.defer_fn(disable_all_underlines, 100)
				end,
			})
		end,
	},
}
