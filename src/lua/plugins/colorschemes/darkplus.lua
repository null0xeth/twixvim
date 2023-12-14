return {
	{
		"martinsione/darkplus.nvim",
		name = "darkplus",
		priority = 1000,
		lazy = false,
		--opts = {},
		config = function()
			--require("darkplus").setup()
			vim.cmd.colorscheme("darkplus")
		end,
	},
}
