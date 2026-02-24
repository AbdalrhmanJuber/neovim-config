-- ===================================================================
-- LSP + MASON + CMP (CLEAN, SAFE, FUTURE-PROOF)
-- ===================================================================

return {

	-- =========================
	-- Mason (installer)
	-- =========================
	{
		"williamboman/mason.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("mason").setup()
		end,
	},

	-- =========================
	-- Mason bridge (install only)
	-- =========================
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		priority = 999,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"html",
					"cssls",
					"emmet_ls",
					"tailwindcss",
					"ts_ls",
					"eslint",
					"jsonls",
					"yamlls",
					"clangd",
					"bashls",
					"pyright",
					"angularls",
					"svlangserver",
					--"intelephense",
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
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				formatting = {
					format = lspkind.cmp_format({ mode = "symbol_text" }),
				},
			})
		end,
	},

	-- =========================
	-- LSP CONFIGURATION
	-- =========================
	{
		"neovim/nvim-lspconfig",
		lazy = false,

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
				cmd = { cmd("lua-language-server") },
				capabilities = capabilities,
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
				cmd = { cmd("typescript-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
			})

			lspconfig.angularls.setup({
				cmd = {
					cmd("ngserver"),
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
				cmd = { cmd("tailwindcss-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = util.root_pattern(
					"tailwind.config.js",
					"tailwind.config.ts",
					"postcss.config.js",
					"package.json",
					".git"
				),
			})

			lspconfig.html.setup({
				cmd = { cmd("vscode-html-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.cssls.setup({
				cmd = { cmd("vscode-css-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.emmet_ls.setup({
				cmd = { cmd("emmet-ls"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.jsonls.setup({
				cmd = { cmd("vscode-json-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.yamlls.setup({
				cmd = { cmd("yaml-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.eslint.setup({
				cmd = { cmd("vscode-eslint-language-server"), "--stdio" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.clangd.setup({
				cmd = { cmd("clangd") },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.bashls.setup({
				cmd = { cmd("bash-language-server"), "start" },
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.pyright.setup({
				cmd = { cmd("pyright-langserver"), "--stdio" },
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
