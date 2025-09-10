-- File type detection for EJS files
vim.filetype.add({
  extension = {
    ejs = 'html', -- Treat .ejs files as HTML
  },
})

-- Enhanced EJS support with embedded JavaScript
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.ejs",
  callback = function()
    vim.bo.filetype = "html"
    vim.bo.syntax = "html"
    
    -- Enable HTML auto-completion and formatting
    vim.bo.omnifunc = "htmlcomplete#CompleteTags"
  end,
})
