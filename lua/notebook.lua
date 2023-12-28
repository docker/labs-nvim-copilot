local _2afile_2a = "fnl/notebook.fnl"
local _2amodule_name_2a = "notebook"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local core, nvim, string = autoload("aniseed.core"), autoload("aniseed.nvim"), autoload("aniseed.string")
do end (_2amodule_locals_2a)["core"] = core
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["string"] = string
--[[ (vim.api.nvim_list_tabpages) (vim.api.nvim_get_current_tabpage) (vim.api.nvim_tabpage_set_var 2 "id" "notebook") (vim.api.nvim_tabpage_get_var 2 "id") (vim.api.nvim_tabpage_get_number 2) (vim.api.nvim_tabpage_get_win 2) (vim.api.nvim_tabpage_list_wins 0) (vim.api.nvim_set_current_tabpage 2) ]]
local docker_notebook = {count = 0, streaming = nil}
local function new_cell_3f(s)
  local streaming = docker_notebook.streaming
  return (not streaming or not (s == streaming))
end
_2amodule_2a["new-cell?"] = new_cell_3f
local function now_streaming(s)
  docker_notebook["streaming"] = s
  return nil
end
_2amodule_2a["now-streaming"] = now_streaming
local function add_cell_buffer()
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(bufnr, core.str("./cells/", docker_notebook.count))
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), bufnr)
  local function _1_()
    return vim.api.nvim_cmd({cmd = "filetype", args = {"detect"}}, {})
  end
  vim.api.nvim_buf_call(bufnr, _1_)
  docker_notebook = core.assoc(docker_notebook, "winnr", vim.api.nvim_get_current_win(), "count", core.inc(docker_notebook.count))
  return bufnr
end
_2amodule_2a["add-cell-buffer"] = add_cell_buffer
local function notebook_create()
  vim.api.nvim_cmd({cmd = "tabnew"}, {})
  local tab_nr = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_tabpage_set_var(tab_nr, "id", "notebook")
  docker_notebook = core.assoc(docker_notebook, "nr", tab_nr)
  return nil
end
_2amodule_2a["notebook-create"] = notebook_create
local function notebook_add_cell()
  if not docker_notebook.nr then
    notebook_create()
    return add_cell_buffer()
  else
    vim.api.nvim_set_current_tabpage(docker_notebook.nr)
    if docker_notebook.winnr then
      vim.api.nvim_set_current_win(docker_notebook.winnr)
    else
    end
    local buf_nr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_cmd({cmd = "sp"}, {})
    return add_cell_buffer()
  end
end
_2amodule_2a["notebook-add-cell"] = notebook_add_cell
local function append_to_cell(s, filetype)
  local bufnr = vim.api.nvim_win_get_buf(docker_notebook.winnr)
  local content = string.join("\n", vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, string.split(core.str(content, s), "\n"))
  local function _4_()
    vim.bo.filetype = filetype
    return nil
  end
  return vim.api.nvim_buf_call(bufnr, _4_)
end
_2amodule_2a["append-to-cell"] = append_to_cell
local function show_tab_window_buffer()
  return core.println(core.str(vim.api.nvim_get_current_tabpage(), "-", vim.api.nvim_get_current_win(), "-", vim.api.nvim_get_current_buf(), "\n", vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()), "\n", docker_notebook))
