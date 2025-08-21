-- Windows-safe treesitter configuration with JS/TS/HTML enabled
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Windows compatibility settings
			require("nvim-treesitter.install").prefer_git = false
			require("nvim-treesitter.install").compilers = { "gcc", "clang", "cc" }
			
			require("nvim-treesitter.configs").setup({
				-- Install parsers including web languages
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"json",
					"yaml",
					"markdown",
					"javascript",
					"typescript",
					"python",
					"bash",
					"html",
					"css",
					"c",
					"cpp",
					"java",
					-- Additional web-related parsers
					"tsx",
				},

				sync_install = false,
				auto_install = false,
				
				-- Keep problematic parsers empty to allow JS/TS/HTML
				ignore_install = { 
				},

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "markdown" },
					
					-- Enable highlighting for web languages
					-- Remove any disable configuration for JS/TS/HTML
				},

				indent = {
					enable = true,
					-- Enable indent for web languages
					-- You can still disable specific ones if they cause issues:
					-- disable = { "html" }, -- uncomment if HTML indent causes problems
				},

				-- Enable other useful modules for web development
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},

				textobjects = {
					enable = true,
				},
			})

			-- Override the treesitter attach to prevent errors
			local ts_config = require("nvim-treesitter.configs")
			local original_attach = ts_config.attach_module
			
			ts_config.attach_module = function(module, bufnr)
				local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
				local problematic_langs = {
					-- Remove web languages from problematic list
					-- Only keep languages that actually cause issues on your system
				}
				
				-- Skip attachment for problematic languages
				for _, p_lang in ipairs(problematic_langs) do
					if lang == p_lang then
						return -- Skip attachment
					end
				end
				
				-- Try to attach safely
				local success, err = pcall(original_attach, module, bufnr)
				if not success then
					-- Log the error for debugging if needed
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
				else
					vim.diagnostic.config({
						virtual_text = false,
						signs = false,
						underline = false,
						update_in_insert = false,
						severity_sort = false,
					})
					errors_hidden = true
				end
			end

			-- Function to enable treesitter for web languages
			local function enable_treesitter_for_web()
				local web_filetypes = {
					"html", "css", "javascript", "typescript",
					"javascriptreact", "typescriptreact", "tsx",
				}
				
				for _, ft in ipairs(web_filetypes) do
					vim.api.nvim_create_autocmd("FileType", {
						pattern = ft,
						callback = function(args)
							-- Ensure treesitter is enabled for this buffer
							local success, _ = pcall(vim.treesitter.start, args.buf)
							if not success then
								-- Fallback to syntax highlighting if treesitter fails
								vim.bo[args.buf].syntax = ft
							end
						end,
					})
				end
				
			end

			-- Function to disable treesitter for web languages (keep for toggling)
			local function disable_treesitter_for_web()
				local web_filetypes = {
					"html", "css", "javascript", "typescript",
					"javascriptreact", "typescriptreact"
				}
				
				for _, ft in ipairs(web_filetypes) do
					vim.api.nvim_create_autocmd("FileType", {
						pattern = ft,
						callback = function(args)
							-- Disable treesitter for this buffer
							vim.treesitter.stop(args.buf)
							-- Use basic syntax highlighting instead
							vim.bo[args.buf].syntax = ft
						end,
					})
				end
				
			end

			-- Enable web languages on startup (changed from disable to enable)
			enable_treesitter_for_web()

			-- Keybindings
			vim.keymap.set('n', '<F12>', toggle_treesitter_errors, { desc = 'Toggle diagnostic messages' })
			vim.keymap.set('n', '<leader>te', enable_treesitter_for_web, { desc = 'Enable Tree-sitter for web files' })
			vim.keymap.set('n', '<leader>td', disable_treesitter_for_web, { desc = 'Disable Tree-sitter for web files' })
		end,
	},

	-- Enable ts-autotag for better HTML/JSX experience
	{
		"windwp/nvim-ts-autotag",
		enabled = true, -- Changed from false to true
		config = function()
			require('nvim-ts-autotag').setup({
				opts = {
					-- Defaults
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = false -- Auto close on trailing </
				},
				-- Also enable for additional filetypes if needed
				per_filetype = {
					["html"] = {
						enable_close = true
					},
					["javascript"] = {
						enable_close = true
					},
					["typescript"] = {
						enable_close = true
					},
					["javascriptreact"] = {
						enable_close = true
					},
					["typescriptreact"] = {
						enable_close = true
					},
				}
			})
		end
	},
}
