---@class CustomModule
local M = {}
local Path = require("plenary.path")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local project_dir = vim.fn.stdpath("data") .. "/project_mgr"
local project_file = project_dir .. "/project.json"

-- Ensure the project directory and file exist
local function ensure_project_file()
  local dir_path = Path:new(project_dir)
  if not dir_path:exists() then
    dir_path:mkdir({ parents = true })
  end

  local file_path = Path:new(project_file)
  if not file_path:exists() then
    file_path:write("[]", "w")
    vim.notify("project_mgr: create a file: " .. file_path, vim.log.levels.INFO)
  end
end

-- Read projects from the project file
local function read_projects()
  ensure_project_file()
  local file = io.open(project_file, "r")
  local content = file:read("*a")
  file:close()
  return vim.fn.json_decode(content)
end

-- Write projects to the project file
local function write_projects(projects)
  ensure_project_file()
  local file = io.open(project_file, "w")
  file:write(vim.fn.json_encode(projects))
  file:close()
end

-- Add a new project
function M.add_project()
  local name = vim.fn.input("Project Name: ")
  local dir = vim.fn.input("Project Directory: ")
  local projects = read_projects()
  table.insert(projects, { name = name, dir = dir })
  write_projects(projects)
  vim.notify("project_mgr: add " .. name .. " success", vim.log.levels.INFO)
end

-- Delete a project
local function delete_project(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  local projects = read_projects()
  for i, project in ipairs(projects) do
    if project.name == selection.name and project.dir == selection.dir then
      table.remove(projects, i)
      vim.notify("project_mgr: remove " .. project.name .. " success", vim.log.levels.INFO)
      break
    end
  end
  write_projects(projects)
end

-- Edit a project
local function edit_project(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  local new_name = vim.fn.input("New Project Name: ", selection.name)
  local new_dir = vim.fn.input("New Project Directory: ", selection.dir)
  local projects = read_projects()
  for i, project in ipairs(projects) do
    if project.name == selection.name and project.dir == selection.dir then
      projects[i] = { name = new_name, dir = new_dir }
      break
    end
  end
  write_projects(projects)
  vim.notify("project_mgr: new name " .. new_name .. " new dir" .. new_dir, vim.log.levels.INFO)
end

-- Change directory to the selected project's directory
local function change_directory(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  vim.cmd("cd " .. selection.dir)
  vim.notify("Changed directory to " .. selection.dir, vim.log.levels.INFO)
end

-- List projects using Telescope
function M.list_projects()
  local projects = read_projects()
  pickers
    .new({}, {
      prompt_title = "Projects",
      finder = finders.new_table({
        results = projects,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name .. " (" .. entry.dir .. ")",
            ordinal = entry.name,
            name = entry.name,
            dir = entry.dir,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(_, map)
        map("n", "d", delete_project)
        map("n", "c", edit_project)
        map({ "n", "i" }, "<CR>", change_directory) -- Add this line to change directory on Enter
        return true
      end,
    })
    :find()
end

return M
