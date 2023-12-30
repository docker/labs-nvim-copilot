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
local complaints, core, nvim, string = autoload("complaints"), autoload("aniseed.core"), autoload("aniseed.nvim"), autoload("aniseed.string")
do end (_2amodule_locals_2a)["complaints"] = complaints
_2amodule_locals_2a["core"] = core
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
local function configure_buffer(bufnr)
  vim.api.nvim_buf_set_name(bufnr, core.str("./cells/", docker_notebook.count))
  docker_notebook = core.assoc(docker_notebook, "count", core.inc(docker_notebook.count))
  local function _1_()
    return vim.api.nvim_cmd({cmd = "filetype", args = {"detect"}}, {})
  end
  vim.api.nvim_buf_call(bufnr, _1_)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nowrite")
  vim.api.nvim_buf_set_option(bufnr, "wrap", true)
  return bufnr
end
_2amodule_2a["configure-buffer"] = configure_buffer
local function add_cell_buffer()
  local bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), bufnr)
  return configure_buffer(bufnr)
end
_2amodule_2a["add-cell-buffer"] = add_cell_buffer
local function notebook_create()
  vim.api.nvim_cmd({cmd = "tabnew"}, {})
  local tab_nr = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_tabpage_set_var(tab_nr, "id", "notebook")
  docker_notebook = core.assoc(docker_notebook, "nr", tab_nr, "winnr", vim.api.nvim_get_current_win())
  local bufnr = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
  vim.api.nvim_buf_set_option(bufnr, "buflisted", false)
  return bufnr
end
_2amodule_2a["notebook-create"] = notebook_create
local function notebook_add_cell(_2_)
  local _arg_3_ = _2_
  local path = _arg_3_["path"]
  local language_id = _arg_3_["language-id"]
  local opts = _arg_3_
  if (not docker_notebook.nr or not vim.api.nvim_tabpage_is_valid(docker_notebook.nr)) then
    local bufnr = notebook_create()
    if (path and language_id) then
      vim.api.nvim_cmd({cmd = "edit", args = {path}}, {})
    else
      configure_buffer(bufnr)
    end
    return bufnr
  else
    if docker_notebook.winnr then
      vim.api.nvim_set_current_win(docker_notebook.winnr)
      vim.api.nvim_cmd({cmd = "sp"}, {})
      docker_notebook = core.assoc(docker_notebook, "winnr", vim.api.nvim_get_current_win())
      if (path and language_id) then
        vim.api.nvim_cmd({cmd = "edit", args = {path}}, {})
        return vim.api.nvim_get_current_buf()
      else
        return add_cell_buffer()
      end
    else
      return nil
    end
  end
end
_2amodule_2a["notebook-add-cell"] = notebook_add_cell
local function bottom_terminal(cmd)
  local current_win = nvim.tabpage_get_win(0)
  local original_buf = nvim.win_get_buf(current_win)
  local term_buf = nvim.create_buf(false, true)
  vim.cmd("split")
  local new_win = nvim.tabpage_get_win(0)
  nvim.win_set_buf(new_win, term_buf)
  return nvim.fn.termopen(cmd)
end
_2amodule_2a["bottom-terminal"] = bottom_terminal
local function runBuffer()
  local bufnr = vim.api.nvim_get_current_buf()
  return bottom_terminal(string.join("\n", vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)))
end
_2amodule_2a["runBuffer"] = runBuffer
local function make_buf_runnable()
  local bufnr = vim.api.nvim_win_get_buf(docker_notebook.winnr)
  return core.println(pcall(vim.api.nvim_buf_set_keymap, bufnr, "n", "<leader>run", ":lua require('notebook').runBuffer()<CR>", {}))
end
_2amodule_2a["make-buf-runnable"] = make_buf_runnable
local function resize()
  local wins = vim.api.nvim_tabpage_list_wins(docker_notebook.nr)
  table.remove(wins)
  for _, winnr in pairs(wins) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local line_count = core.count(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true))
    local optimum_size
    if (line_count < 8) then
      optimum_size = (line_count + 2)
    else
      optimum_size = 10
    end
    local function _9_()
      return vim.api.nvim_cmd({cmd = "resize", args = {optimum_size}}, {})
    end
    vim.api.nvim_win_call(winnr, _9_)
  end
  return nil
end
_2amodule_2a["resize"] = resize
local function append_to_cell(s, filetype)
  local bufnr = vim.api.nvim_win_get_buf(docker_notebook.winnr)
  local content = string.join("\n", vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  local lines = string.split(core.str(content, s), "\n")
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  local function _10_()
    vim.bo.filetype = filetype
    return nil
  end
  vim.api.nvim_buf_call(bufnr, _10_)
  return resize()
end
_2amodule_2a["append-to-cell"] = append_to_cell
local function show_tab_window_buffer()
  return core.println(core.str(vim.api.nvim_get_current_tabpage(), "-", vim.api.nvim_get_current_win(), "-", vim.api.nvim_get_current_buf(), "\n", vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win()), "\n", docker_notebook))
