vim.api.nvim_create_user_command("LgToggle", function()
	require("lg").toggle()
end, {})
