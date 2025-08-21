-- Windows-safe treesitter configuration
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
				-- Only install parsers that work reliably on Windows
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"json",
					"yaml",
					"markdown",
				},

				sync_install = false,
				auto_install = false,
				
				-- Completely ignore problematic parsers
				ignore_install = { 
					"html", "css", "javascript", "typescript", 
					"tsx", "jsx", "cpp", "c" 
				},

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "markdown" },
					
					-- Disable highlighting for web languages entirely
					disable = { 
						"html", "css", "javascript", "typescript", 
						"javascriptreact", "typescriptreact",
						"tsx", "jsx", "cpp", "c"
					},
				},

				indent = {
					enable = true,
					-- Disable indent for problematic languages
					disable = { 
						"python", "yaml", "html", "css", 
						"javascript", "typescript" 
					},
				},
			})

			-- Override the treesitter attach to prevent errors
			local ts_config = require("nvim-treesitter.configs")
			local original_attach = ts_config.attach_module
			
			ts_config.attach_module = function(module, bufnr)
				local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
				local problematic_langs = {
					"html", "css", "javascript", "typescript",
					"tsx", "jsx", "cpp", "c"
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
					-- Silently fail for now
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
					vim.notify("Diagnostic messages shown", vim.log.levels.INFO)
					errors_hidden = false
				else
					vim.diagnostic.config({
						virtual_text = false,
						signs = false,
						underline = false,
						update_in_insert = false,
						severity_sort = false,
					})
					vim.notify("Diagnostic messages hidden", vim.log.levels.INFO)
					errors_hidden = true
				end
			end

			-- Alternative: Completely disable treesitter for specific filetypes
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

			-- Auto-disable on startup
			disable_treesitter_for_web()

			-- Keybindings
			vim.keymap.set('n', '<F12>', toggle_treesitter_errors, { desc = 'Toggle diagnostic messages' })
			vim.keymap.set('n', '<leader>td', disable_treesitter_for_web, { desc = 'Disable Tree-sitter for web files' })
		end,
	},

	-- Keep ts-autotag disabled
	{
		"windwp/nvim-ts-autotag",
		enabled = false,
	},
}
