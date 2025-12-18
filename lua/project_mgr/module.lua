---@class CustomModule
local M = {}
local Path = require("plenary.path")

local project_dir = vim.fn.stdpath("data") .. "/project_mgr"
local project_file = project_dir .. "/project.json"
-- local now_project = nil

-- Ensure the project directory and file exist
local function ensure_project_file()
  local dir_path = Path:new(project_dir)
  if not dir_path:exists() then
    dir_path:mkdir({ parents = true })
  end

  local file_path = Path:new(project_file)
  if not file_path:exists() then
    file_path:write("[]", "w")
    vim.notify("project_mgr: created file: " .. project_file, vim.log.levels.INFO)
  end
end

-- Read projects from the project file
local function read_projects()
  ensure_project_file()
  local file = io.open(project_file, "r")
  if file == nil then
    return {}
  end
  local content = file:read("*a")
  file:close()
  return vim.fn.json_decode(content)
end

-- Write projects to the project file
local function write_projects(dir, name, cul)
  local projects = read_projects()

  local find_flag = false
  for i, project in ipairs(projects) do
    if project.dir == dir then
      if cul == "edit" then
        if project.name == name then
          return
        end
        projects[i] = { name = name, dir = dir }
        vim.notify("project_mgr: updated successfully", vim.log.levels.INFO)
      elseif cul == "delete" then
        table.remove(projects, i)
        vim.notify("project_mgr: removed successfully", vim.log.levels.INFO)
      else
        error("Unknown operation: " .. cul)
        return
      end
      find_flag = true
      break
    end
  end

  if not find_flag and cul == "edit" then
    table.insert(projects, { name = name, dir = dir })
    vim.notify("project_mgr: updated successfully", vim.log.levels.INFO)
  end

  local file = io.open(project_file, "w")
  if file == nil then
    error("Failed to write projects to file")
    return
  end

  file:write(vim.fn.json_encode(projects))
  file:close()
end

-- Add a new project
function M.add_project()
  local name = vim.fn.input("Project Name: ")
  if name == "" then
    vim.notify("project_mgr: Project name cannot be empty", vim.log.levels.ERROR)
    return
  end
  local dir = vim.fn.input("Project Directory: ")
  if dir == "" then
    vim.notify("project_mgr: Project directory cannot be empty", vim.log.levels.ERROR)
    return
  end
  write_projects(dir, name, "edit")
end

-- Add a new project on current dir
function M.add_project_current_dir()
  local name = vim.fn.input("Project Name: ")
  if name == "" then
    vim.notify("project_mgr: Project name cannot be empty", vim.log.levels.ERROR)
    return
  end
  local dir = vim.fn.getcwd() -- Get the current working directory
  write_projects(dir, name, "edit")
end

-- Delete a project
function M.delete_project(selected)
  local dir = selected:match("%((.-)%)")
  local name = selected:match("^(.-)%(")
  write_projects(dir, name, "delete")
end

function M.delete_project_current_dir()
  local dir = vim.fn.getcwd() -- Get the current working directory
  write_projects(dir, "", "delete")
end

-- Edit a project
function M.edit_project_current_dir()
  local dir = vim.fn.getcwd() -- Get the current working directory
  local name = "new"
  local new_name = vim.fn.input("New Project Name: ", name)
  if new_name == "" then
    new_name = name
    vim.notify("project_mgr: Project name use pre", vim.log.levels.INFO)
    return
  end
  write_projects(dir, new_name, "edit")
end

-- Edit a project
function M.edit_project(selected)
  local dir = selected:match("%((.-)%)")
  local name = selected:match("^(.-)%(")
  local new_name = vim.fn.input("New Project Name: ", name)
  if new_name == "" then
    new_name = name
    vim.notify("project_mgr: Project name use pre", vim.log.levels.INFO)
    return
  end
  local new_dir = vim.fn.input("New Project Directory: ", dir)
  if new_dir == "" then
    new_dir = dir
    vim.notify("project_mgr: Project directory use pre", vim.log.levels.INFO)
    return
  end
  write_projects(new_dir, new_name, "edit")
end

-- Change directory to the selected project's directory
function M.change_directory(selected)
  local dir = selected:match("%((.-)%)")
  vim.cmd("cd " .. dir)
  vim.notify("Changed directory to " .. dir, vim.log.levels.INFO)
end

-- List projects using Telescope
function M.show_list_projects()
  local projects = read_projects()
  local project_list = {}
  if projects == nil then
    return {}
  end
  for _, project in ipairs(projects) do
    table.insert(project_list, project.name .. "(" .. project.dir .. ")")
  end
  return project_list
end

-- 获取现在的目录配置名字
function M.get_now_project_name(dir_name)
  local projects = read_projects()
  for i, project in ipairs(projects) do
    if project.dir == dir_name then
      return project.name
    end
  end
  return nil
end

-- 获取现在的目录配置名字
function M.get_now_project_dir(name)
  local projects = read_projects()
  for i, project in ipairs(projects) do
    if project.name == name then
      return project.dir
    end
  end
  return nil
end

function M.add_xbot_robot_project()
  local dir = vim.fn.getcwd() -- Get the current working directory
  local package_json_path = dir .. "/xbot_robot/package.json"
  if vim.fn.filereadable(package_json_path) == 1 then
    local content = vim.fn.readfile(package_json_path)
    local json = vim.fn.json_decode(content)
    local name = json.name

    write_projects(dir, name, "edit")
  end
end

return M
