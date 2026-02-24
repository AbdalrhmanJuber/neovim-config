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

local function disable_all_underlines_except_diagnostics()
  for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
    -- keep diagnostic underlines
    if name:match("^DiagnosticUnderline") then
      goto continue
    end

    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
    if ok and hl and (hl.underline or hl.undercurl) then
      hl.underline = false
      hl.undercurl = false
      vim.api.nvim_set_hl(0, name, hl)
    end

    ::continue::
  end
end

-- run once
disable_all_underlines_except_diagnostics()

-- reapply after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = disable_all_underlines_except_diagnostics,
})

-- reapply after LSP attaches (LSP re-adds highlights)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.defer_fn(disable_all_underlines_except_diagnostics, 100)
  end,
})
vim.opt.shadafile = vim.fn.stdpath("data") .. "/shada/main_alt.shada"
