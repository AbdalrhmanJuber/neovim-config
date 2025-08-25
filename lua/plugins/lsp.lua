-- Minimal LSP configuration for Windows compatibility
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

	-- Mason LSP config bridge
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		priority = 999,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"cssls", -- CSS Language Server
					"html", -- HTML Language Server
					"emmet_ls", -- Emmet Language Server
					"tailwindcss", -- Tailwind CSS Language Server
					"ts_ls",
					"eslint",
					"vtsls",
					"jsonls",
					"pyright",
					"clangd",
					"bashls",
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

	-- nvim-vtsls (keep this as an alternative option)
	{
		"yioneko/nvim-vtsls",
		ft = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		enabled = false, -- Disable this since we're using ts_ls
		config = function()
			-- Override the default root_dir to fix Windows path issues
			local lspconfig = require("lspconfig")

			-- Custom root directory function that's more Windows-friendly
			local function get_typescript_root(fname)
				local util = require("lspconfig.util")

				-- First try the standard patterns
				local root = util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)

				-- If no root found, use the file's directory
				if not root then
					root = vim.fn.fnamemodify(fname, ":p:h")
				end

				return root
			end

			-- Configure vtsls with the custom root_dir
			require("vtsls").config({
				-- Add the custom root_dir here
				root_dir = get_typescript_root,
				settings = {
					vtsls = {
						enableMoveToFileCodeAction = true,
						autoUseWorkspaceTsdk = true,
						experimental = {
							completion = {
								enableServerSideFuzzyMatch = true,
							},
						},
					},
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
					javascript = {
						updateImportsOnFileMove = { enabled = "always" },
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
				},
			})
		end,
	},

	-- LSP Configuration
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

				-- ESLint specific keybindings
				if client.name == "eslint" then
					vim.keymap.set("n", "<leader>lf", function()
						vim.cmd("EslintFixAll")
					end, { buffer = bufnr, desc = "ESLint Fix All" })
				end
			end

			-- Lua LSP
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

			-- TypeScript/JavaScript LSP (ts_ls)
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
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

			-- ESLint LSP
			lspconfig.eslint.setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)

					-- Auto-fix on save
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
				settings = {
					codeAction = {
						disableRuleComment = {
							enable = true,
							location = "separateLine",
						},
						showDocumentation = {
							enable = true,
						},
					},
					codeActionOnSave = {
						enable = false,
						mode = "all",
					},
					experimental = {
						useFlatConfig = false,
					},
					format = true,
					nodePath = "",
					onIgnoredFiles = "off",
					packageManager = "npm",
					problems = {
						shortenToSingleLine = false,
					},
					quiet = false,
					rulesCustomizations = {},
					run = "onType",
					useESLintClass = false,
					validate = "on",
					workingDirectory = {
						mode = "location",
					},
				},
			})
			-- C/C++ LSP (clangd) - Add this
			lspconfig.clangd.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.root_pattern(
						"Makefile",
						"configure.ac",
						"configure.in",
						"config.h.in",
						"meson.build",
						"meson_options.txt",
						"build.ninja"
					)(fname) or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname) or util.find_git_ancestor(
						fname
					)
				end,
			})
		-- Enhanced CSS LSP
        lspconfig.cssls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore", -- Ignore unknown @ rules (useful for Tailwind)
                    },
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                less = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
            },
            filetypes = { "css", "scss", "less", "sass" },
        })

        -- Enhanced HTML LSP
        lspconfig.html.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                html = {
                    format = {
                        templating = true,
                        wrapLineLength = 120,
                        wrapAttributes = "auto",
                    },
                    hover = {
                        documentation = true,
                        references = true,
                    },
                },
            },
            filetypes = { "html", "htmldjango", "blade" },
        })

        -- Add Emmet LSP for better HTML/CSS snippets
        lspconfig.emmet_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = {
                "css",
                "eruby",
                "html",
                "javascript",
                "javascriptreact",
                "less",
                "sass",
                "scss",
                "svelte",
                "pug",
                "typescriptreact",
                "vue",
            },
            init_options = {
                html = {
                    options = {
                        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
                        ["bem.enabled"] = true,
                    },
                },
            },
        })			-- Tailwind CSS LSP
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- JSON LSP
			lspconfig.jsonls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Python LSP
			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- LSP diagnostic configuration
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
			})
		end,
	},

	-- Emmet for HTML/CSS (works without LSP)
	{
		"mattn/emmet-vim",
		ft = { "html", "css" },
		config = function()
			vim.g.user_emmet_leader_key = "<C-y>"
		end,
	},
}
