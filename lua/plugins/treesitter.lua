-- Minimal treesitter configuration for Windows
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
				-- Only install the most stable parsers
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query", -- Core parsers
					"css",
					"json",
					"yaml",
					"markdown", -- Safe parsers
					"typescript",
					"javascript",
				},

				sync_install = true,
				auto_install = false,
				ignore_install = { "html", "cpp", "c" }, -- Ignore problematic ones

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "markdown" },
					-- Disable for problematic file types
					disable = { "javascript", "html", "jsx", "tsx" },
				},

				indent = {
					enable = true,
					disable = { "python", "javascript", "html" },
				},
			})

			-- Toggle to completely remove/show error messages
			local errors_hidden = false

			local function toggle_treesitter_errors()
				if errors_hidden then
					-- Show errors by enabling virtual text and signs
					vim.diagnostic.config({
						virtual_text = true,
						signs = true,
						underline = true,
						update_in_insert = false,
						severity_sort = false,
					})
					vim.notify("Tree-sitter error messages shown", vim.log.levels.INFO)
					errors_hidden = false
				else
					-- Hide errors by disabling virtual text and signs completely
					vim.diagnostic.config({
						virtual_text = false,  -- This removes the text completely
						signs = false,         -- This removes the error signs/icons
						underline = false,     -- This removes underlines
						update_in_insert = false,
						severity_sort = false,
					})
					vim.notify("Tree-sitter error messages hidden", vim.log.levels.INFO)
					errors_hidden = true
				end
			end

			-- Set keybinding
			vim.keymap.set('n', '<F12>', toggle_treesitter_errors, { desc = 'Toggle Tree-sitter error messages' })

			-- Alternative: If you want to permanently disable error messages, uncomment this:
			-- vim.diagnostic.config({ virtual_text = false, signs = false })
		end,
	},

	-- Disable ts-autotag temporarily
	{
		"windwp/nvim-ts-autotag",
		enabled = false, -- Disable until treesitter is stable
	},
}
