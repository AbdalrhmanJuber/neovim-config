-- Main entry point - keep this minimal
require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.filetypes")
vim.cmd([[colorscheme tokyonight-night]])
-- vim.cmd("colorscheme rose-pine")

-- vim.cmd("colorscheme vague")

-- vim.cmd[[colorscheme solarized-osaka]]

-- vim.cmd.colorscheme("catppuccin-mocha")
vim.opt.shadafile = vim.fn.stdpath("data") .. "/shada/main_alt.shada"
