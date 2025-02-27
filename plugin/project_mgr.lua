vim.api.nvim_create_user_command("ProjetctMgrList", require("project_mgr").list, {})

vim.api.nvim_create_user_command("ProjetctMgrAdd", require("project_mgr").add, {})

vim.api.nvim_create_user_command("ProjetctMgrAddCurrent", require("project_mgr").add_current, {})

vim.api.nvim_create_user_command("ProjetctMgrEdit", require("project_mgr").edit, {})

vim.api.nvim_create_user_command("ProjetctMgrEditCurrent", require("project_mgr").edit_current, {})

vim.api.nvim_create_user_command("ProjetctMgrDel", require("project_mgr").delete, {})

vim.api.nvim_create_user_command("ProjetctMgrDelCurrent", require("project_mgr").delete_current, {})
