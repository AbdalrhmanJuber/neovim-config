# LSP Configuration Guide

This Neovim configuration includes enhanced LSP support with comprehensive debugging and management tools.

## Supported Language Servers

- **ts_ls** - TypeScript/JavaScript Language Server
- **eslint** - ESLint Language Server  
- **lua_ls** - Lua Language Server
- **html** - HTML Language Server
- **cssls** - CSS Language Server
- **jsonls** - JSON Language Server

## LSP Keybindings

### Navigation & Information
- `gd` - Go to definition
- `gD` - Go to declaration  
- `K` - Show hover information
- `gi` - Go to implementation
- `gr` - Show references
- `<C-k>` - Show signature help

### Code Actions & Editing
- `<leader>rn` - Rename symbol
- `<leader>ca` - Show code actions
- `<leader>f` - Format buffer

### LSP Management & Debugging
- `<leader>ls` - Show detailed LSP status
- `<leader>lr` - Restart LSP servers for current buffer
- `<leader>lR` - Restart all LSP servers
- `<leader>li` - Show LspInfo
- `<leader>lI` - Show Mason package manager
- `<leader>lh` - Show LSP help and all keybindings

### Advanced Debugging
- `<leader>ld` - Diagnose LSP attachment issues
- `<leader>lc` - Check server installation status
- `<leader>lt` - Create test TypeScript project
- `<leader>lrt` - Reinstall TypeScript server
- `<leader>lre` - Reinstall ESLint server

## Troubleshooting TypeScript Issues

If TypeScript LSP is not working:

1. **Check Server Status**: Use `<leader>ls` to see if ts_ls is attached
2. **Verify Installation**: Use `<leader>lc` to check if servers are installed
3. **Create Test Project**: Use `<leader>lt` to create a test TypeScript project
4. **Force Restart**: Use `<leader>lR` to restart all servers
5. **Diagnose Issues**: Use `<leader>ld` for detailed diagnosis
6. **Reinstall Server**: Use `<leader>lrt` to reinstall TypeScript server

## Features

### Enhanced TypeScript Support
- Inlay hints for parameters, types, and return values
- Enhanced completion with import suggestions
- Proper project root detection (package.json, tsconfig.json, .git)
- Automatic server attachment for .ts, .js, .tsx, .jsx files

### Safe ESLint Integration  
- No vim.fs.concat usage to prevent crashes
- Auto-fix on save functionality
- Comprehensive rule customization support

### Comprehensive Debugging
- Server attachment/detachment notifications
- Detailed capability reporting for each server
- Installation status checking
- Automatic diagnostic collection

### Smart Server Management
- Automatic server restart on configuration reload
- Manual restart capabilities per buffer or globally
- Test project creation for debugging
- Server reinstallation utilities

## Auto-Installation

All required language servers are automatically installed via Mason when you first start Neovim. If servers fail to install, use `:Mason` to manually install them.

## Project Structure Requirements

For best TypeScript/JavaScript support, ensure your project has:
- `package.json` - For dependency management
- `tsconfig.json` or `jsconfig.json` - For TypeScript configuration
- `.eslintrc.*` files - For ESLint configuration (optional)

## Common Issues & Solutions

**Issue: "No LSP clients attached"**
- Solution: Check filetype with `:set filetype?`
- Use `<leader>ld` to diagnose the issue
- Try `:LspStart ts_ls` manually

**Issue: "ESLint crashes with vim.fs.concat error"** 
- Solution: This is fixed in the new configuration
- ESLint now uses safe lspconfig.util functions

**Issue: "TypeScript server shows as 'Enabled' but not 'Active'"**
- Solution: This is fixed with enhanced attachment logic
- Servers are now force-started for .ts/.js files
- Use `<leader>lR` to restart if needed

**Issue: "LSP keybindings don't work"**
- Solution: Keybindings are only active when LSP is attached
- Use `<leader>ls` to check if servers are attached
- Try `<leader>lr` to restart server for current buffer

## Performance Notes

- Servers start automatically when opening supported file types
- Lazy loading prevents startup delays
- Enhanced root detection improves project support
- Diagnostic updates are optimized for performance