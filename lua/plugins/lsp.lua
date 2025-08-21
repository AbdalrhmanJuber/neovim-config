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

	-- Mason LSP config bridge - FIXED for proper server attachment
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
					"eslint",        -- ESLint Language Server
				},
				automatic_installation = true,
				-- Disable automatic setup to prevent overriding custom configs
				-- We'll handle setup manually in nvim-lspconfig
			})
			
			-- Add debug notification for installed servers
			vim.defer_fn(function()
				local installed_servers = require("mason-lspconfig").get_installed_servers()
			end, 2000)
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

	-- Clean LSP Configuration
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

			-- Enhanced capabilities
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- Add LSP debugging function
			local function debug_lsp_status()
				local clients = vim.lsp.get_clients()
				if #clients == 0 then
					return
				end
				
				local status_msg = "LSP Status:\n"
				for _, client in ipairs(clients) do
					local buffers = vim.lsp.get_buffers_by_client_id(client.id)
					local buf_count = #buffers
					status_msg = status_msg .. string.format("- %s: %s (%d buffers)\n", 
						client.name, 
						client.is_stopped() and "Stopped" or "Active",
						buf_count
					)
				end
				vim.notify(status_msg, vim.log.levels.INFO)
			end

			-- Add keybinding for LSP status debugging
			vim.keymap.set("n", "<leader>ls", debug_lsp_status, { desc = "Show LSP status" })

			-- Enhanced on_attach function with better debugging
			local on_attach = function(client, bufnr)
				-- Buffer-specific keymaps
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
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

				-- Add manual server restart keybinding
				vim.keymap.set("n", "<leader>lr", function()
					vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = bufnr }))
					vim.defer_fn(function()
						vim.cmd("edit") -- Reload buffer to retrigger LSP
					end, 500)
				end, { buffer = bufnr, desc = "Restart LSP server" })

				-- Enhanced success notification with more details
				local filetype = vim.bo[bufnr].filetype
				vim.notify(
					string.format("✅ LSP attached: %s to %s (buffer %d)", 
						client.name, filetype, bufnr), 
					vim.log.levels.INFO
				)
				
				-- Debug server capabilities
				if client.server_capabilities then
					local caps = {}
					if client.server_capabilities.documentFormattingProvider then
						table.insert(caps, "formatting")
					end
					if client.server_capabilities.completionProvider then
						table.insert(caps, "completion")
					end
					if client.server_capabilities.hoverProvider then
						table.insert(caps, "hover")
					end
					if client.server_capabilities.definitionProvider then
						table.insert(caps, "goto_definition")
					end
					if #caps > 0 then
						vim.notify(
							string.format("📋 %s capabilities: %s", client.name, table.concat(caps, ", ")),
							vim.log.levels.INFO
						)
					end
				end
			end

			-- Lua Language Server
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
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
			lspconfig.cssls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- HTML Language Server
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- TypeScript Language Server (handles both JS and TS) - ENHANCED
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = function(fname)
					-- Enhanced root detection for better project setup
					local util = require("lspconfig.util")
					return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
						or util.path.dirname(fname)
				end,
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx"
				},
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = 'all',
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
						preferences = {
							disableSuggestions = false,
							includeCompletionsForModuleExports = true,
							includeCompletionsForImportStatements = true,
						},
						suggest = {
							includeCompletionsForModuleExports = true,
						}
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = 'all',
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
						preferences = {
							disableSuggestions = false,
							includeCompletionsForModuleExports = true,
							includeCompletionsForImportStatements = true,
						},
						suggest = {
							includeCompletionsForModuleExports = true,
						}
					}
				},
				-- Force server to start for these file types
				on_init = function(client, initialization_result)
				end,
			})

			-- ESLint Language Server - SAFE IMPLEMENTATION
			lspconfig.eslint.setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					-- Call the common on_attach first
					on_attach(client, bufnr)
					
					-- Add ESLint-specific formatting on save
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
						group = vim.api.nvim_create_augroup("EslintFixOnSave", { clear = false }),
					})
				end,
				settings = {
					codeAction = {
						disableRuleComment = {
							enable = true,
							location = "separateLine"
						},
						showDocumentation = {
							enable = true
						}
					},
					codeActionOnSave = {
						enable = false, -- We handle this manually
						mode = "all"
					},
					format = true,
					nodePath = "",
					onIgnoredFiles = "off",
					packageManager = "npm",
					quiet = false,
					rulesCustomizations = {},
					run = "onType",
					validate = "on",
					workingDirectory = {
						mode = "location"
					}
				},
				-- Safe root directory detection without vim.fs.concat
				root_dir = function(fname)
					local util = require("lspconfig.util")
					-- Use standard util functions instead of vim.fs.concat
					return util.root_pattern(
						".eslintrc",
						".eslintrc.json", 
						".eslintrc.js",
						".eslintrc.yaml",
						".eslintrc.yml",
						"package.json"
					)(fname) or util.path.dirname(fname)
				end,
				filetypes = {
					"javascript", 
					"javascriptreact", 
					"typescript", 
					"typescriptreact"
				}
			})

			-- JSON Language Server
			lspconfig.jsonls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "json", "jsonc" },
			})

			-- LSP diagnostic configuration with better visibility
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
				},
			})

			-- Better LSP UI with enhanced borders and info
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				title = "LSP Hover",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				title = "Signature Help",
			})

			-- Add global keybindings for LSP management
			vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
			vim.keymap.set("n", "<leader>lI", "<cmd>Mason<cr>", { desc = "Mason Info" })
			
			-- Force LSP restart for current buffer
			vim.keymap.set("n", "<leader>lR", function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					return
				end
				
				for _, client in ipairs(clients) do
					vim.lsp.stop_client(client.id)
				end
				
				vim.defer_fn(function()
					vim.cmd("edit") -- Reload buffer to retrigger LSP
				end, 1000)
			end, { desc = "Restart all LSP servers for buffer" })

			-- Add autocmd to show when servers attach to files
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					local bufnr = event.buf
					local filetype = vim.bo[bufnr].filetype
					
					vim.notify(
						string.format("🔗 %s attached to %s file", client.name, filetype),
						vim.log.levels.INFO
					)
				end,
			})

			-- Add autocmd to show when servers detach
			vim.api.nvim_create_autocmd("LspDetach", {
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client then
						vim.notify(
							string.format("🔌 %s detached", client.name),
							vim.log.levels.WARN
						)
					end
				end,
			})

			-- Force TypeScript server to start for specific file types with retries
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
				callback = function(event)
					local bufnr = event.buf
					
					-- Function to check and start TypeScript server
					local function check_and_start_ts_server()
						local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })
						if #clients == 0 then
							vim.notify("🔄 Starting TypeScript server...", vim.log.levels.INFO)
							vim.cmd("LspStart ts_ls")
							
							-- Schedule a check after server should have started
							vim.defer_fn(function()
								local new_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })
								if #new_clients == 0 then
									vim.notify("⚠️ TypeScript server failed to start. Use <leader>ld to diagnose.", vim.log.levels.WARN)
								else
									vim.notify("✅ TypeScript server started successfully!", vim.log.levels.INFO)
								end
							end, 2000)
						end
					end
					
					-- Small initial delay to ensure file is properly loaded
					vim.defer_fn(check_and_start_ts_server, 100)
				end,
			})

			-- Add a command to manually trigger server attachment
			vim.api.nvim_create_user_command('LspAttachAll', function()
				vim.notify("🔄 Attempting to attach all relevant LSP servers...", vim.log.levels.INFO)
				
				local bufnr = vim.api.nvim_get_current_buf()
				local filetype = vim.bo[bufnr].filetype
				
				local server_map = {
					javascript = { "ts_ls", "eslint" },
					javascriptreact = { "ts_ls", "eslint" },
					typescript = { "ts_ls", "eslint" },
					typescriptreact = { "ts_ls", "eslint" },
					lua = { "lua_ls" },
					html = { "html" },
					css = { "cssls" },
					json = { "jsonls" },
				}
				
				local servers = server_map[filetype] or {}
				for _, server in ipairs(servers) do
					vim.cmd("LspStart " .. server)
				end
				
				if #servers > 0 then
					vim.notify("🚀 Started servers: " .. table.concat(servers, ", "), vim.log.levels.INFO)
				else
					vim.notify("❓ No LSP servers configured for filetype: " .. filetype, vim.log.levels.WARN)
				end
			end, { desc = "Manually attach all relevant LSP servers" })

			-- Add keybinding for manual attachment
			vim.keymap.set("n", "<leader>la", "<cmd>LspAttachAll<cr>", { desc = "Attach all LSP servers" })
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
