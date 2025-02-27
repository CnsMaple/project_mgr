-- main module file
local module = require("project_mgr.module")
-- local fzf_lua = require("fzf-lua")
-- local utils = require("fzf-lua.utils")

local function select_result(fn)
  -- 调用 vim.ui.select 函数
  local items = module.list_projects()

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
  select_result(module.change_directory)
  --
  -- fzf_lua.fzf_exec(items, {
  --   prompt = "project list> ",
  --   fzf_opts = {
  --     ["--header"] = string.format(
  --       ":: <%s> to %s | <%s> to %s",
  --       ansi_from_hl("FzfLuaHeaderBind", "ctrl-d"),
  --       ansi_from_hl("FzfLuaHeaderText", "delete"),
  --       ansi_from_hl("FzfLuaHeaderBind", "ctrl-e"),
  --       ansi_from_hl("FzfLuaHeaderText", "edit")
  --     ),
  --   },
  --   fzf_colors = true,
  --   actions = {
  --     -- print(selected[1])
  --     -- vim.notify(selected[0] .. selected[1] .. "yees")
  --     ["default"] = {
  --       function(selected)
  --         module.change_directory(selected[1])
  --         vim.api.nvim_win_close(0, false)
  --       end,
  --     },
  --     ["ctrl-d"] = function(selected)
  --       local path = selected[1]
  --       local choice = vim.fn.confirm("Delete '" .. path .. "' project? ", "&Yes\n&No")
  --       if choice == 1 then
  --         module.delete_project(path)
  --       end
  --     end,
  --     ["ctrl-e"] = function(selected)
  --       module.edit_project(selected[1])
  --     end,
  --   },
  -- })
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
