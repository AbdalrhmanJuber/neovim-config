-- ===================================================================
-- LSP + MASON + CMP (CLEAN, SAFE, FUTURE-PROOF)
-- ===================================================================

return {

	-- =========================
	-- Mason (installer)
	-- =========================
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		config = function()
			require("mason").setup()
		end,
	},

	-- =========================
	-- Mason bridge (install only)
	-- =========================
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				-- Only install servers you actually use regularly
				ensure_installed = {
					"lua_ls",
					"html",
					"cssls",
					"ts_ls",
					"tailwindcss",
					"jsonls",
				},
			})
		end,
	},

	-- =========================
	-- Completion Engine
	-- =========================
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
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
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "buffer", priority = 500 },
					{ name = "path", priority = 250 },
				}),
				formatting = {
					format = lspkind.cmp_format({ 
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
			})
		end,
	},

	-- =========================
	-- LSP CONFIGURATION
	-- =========================
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- Disable legacy providers (safe + faster)
			vim.g.loaded_node_provider = 0
			vim.g.loaded_python3_provider = 0
			vim.g.loaded_perl_provider = 0
			vim.g.loaded_ruby_provider = 0

			local lspconfig = require("lspconfig")
			local util = lspconfig.util
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

			local function cmd(bin)
				return mason_bin .. bin
			end

			-- =========================
			-- on_attach (keymaps)
			-- =========================
			local on_attach = function(_, bufnr)
				local opts = { buffer = bufnr, silent = true }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			end

			-- =========================
			-- SERVERS
			-- =========================

			lspconfig.lua_ls.setup({
			cmd = { cmd("lua-language-server.cmd") },
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			lspconfig.ts_ls.setup({
				cmd = { cmd("typescript-language-server.cmd"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
			})

			lspconfig.angularls.setup({
				cmd = {
					cmd("ngserver.cmd"),
					"--stdio",
					"--tsProbeLocations",
					vim.fn.getcwd(),
					"--ngProbeLocations",
					vim.fn.getcwd(),
				},
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = util.root_pattern("angular.json", "project.json"),
				single_file_support = false,
			})

			lspconfig.tailwindcss.setup({
				cmd = { cmd("tailwindcss-language-server.cmd"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			filetypes = { 
				"html", 
				"css", 
				"scss", 
				"javascript", 
				"javascriptreact", 
				"typescript", 
				"typescriptreact",
				"vue" 
			},
			root_dir = util.root_pattern(
				"tailwind.config.js",
				"tailwind.config.ts",
				"postcss.config.js",
				"package.json",
				".git"
			),
			settings = {
				tailwindCSS = {
					validate = true,
					lint = {
						cssConflict = "warning",
						invalidApply = "error",
						invalidScreen = "error",
						invalidVariant = "error",
						invalidConfigPath = "error",
						invalidTailwindDirective = "error",
						recommendedVariantOrder = "warning",
					},
					classAttributes = { "class", "className", "classList", "ngClass" },
					experimental = {
						classRegex = {
							{ "class:\\s*?[\"'`]([^\"'`]*).*?[\"'`]", "[\"'`]([^\"'`]*).*?[\"'`]" },
							{ ":class=\"([^\"]*)", "([a-zA-Z0-9\\-:]+)" },
						},
					},
				},
			},
		})

		lspconfig.cssls.setup({
			cmd = { cmd("vscode-css-language-server.cmd"), "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig.emmet_ls.setup({
			cmd = { cmd("emmet-ls.cmd"), "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
			filetypes = { 
				"html", 
				"css", 
				"scss", 
				"javascript", 
				"javascriptreact", 
				"typescript", 
				"typescriptreact",
				"vue" 
			},
		})

		lspconfig.jsonls.setup({
			cmd = { cmd("vscode-json-language-server.cmd"), "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.yamlls.setup({
			cmd = { cmd("yaml-language-server.cmd"), "--stdio" },
			capabilities = capabilities,
			on_attach = on_attach,
	})

	lspconfig.eslint.setup({
		cmd = { cmd("vscode-eslint-language-server.cmd"), "--stdio" },
		capabilities = capabilities,
		on_attach = on_attach,
		root_dir = util.root_pattern(
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yaml",
			".eslintrc.yml",
			".eslintrc.json",
			"eslint.config.js",
			"package.json"
		),
		settings = {
			workingDirectory = { mode = "auto" },
		},
	})

			lspconfig.clangd.setup({
				cmd = { cmd("clangd") },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.bashls.setup({
			cmd = { cmd("bash-language-server.cmd"), "start" },
				on_attach = on_attach,
			})

			lspconfig.pyright.setup({
				cmd = { cmd("pyright-langserver.cmd"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.intelephense.setup({
				cmd = { cmd("intelephense.cmd"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = util.root_pattern("composer.json", "artisan", ".git"),

				settings = {
					intelephense = {
						files = {
							maxSize = 5000000, -- 5MB file limit (prevents vendor madness)
						},
						environment = {
							phpVersion = "8.2",
						},
						diagnostics = {
							enable = true,
						},
						format = {
							enable = false, -- formatting is expensive
						},
						completion = {
							fullyQualifyGlobalConstantsAndFunctions = false,
						},
					},
				},
			})

			lspconfig.svlangserver.setup({
				cmd = { cmd("svlangserver") },
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "verilog", "systemverilog" },
			})

			lspconfig.volar.setup({
				cmd = { cmd("vue-language-server.cmd"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "vue" },
				root_dir = util.root_pattern("package.json", "vue.config.js", "vite.config.js", ".git"),
				single_file_support = true,
				init_options = {
					typescript = {
						tsdk = vim.fn.expand("$HOME/.npm-global/node_modules/typescript/lib"),
					},
				},
			})

			-- =========================
			-- Diagnostics UI
			-- =========================
			vim.diagnostic.config({
				virtual_text = { prefix = "●", spacing = 4 },
				underline = false,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
				},
			})
		end,
	},
}
