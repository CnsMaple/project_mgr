-- main module file
local module = require("project_mgr.module")

---@class Config
---@field yd_app_dir string
local config = {}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.list = function()
  module.list_projects()
end

M.add = function()
  module.add_project()
end

M.add_current = function()
  module.add_project_current_dir()
end

return M
