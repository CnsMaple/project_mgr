-- main module file
local module = require("project_mgr.module")

local function select_result(fn)
  -- 调用 vim.ui.select 函数
  local items = module.show_list_projects()

  vim.ui.select(items, {
    prompt = "请选择一个选项:", -- 提示信息
    format_item = function(item)
      return item
    end, -- 可选：格式化显示每个选项的方式
  }, function(choice)
    if choice then
      fn(choice)
    else
      vim.notify("project_mgr: no choice", vim.log.levels.INFO)
    end
  end)
end

---@class Config
---@field enabled_xbot_robot boolean
local config = {
  enabled_xbot_robot = false,
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  -- 如果当前目录存在 xbot_robot 目录，那就读取这个目录下的package.json文件，然后jason里面的name字段作为项目名称，当前目录作为项目路径，添加到项目列表中
  if M.config.enabled_xbot_robot then
    module.add_xbot_robot_project()
  end
end

M.list = function()
  select_result(module.change_directory)
end

M.add = function()
  module.add_project()
end

M.edit = function()
  select_result(module.edit_project)
end

M.edit_current = function()
  module.edit_project_current_dir()
end

M.delete = function()
  select_result(module.delete_project)
end

M.delete_current = function()
  module.delete_project_current_dir()
end

M.add_current = function()
  module.add_project_current_dir()
end

return M
