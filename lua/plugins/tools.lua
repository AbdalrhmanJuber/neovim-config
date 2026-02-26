-- Development tools and utilities
return {
	-- GitHub Copilot
	{
		"github/copilot.vim",
		cmd = { "Copilot" }, -- load only when you call a Copilot command
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_proxy_strict_ssl = false

			-- Start with Copilot disabled
			vim.g.copilot_enabled = false

			-- Accept suggestion
			vim.keymap.set("i", "<C-Z>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})

			-- Enable / Disable / Toggle
			vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", {
				desc = "Enable Copilot",
				silent = true,
			})
			vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", {
				desc = "Disable Copilot",
				silent = true,
			})
			vim.keymap.set("n", "<leader>ct", function()
				local enabled = vim.fn["copilot#Enabled"]() == 1

				if enabled then
					vim.cmd("Copilot disable")
					print("Copilot disabled")
				else
					vim.cmd("Copilot enable")
					print("Copilot enabled")
				end
			end, {
				desc = "Toggle Copilot",
				silent = true,
			})

			-- Filetypes (all off by default, selectively enabled later)
			vim.g.copilot_filetypes = {
				["*"] = false,
				javascript = true,
				typescript = true,
				lua = true,
				rust = true,
				c = true,
				["c#"] = true,
				["c++"] = true,
				go = true,
				python = true,
				html = true,
				css = true,
				scss = true,
				json = true,
				yaml = true,
				markdown = true,
			}
		end,
	},
	-- Emmet
	{
		"mattn/emmet-vim",
		ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "blade" },
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" }, -- Load earlier instead of just BufWritePre
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ 
						lsp_fallback = false,
						timeout_ms = 3000,
					})
				end,
				desc = "[F]ormat file",
			},
		},
		opts = {
			format_on_save = false,
			formatters_by_ft = {
				html = { "prettier" },
				css = { "prettier" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "black" },

				-- ✅ Laravel
				php = { "php_cs_fixer" },
				blade = { "blade_formatter" },
				cpp = { "clang_format" },
				c = { "clang_format" },
				vue = { "prettier" },
				["*"] = { "trim_whitespace" },
			},
			formatters = {
				blade_formatter = {
					command = "blade-formatter",
					args = {
						"--stdin"
					},
					stdin = true,
				},

				php_cs_fixer = {
					command = "php-cs-fixer",
					args = {
						"fix",
						"--using-cache=no",
						"--quiet",
						"$FILENAME",
					},
					stdin = false,
				},
			},
		},
	},

	-- Tailwind tools
	{
		"luckasRanarison/tailwind-tools.nvim",
		ft = { "html", "css","blade", "vue", "javascript", "typescript", "javascriptreact", "typescriptreact" },
		config = function()
			require("tailwind-tools").setup({
				color_enabled = true,
				color_mode = "background",
			})
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Trouble
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{ "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		},
	},
}