end
_2amodule_2a["show-tab-window-buffer"] = show_tab_window_buffer
vim.api.nvim_create_user_command("NotebookAddCell", notebook_add_cell, {nargs = 0})
vim.api.nvim_create_user_command("NotebookCoordinates", show_tab_window_buffer, {nargs = 0})
local function flush_function_call()
  if docker_notebook["current-function-call"] then
    do
      local _let_5_ = docker_notebook["current-function-call"]
      local name = _let_5_["name"]
      local args = _let_5_["arguments"]
      local arguments
      if core["table?"](args) then
        arguments = args
      else
        arguments = vim.json.decode(args)
      end
      if ((name == "cell-execution") or (name == "suggest-command")) then
        notebook_add_cell()
        append_to_cell(arguments.command, "shellscript")
      elseif (name == "update-file") then
        notebook_add_cell()
        append_to_cell(core.str("not complete"), "markdown")
      elseif (name == "show-notification") then
        local _let_7_ = arguments
        local level = _let_7_["level"]
        local message = _let_7_["message"]
        vim.api.nvim_notify(message, vim.log.levels.INFO, {})
      elseif (name == "create-notebook") then
        local _let_8_ = arguments
        local notebook = _let_8_["notebook"]
        local cells = _let_8_["cells"]
        for _, _9_ in pairs(cells.cells) do
          local _each_10_ = _9_
          local kind = _each_10_["kind"]
          local value = _each_10_["value"]
          local language_id = _each_10_["languageId"]
          notebook_add_cell()
          if (kind == 1) then
            append_to_cell(value, "markdown")
          else
            append_to_cell(value, language_id)
          end
        end
      else
      end
    end
    docker_notebook["current-function-call"] = nil
    return nil
  else
    return nil
  end
end
_2amodule_2a["flush-function-call"] = flush_function_call
local function docker_ai_content_handler(extension_id, message)
  if message.content then
    if new_cell_3f("content") then
      notebook_add_cell()
      now_streaming("content")
      flush_function_call()
    else
    end
    return append_to_cell(message.content, "markdown")
  elseif message.complete then
    now_streaming(nil)
    return flush_function_call()
  else
    local _15_
    do
      local call_name = message.function_call.name
      _15_ = (call_name == "show-notification")
    end
    if _15_ then
      local function_call_name = message.function_call.name
      if new_cell_3f(function_call_name) then
        now_streaming(function_call_name)
        flush_function_call()
      else
      end
      docker_notebook = core.assoc(docker_notebook, "current-function-call", message.function_call)
      return nil
    elseif message.function_call.name then
      local function_call_name = message.function_call.name
      if new_cell_3f(function_call_name) then
        now_streaming(function_call_name)
        flush_function_call()
      else
      end
      docker_notebook = core.assoc(docker_notebook, "current-function-call", message.function_call)
      return nil
    else
      local function _19_()
        local _let_18_ = message.function_call
        local name = _let_18_["name"]
        local arguments = _let_18_["arguments"]
        return (arguments and not name)
      end
      if (message.function_call and _19_()) then
        local current_function_call = docker_notebook["current-function-call"]
        local _let_20_ = message.function_call
        local name = _let_20_["name"]
        local arguments = _let_20_["arguments"]
        docker_notebook = core.assoc(docker_notebook, "current-function-call", core.assoc(current_function_call, "arguments", core.str(current_function_call.arguments, arguments)))
        return nil
      else
        notebook_add_cell()
        return append_to_cell(vim.json.encode(message), "json")
      end
    end
  end
end
_2amodule_2a["docker-ai-content-handler"] = docker_ai_content_handler
--[[ (core.println docker-notebook) (docker-ai-content-handler nil {:content "some content"}) (docker-ai-content-handler nil {:content "
some more content"}) (docker-ai-content-handler nil {:complete true}) (docker-ai-content-handler nil {:function_call {:arguments {:level "INFO" :message "test message"} :name "show-notification"}}) (docker-ai-content-handler nil {:complete true}) (core.println docker-notebook) (docker-ai-content-handler nil {:function_call {:arguments "" :name "cell-execution"}}) (docker-ai-content-handler nil {:function_call {:arguments (vim.json.encode {:command "docker build"})}}) (docker-ai-content-handler nil {:complete true}) (docker-ai-content-handler nil {:function_call {:arguments {:cells {:cells [{:kind 1 :value "Some Content"} {:kind 2 :languageId "shellscript" :value "touch .dockerignore"}]}} :name "create-notebook"}}) (docker-ai-content-handler nil {:complete true}) ]]
return _2amodule_2a