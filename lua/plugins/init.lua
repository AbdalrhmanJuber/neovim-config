-- Main plugin list - imports all plugin modules
return {
	-- Import all plugin configurations
	{ import = "plugins.lsp" },
	{ import = "plugins.completion" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.ui" },
	{ import = "plugins.editor" },
	{ import = "plugins.tools" },
}
