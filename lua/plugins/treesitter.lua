-- Complete treesitter configuration optimized for web development
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			-- Windows compatibility settings
			require("nvim-treesitter.install").prefer_git = false
			require("nvim-treesitter.install").compilers = { "gcc", "clang", "cc" }
			
			require("nvim-treesitter.configs").setup({
				-- Comprehensive web development parsers
				ensure_installed = {
					-- Core
					"lua", "vim", "vimdoc", "query",
					
					-- Web fundamentals
					"html", "css", "scss", "javascript", "typescript", "tsx",
					
					-- Web frameworks/libraries
					"angular",
					
					-- Styling
					"styled",
					
					-- Data formats
					"json", "json5", "jsonc", "yaml", "toml", "xml",
					
					-- Documentation
					"markdown", "markdown_inline", 
					
					-- Backend languages you might use
					"python", "go", "rust", "php",
					
					-- Config files
					"dockerfile", "nginx", "gitignore", "gitcommit",
					
					-- Shell scripting
					"bash",
					
					-- Other useful ones
					"regex", "sql", "graphql",
					
					-- Systems programming (optional)
					"c", "cpp", "java",
				},

				sync_install = false,
				auto_install = true,
				
				ignore_install = {},

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "markdown" },
				},

				indent = {
					enable = true,
					-- You might want to disable HTML indent if it's problematic
					-- disable = { "html" },
				},

				-- Enhanced incremental selection for web development
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},

				-- Text objects for better code navigation
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							-- Functions
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							
							-- Classes
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							
							-- Parameters/arguments
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							
							-- Conditionals
							["ai"] = "@conditional.outer",
							["ii"] = "@conditional.inner",
							
							-- Loops
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							
							-- Comments
							["aC"] = "@comment.outer",
							["iC"] = "@comment.inner",
							
							-- Blocks
							["ab"] = "@block.outer",
							["ib"] = "@block.inner",
						},
						selection_modes = {
							['@parameter.outer'] = 'v',
							['@function.outer'] = 'V',
							['@class.outer'] = '<c-v>',
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]A"] = "@parameter.inner",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[A"] = "@parameter.inner",
						},
					},
				},

				-- Folding based on treesitter
				fold = {
					enable = true,
				},
			})

			-- Set folding method to use treesitter
			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt.foldenable = false -- Don't fold by default

			-- Override the treesitter attach to prevent errors
			local ts_config = require("nvim-treesitter.configs")
			local original_attach = ts_config.attach_module
			
			ts_config.attach_module = function(module, bufnr)
				local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
				local problematic_langs = {
					-- Add any languages that cause issues on your system
				}
				
				for _, p_lang in ipairs(problematic_langs) do
					if lang == p_lang then
						return
					end
				end
				
				local success, err = pcall(original_attach, module, bufnr)
				if not success then
					return
				end
			end

			-- Toggle diagnostic messages
			local errors_hidden = false
			local function toggle_treesitter_errors()
				if errors_hidden then
					vim.diagnostic.config({
						virtual_text = true,
						signs = true,
						underline = true,
						update_in_insert = false,
						severity_sort = false,
					})
					errors_hidden = false
					print("Treesitter diagnostics enabled")
				else
					vim.diagnostic.config({
						virtual_text = false,
						signs = false,
						underline = false,
						update_in_insert = false,
						severity_sort = false,
					})
					errors_hidden = true
					print("Treesitter diagnostics hidden")
				end
			end

			-- Enhanced web development support
			local function enable_treesitter_for_web()
				local web_filetypes = {
					"html", "css", "scss", "less", "sass",
					"javascript", "typescript", "jsx", "tsx",
					"javascriptreact", "typescriptreact",
					"vue", "svelte", "astro", "mdx",
				}
				
				for _, ft in ipairs(web_filetypes) do
					vim.api.nvim_create_autocmd("FileType", {
						pattern = ft,
						callback = function(args)
							local success, _ = pcall(vim.treesitter.start, args.buf)
							if not success then
								vim.bo[args.buf].syntax = ft
							end
						end,
					})
				end
				print("Treesitter enabled for web development")
			end

			local function disable_treesitter_for_web()
				local web_filetypes = {
					"html", "css", "scss", "less", "sass",
					"javascript", "typescript", "jsx", "tsx",
					"javascriptreact", "typescriptreact",
					"vue", "svelte", "astro", "mdx",
				}
				
				for _, ft in ipairs(web_filetypes) do
					vim.api.nvim_create_autocmd("FileType", {
						pattern = ft,
						callback = function(args)
							vim.treesitter.stop(args.buf)
							vim.bo[args.buf].syntax = ft
						end,
					})
				end
				print("Treesitter disabled for web development")
			end

			-- Enable web languages on startup
			enable_treesitter_for_web()

			-- Keybindings
			vim.keymap.set('n', '<F12>', toggle_treesitter_errors, { desc = 'Toggle diagnostic messages' })
			vim.keymap.set('n', '<leader>te', enable_treesitter_for_web, { desc = 'Enable Tree-sitter for web files' })
			vim.keymap.set('n', '<leader>td', disable_treesitter_for_web, { desc = 'Disable Tree-sitter for web files' })
		end,
	},

	-- Enhanced auto-tag support for web development
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require('nvim-ts-autotag').setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
				per_filetype = {
					["html"] = { enable_close = true },
					["xml"] = { enable_close = true },
					["javascript"] = { enable_close = true },
					["typescript"] = { enable_close = true },
					["javascriptreact"] = { enable_close = true },
					["typescriptreact"] = { enable_close = true },
					["jsx"] = { enable_close = true },
					["tsx"] = { enable_close = true },
					["vue"] = { enable_close = true },
					["svelte"] = { enable_close = true },
					["astro"] = { enable_close = true },
					["php"] = { enable_close = true },
				}
			})
		end
	},

	-- Additional useful treesitter plugins for web development
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require('ts_context_commentstring').setup({
				enable_autocmd = false,
			})
			
			-- Integration with Comment.nvim if you use it
			local get_option = vim.filetype.get_option
			vim.filetype.get_option = function(filetype, option)
				return option == "commentstring"
					and require("ts_context_commentstring.internal").calculate_commentstring()
					or get_option(filetype, option)
			end
		end
	},
}
