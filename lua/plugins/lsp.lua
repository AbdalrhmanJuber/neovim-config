-- Clean LSP configuration without problematic components
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

	-- Mason LSP config bridge - Enhanced with automatic setup
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		priority = 999,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",        -- Lua Language Server
					"cssls",         -- CSS Language Server
					"html",          -- HTML Language Server
					"ts_ls",         -- TypeScript Language Server (handles JS/TS)
					"jsonls",        -- JSON Language Server
				},
				automatic_installation = true,
			})

			-- Server validation utility
			local function is_server_available(server_name)
				local mason_registry = require("mason-registry")
				local success, pkg = pcall(mason_registry.get_package, server_name)
				if success and pkg:is_installed() then
					return true
				end
				return false
			end

			-- Store server availability for later use
			vim.g.lsp_server_status = {
				lua_ls = is_server_available("lua-language-server"),
				cssls = is_server_available("css-lsp"),
				html = is_server_available("html-lsp"),
				ts_ls = is_server_available("typescript-language-server"),
				jsonls = is_server_available("json-lsp"),
			}
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

	-- Schema store for JSON
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},

	-- Clean LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
			"b0o/schemastore.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local util = require("lspconfig.util")

			-- Enhanced capabilities
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities.textDocument.completion.completionItem.resolveSupport = {
				properties = { "documentation", "detail", "additionalTextEdits" },
			}

			-- Utility functions
			local function safe_setup(server_name, config)
				local success, err = pcall(function()
					lspconfig[server_name].setup(config)
				end)
				if not success then
					vim.notify(
						string.format("Failed to setup %s: %s", server_name, err),
						vim.log.levels.ERROR
					)
					return false
				end
				return true
			end

			local function get_typescript_server_path()
				-- Try to find typescript-language-server in various locations
				local paths = {
					vim.fn.exepath("typescript-language-server"),
					vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server",
				}
				
				for _, path in ipairs(paths) do
					if path and path ~= "" and vim.fn.executable(path) == 1 then
						return path
					end
				end
				return nil
			end

			-- Enhanced on_attach function with better error handling
			local on_attach = function(client, bufnr)
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
				
				-- Standard LSP keymaps
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, bufopts)

				-- Enhanced diagnostics
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, bufopts)
				vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, bufopts)

				-- Show success message with more details
				vim.notify(
					string.format("LSP attached: %s (PID: %s)", client.name, client.config.cmd and client.config.cmd[1] or "N/A"),
					vim.log.levels.INFO
				)
			end

			-- Debug commands
			vim.api.nvim_create_user_command("LspDebug", function()
				local clients = vim.lsp.get_active_clients()
				if #clients == 0 then
					vim.notify("No active LSP clients", vim.log.levels.WARN)
					return
				end

				for _, client in ipairs(clients) do
					local info = {
						name = client.name,
						id = client.id,
						filetypes = client.config.filetypes,
						root_dir = client.config.root_dir,
						cmd = client.config.cmd,
						attached_buffers = vim.tbl_keys(client.attached_buffers),
					}
					print(vim.inspect(info))
				end
			end, { desc = "Show LSP debug information" })

			vim.api.nvim_create_user_command("LspRestart", function()
				vim.cmd("LspStop")
				vim.defer_fn(function()
					vim.cmd("edit")
				end, 500)
			end, { desc = "Restart LSP servers" })

			-- Health check command
			vim.api.nvim_create_user_command("LspHealth", function()
				local servers = { "lua_ls", "cssls", "html", "ts_ls", "jsonls" }
				for _, server in ipairs(servers) do
					local status = vim.g.lsp_server_status and vim.g.lsp_server_status[server]
					local installed = status and "✓ Installed" or "✗ Not installed"
					local active = false
					
					for _, client in ipairs(vim.lsp.get_active_clients()) do
						if client.name == server then
							active = true
							break
						end
					end
					
					local active_status = active and "✓ Active" or "○ Inactive"
					vim.notify(string.format("%s: %s | %s", server, installed, active_status))
				end
			end, { desc = "Check LSP server health" })

			-- Lua Language Server
			safe_setup("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "lua-language-server" },
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

			-- CSS Language Server
			safe_setup("cssls", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "vscode-css-language-server", "--stdio" },
			})

			-- HTML Language Server
			safe_setup("html", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "vscode-html-language-server", "--stdio" },
			})

			-- TypeScript Language Server (Enhanced Configuration)
			local ts_server_path = get_typescript_server_path()
			if ts_server_path then
				local ts_config = {
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = { ts_server_path, "--stdio" },
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx"
					},
					root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
					init_options = {
						hostInfo = "neovim",
						preferences = {
							disableSuggestions = false,
							includeCompletionsForModuleExports = true,
							includeCompletionsWithInsertText = true,
						}
					},
					settings = {
						typescript = {
							preferences = {
								disableSuggestions = false,
								includeCompletionsForModuleExports = true,
								includeCompletionsWithInsertText = true,
								importModuleSpecifier = "relative"
							},
							suggest = {
								autoImports = true,
								includeAutomaticOptionalChainCompletions = true,
							},
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
							}
						},
						javascript = {
							preferences = {
								disableSuggestions = false,
								includeCompletionsForModuleExports = true,
								includeCompletionsWithInsertText = true,
								importModuleSpecifier = "relative"
							},
							suggest = {
								autoImports = true,
								includeAutomaticOptionalChainCompletions = true,
							}
						}
					}
				}
				
				if safe_setup("ts_ls", ts_config) then
					vim.notify("TypeScript LSP configured successfully", vim.log.levels.INFO)
				end
			else
				vim.notify(
					"TypeScript Language Server not found. Install via :MasonInstall typescript-language-server",
					vim.log.levels.WARN
				)
			end

			-- JSON Language Server
			local json_settings = {
				json = {
					validate = { enable = true },
				}
			}
			
			-- Try to add schemastore schemas if available
			local ok, schemastore = pcall(require, "schemastore")
			if ok then
				json_settings.json.schemas = schemastore.json.schemas()
			end
			
			safe_setup("jsonls", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
				settings = json_settings
			})

			-- Enhanced LSP diagnostic configuration
			vim.diagnostic.config({
				virtual_text = {
					severity = vim.diagnostic.severity.ERROR,
					source = "if_many",
					format = function(diagnostic)
						if diagnostic.source then
							return string.format("[%s] %s", diagnostic.source, diagnostic.message)
						end
						return diagnostic.message
					end,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			-- Enhanced LSP UI handlers
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
			})

			-- Custom diagnostic signs
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			-- Auto-format on save for specific filetypes (optional)
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.lua" },
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})
		end,
	},

	-- Emmet for HTML/CSS
	{
		"mattn/emmet-vim",
		ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
		config = function()
			vim.g.user_emmet_leader_key = '<C-y>'
			vim.g.user_emmet_settings = {
				javascript = {
					extends = 'jsx',
				},
				typescript = {
					extends = 'tsx',
				},
			}
		end,
	},
}
