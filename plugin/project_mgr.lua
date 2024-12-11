vim.api.nvim_create_user_command("ProjetctMgrList", require("project_mgr").list, {})

vim.api.nvim_create_user_command("ProjetctMgrAdd", require("project_mgr").add, {})

vim.api.nvim_create_user_command("ProjetctMgrAddCurrent", require("project_mgr").add_current, {})
