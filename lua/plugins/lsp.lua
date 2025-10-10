-- FINAL LSP Configuration - CLEAN & MODERN (ALL SERVERS ENABLED + ANGULAR FIXED)
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
					"yamlls",
					"angularls", -- ADD ANGULAR LANGUAGE SERVER
					"verible", -- ADD THIS for Verilog/SystemVerilog
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
			-- AGGRESSIVE SYSTEM LSP BLOCKING
			vim.g.loaded_node_provider = 0
			vim.g.loaded_python3_provider = 0
			vim.g.loaded_perl_provider = 0
			vim.g.loaded_ruby_provider = 0

			-- CLEAR ANY EXISTING LSP CONFIGS
			for server_name, _ in pairs(require("lspconfig.configs")) do
				require("lspconfig")[server_name] = nil
			end

			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local mason_path = vim.fn.stdpath("data") .. "/mason/bin/"

			-- FORCE MASON EXECUTABLES FOR ALL SERVERS
			local function get_mason_cmd(server_name)
				local cmd_map = {
					html = "vscode-html-language-server.CMD",
					emmet_ls = "emmet-ls.CMD",
					tailwindcss = "tailwindcss-language-server.CMD",
					cssls = "vscode-css-language-server.CMD",
					ts_ls = "typescript-language-server.CMD",
					eslint = "vscode-eslint-language-server.CMD",
					lua_ls = "lua-language-server.CMD",
					jsonls = "vscode-json-language-server.CMD",
					pyright = "pyright-langserver.CMD",
					clangd = "clangd.CMD",
					bashls = "bash-language-server.CMD",
					yamlls = "yaml-language-server.CMD",
					angularls = "ngserver.CMD", -- ADD ANGULAR COMMAND MAPPING

					verible = "verible-verilog-ls.CMD", -- ADD THIS
				}
				return mason_path .. cmd_map[server_name]
			end

			-- AGGRESSIVE DUPLICATE PREVENTION WITH ANGULAR EXCEPTION
			local active_servers = {}
			local on_attach = function(client, bufnr)
				-- Modified system LSP killing with Angular exception
				if client.config and client.config.cmd and client.config.cmd[1] then
					local cmd = client.config.cmd[1]
					local is_mason = string.match(cmd, "mason") or string.match(cmd, mason_path:gsub("\\", "\\\\"))
					local is_angular_exception = client.name == "angularls" and string.match(cmd, "ngserver")

					if not is_mason and not is_angular_exception then
						print("Killing system LSP: " .. client.name .. " (" .. cmd .. ")")
						vim.lsp.stop_client(client.id, true)
						return
					end
				end

				-- Track active servers per buffer
				if not active_servers[bufnr] then
					active_servers[bufnr] = {}
				end

				if active_servers[bufnr][client.name] then
					print("Killing duplicate LSP: " .. client.name)
					vim.lsp.stop_client(client.id, true)
					return
				end

				active_servers[bufnr][client.name] = client.id

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

			-- MODIFIED SYSTEM LSP BLOCKING WITH ANGULAR EXCEPTION
			local original_start_client = vim.lsp.start_client
			vim.lsp.start_client = function(config)
				-- Block any server that's not from Mason, except Angular
				if config.cmd and config.cmd[1] then
					local cmd = config.cmd[1]
					local is_mason = string.match(cmd, "mason") or string.match(cmd, mason_path:gsub("\\", "\\\\"))
					local is_angular_exception = config.name == "angularls" and string.match(cmd, "ngserver")

					if not is_mason and not is_angular_exception then
						print("BLOCKED system LSP: " .. (config.name or "unknown") .. " (" .. cmd .. ")")
						return nil
					end
				end
				return original_start_client(config)
			end

			-- MANUAL LSP SETUP WITH FORCED MASON COMMANDS
			local servers = {

				verible = {
					cmd = { get_mason_cmd("verible") },
					filetypes = { "verilog", "systemverilog" },
					root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
					single_file_support = true,
				},
				yamlls = {
					cmd = { get_mason_cmd("yamlls"), "--stdio" },
					filetypes = { "yaml", "yaml.docker-compose" },
					settings = {
						yaml = {
							validate = true,
							completion = true,
							hover = true,
							schemaStore = {
								enable = false,
							},
							schemas = {
								["file:///C:/Users/a-ahm/.config/nvim/yaml_schemas/compose-spec.json"] = "docker-compose*.yml",
							},
						},
					},
				},
				angularls = {
					cmd = {
						get_mason_cmd("angularls"),
						"--stdio",
						"--tsProbeLocations",
						vim.fn.getcwd(),
						"--ngProbeLocations",
						vim.fn.getcwd(),
					},
					filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
					root_dir = lspconfig.util.root_pattern("angular.json", "project.json"),
					settings = {
						angular = {
							log = "verbose",
						},
					},
					single_file_support = false,
				},
				html = {
					cmd = { get_mason_cmd("html"), "--stdio" },
					settings = {
						html = {
							format = { enable = false },
							hover = { documentation = false },
						},
					},
					root_dir = lspconfig.util.root_pattern("package.json", ".git", vim.fn.getcwd()),
				},
				emmet_ls = {
					cmd = { get_mason_cmd("emmet_ls"), "--stdio" },
					filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact", "vue" },
					init_options = {
						html = { options = { ["bem.enabled"] = true } },
					},
					root_dir = lspconfig.util.root_pattern("package.json", ".git", vim.fn.getcwd()),
				},
				tailwindcss = {
					cmd = { get_mason_cmd("tailwindcss"), "--stdio" },
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
				},
				cssls = {
					cmd = { get_mason_cmd("cssls"), "--stdio" },
					settings = {
						css = { validate = true, lint = { unknownAtRules = "ignore" } },
						scss = { validate = true, lint = { unknownAtRules = "ignore" } },
						less = { validate = true, lint = { unknownAtRules = "ignore" } },
					},
					filetypes = { "css", "scss", "less", "sass" },
				},
				ts_ls = {
					cmd = { get_mason_cmd("ts_ls"), "--stdio" },
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
				},
				eslint = {
					cmd = { get_mason_cmd("eslint"), "--stdio" },
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
				},
				lua_ls = {
					cmd = { get_mason_cmd("lua_ls") },
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
				},
				jsonls = {
					cmd = { get_mason_cmd("jsonls"), "--stdio" },
				},
				pyright = {
					cmd = { get_mason_cmd("pyright"), "--stdio" },
				},
				clangd = {
					cmd = { get_mason_cmd("clangd") },
					init_options = {
						clangdFileStatus = true,
						usePlaceholders = true,
						completeUnimported = true,
					},
					single_file_support = true,
					root_dir = lspconfig.util.root_pattern(
						"compile_commands.json",
						"compile_flags.txt",
						".clangd",
						".git",
						"CMakeLists.txt",
						"Makefile"
					),
				},
				bashls = {
					cmd = { get_mason_cmd("bashls"), "start" },
				},
			}

			-- Setup each server manually
			for server_name, config in pairs(servers) do
				config.capabilities = capabilities
				if not config.on_attach then
					config.on_attach = on_attach
				end
				lspconfig[server_name].setup(config)
			end

			-- MODIFIED CLEANUP TIMER WITH ANGULAR EXCEPTION
			vim.defer_fn(function()
				local clients = vim.lsp.get_clients()
				for _, client in ipairs(clients) do
					if client.config and client.config.cmd and client.config.cmd[1] then
						local cmd = client.config.cmd[1]
						local is_mason = string.match(cmd, "mason") or string.match(cmd, mason_path:gsub("\\", "\\\\"))
						local is_angular_exception = client.name == "angularls" and string.match(cmd, "ngserver")

						if not is_mason and not is_angular_exception then
							print("Cleanup: Killing system LSP " .. client.name)
							vim.lsp.stop_client(client.id, true)
						end
					end
				end
			end, 2000)

			-- Diagnostics and UI (unchanged)
			vim.diagnostic.config({
				virtual_text = {
					delay = 100,
					spacing = 4,
					source = "if_many",
					prefix = "●",
					format = function(diagnostic)
						local message = diagnostic.message
						if #message > 60 then
							message = message:sub(1, 57) .. "..."
						end
						return message
					end,
				},
				signs = {
					severity = { min = vim.diagnostic.severity.HINT },
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.INFO] = "",
						[vim.diagnostic.severity.HINT] = "",
					},
				},
				underline = false,
				update_in_insert = false,
				severity_sort = true,
				float = {
					focusable = true,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					max_width = math.floor(vim.o.columns * 0.8),
					max_height = math.floor(vim.o.lines * 0.4),
					wrap = true,
				},
			})
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					local opts = {
						focusable = false,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						border = "rounded",
						source = "always",
						prefix = " ",
						scope = "cursor",
						max_width = math.floor(vim.o.columns * 0.8),
						max_height = math.floor(vim.o.lines * 0.3),
						wrap = true,
					}
					vim.diagnostic.open_float(nil, opts)
				end,
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
