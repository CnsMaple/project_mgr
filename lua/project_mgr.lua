-- main module file
local module = require("project_mgr.module")
local fzf_lua = require("fzf-lua")
local utils = require("fzf-lua.utils")

local function hl_validate(hl)
  return not utils.is_hl_cleared(hl) and hl or nil
end

local function ansi_from_hl(hl, s)
  return utils.ansi_from_hl(hl_validate(hl), s)
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
  local items = module.list_projects()

  fzf_lua.fzf_exec(items, {
    prompt = "project list> ",
    fzf_opts = {
      ["--header"] = string.format(
        ":: <%s> to %s | <%s> to %s",
        ansi_from_hl("FzfLuaHeaderBind", "ctrl-d"),
        ansi_from_hl("FzfLuaHeaderText", "delete"),
        ansi_from_hl("FzfLuaHeaderBind", "ctrl-e"),
        ansi_from_hl("FzfLuaHeaderText", "edit")
      ),
    },
    fzf_colors = true,
    actions = {
      -- print(selected[1])
      -- vim.notify(selected[0] .. selected[1] .. "yees")
      ["default"] = {
        function(selected)
          module.change_directory(selected[1])
          vim.api.nvim_win_close(0, false)
        end,
      },
      ["ctrl-d"] = function(selected)
        local path = selected[1]
        local choice = vim.fn.confirm("Delete '" .. path .. "' project? ", "&Yes\n&No")
        if choice == 1 then
          module.delete_project(path)
        end
      end,
      ["ctrl-e"] = function(selected)
        module.edit_project(selected[1])
      end,
    },
  })
end

M.add = function()
  module.add_project()
end

M.add_current = function()
  module.add_project_current_dir()
end

return M