end
_2amodule_2a["show-tab-window-buffer"] = show_tab_window_buffer
local _12_
do
  local _11_ = {}
  local function _13_(...)
    return notebook_add_cell(_11_, ...)
  end
  _12_ = _13_
end
vim.api.nvim_create_user_command("NotebookAddCell", _12_, {nargs = 0})
vim.api.nvim_create_user_command("NotebookCoordinates", show_tab_window_buffer, {nargs = 0})
vim.api.nvim_create_user_command("NotebookResize", resize, {nargs = 0})
local function flush_function_call()
  if docker_notebook["current-function-call"] then
    do
      local _let_14_ = docker_notebook["current-function-call"]
      local name = _let_14_["name"]
      local args = _let_14_["arguments"]
      local arguments
      if core["table?"](args) then
        arguments = args
      else
        arguments = vim.json.decode(args)
      end
      core.println("--- call function ", name)
      core.println("--- arguments ", arguments)
      if ((name == "cell-execution") or (name == "suggest-command")) then
        notebook_add_cell({})
        append_to_cell(arguments.command, "shellscript")
        make_buf_runnable()
      elseif (name == "update-file") then
        local _let_16_ = arguments
        local language_id = _let_16_["languageId"]
        local path = _let_16_["path"]
        local edit = _let_16_["edit"]
        local bufnr = notebook_add_cell({path = path, ["language-id"] = language_id})
        core.println("do it", pcall(vim.api.nvim_buf_set_lines, bufnr, 0, 0, false, string.split(edit, "\n")))
      elseif (name == "show-notification") then
        local _let_17_ = arguments
        local level = _let_17_["level"]
        local message = _let_17_["message"]
        vim.api.nvim_notify(message, vim.log.levels.INFO, {})
      elseif (name == "create-notebook") then
        local _let_18_ = arguments
        local notebook = _let_18_["notebook"]
        local cells = _let_18_["cells"]
        for _, _19_ in pairs(cells.cells) do
          local _each_20_ = _19_
          local kind = _each_20_["kind"]
          local value = _each_20_["value"]
          local language_id = _each_20_["languageId"]
          notebook_add_cell({})
          if (kind == 1) then
            append_to_cell(value, "markdown")
          else
            append_to_cell(value, language_id)
            if (language_id == "shellscript") then
              make_buf_runnable()
            else
            end
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
      notebook_add_cell({})
      now_streaming("content")
      flush_function_call()
    else
    end
    return append_to_cell(message.content, "markdown")
  elseif message.complete then
    now_streaming(nil)
    return flush_function_call()
  else
    local _26_
    do
      local call_name = message.function_call.name
      _26_ = (call_name == "show-notification")
    end
    if _26_ then
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
      local function _30_()
        local _let_29_ = message.function_call
        local name = _let_29_["name"]
        local arguments = _let_29_["arguments"]
        return (arguments and not name)
      end
      if (message.function_call and _30_()) then
        local current_function_call = docker_notebook["current-function-call"]
        local _let_31_ = message.function_call
        local name = _let_31_["name"]
        local arguments = _let_31_["arguments"]
        docker_notebook = core.assoc(docker_notebook, "current-function-call", core.assoc(current_function_call, "arguments", core.str(current_function_call.arguments, arguments)))
        return nil
      else
        notebook_add_cell({})
        return append_to_cell(vim.json.encode(message), "json")
      end
    end
  end
end
_2amodule_2a["docker-ai-content-handler"] = docker_ai_content_handler
--[[ (core.println docker-notebook) (docker-ai-content-handler nil {:content "some content"}) (docker-ai-content-handler nil {:content "
some more content"}) (docker-ai-content-handler nil {:complete true}) (docker-ai-content-handler nil {:function_call {:arguments {:edit "FROM your ass" :languageId "dockerfile" :path "Dockerfile"} :name "update-file"}}) (docker-ai-content-handler nil {:complete true}) (docker-ai-content-handler nil {:function_call {:arguments {:level "INFO" :message "test message"} :name "show-notification"}}) (docker-ai-content-handler nil {:complete true}) (docker-ai-content-handler nil {:function_call {:arguments "" :name "cell-execution"}}) (docker-ai-content-handler nil {:function_call {:arguments (vim.json.encode {:command "docker build"})}}) (docker-ai-content-handler nil {:complete true}) (docker-ai-content-handler nil {:function_call {:arguments {:cells {:cells [{:kind 1 :value "Some Content"} {:kind 2 :languageId "shellscript" :value "touch .dockerignore"}]}} :name "create-notebook"}}) (docker-ai-content-handler nil {:complete true}) ]]
return _2amodule_2a