-- Module to open the current file and line in git browser interface
--
-- TODO:
--    - open in default browser or just use clipboard?
--    - handle various remote types
--      - stash
--      - bitbucket
--      - github
--      - gitlab
--    - support line
--    - support visual blocks
--    - support branch
local Job = require('plenary.job')

local module = {}

local function get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    print('[get_os_command_output]: cmd has to be a table')
    return {}
  end
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({ command = command, args = cmd, cwd = cwd, on_stderr = function(_, data)
    table.insert(stderr, data)
  end }):sync()
  return stdout, ret, stderr
end

local function get_git_filepath(filename)
  output, ret = get_os_command_output({
    "git", "rev-parse", "--show-toplevel", "--show-prefix", filename
  })

  if ret ~= 0 then
    print('not git repo')
    return {}
  end

  if output[2] ~= "" then
    return output[2] .. "/" .. output[3]
  end
  return output[3]
end

local function get_current_line_number()
  return vim.fn.line('.')
end

local function get_git_remote()
  -- TODO: allow remote name to be configurable
  output = get_os_command_output({ "git", "remote", "get-url", "origin" })
  return output[1]
end

local function url_is_http(url)
  return string.find(url, "^https?://") ~= nil
end

local function parse_remote_ssh(url)
  _, _, remote, path = string.find(url, "^[^@]+@([^:]+):%d*/?(.+)%.git$")
  return remote, path
end

local git_provider_map = {
  github = {
    test = "github",
    path = "tree/master",
    lines = "#L"
  },
  gitlab = {
    test = "gitlab",
    path = "",
    lines = "#L"
  },
  bitbucket = {
    test = "bitbucket",
    path = "",
    lines = "#lines-"
  },
  stash = {
    test = "stash",
    path = "",
    lines = "#"
  },
}

local function parse_remote_url(url)
  if url_is_http(url) then
    -- do something different
  end

  remote, path = parse_remote_ssh(url)

  matched_providers = vim.tbl_filter(function(provider)
    return string.match(remote, provider["test"]) ~= nil
  end, git_provider_map)

  -- TODO: if count(matched_providers) > 1 do something
  
  provider = matched_providers[1]
  path = path .. "/" .. provider["path"]

  return remote, path, provider["lines"]
end

local function build_url(remote, path, filename, line_num)
  print(
    "https://" .. remote ..
    "/" .. path .. "/" .. filename ..
    provider["lines"] .. line_num
  )
end

module.open = function(opts)
  opts = opts or {}
  file = opts.file or vim.fn.expand("%")

  git_file_path = get_git_filepath(file)
  git_remote = get_git_remote()

  remote, path, filename = parse_remote_url(git_remote)
  line_num = get_current_line_number()

  build_url(remote, path, git_file_path, line_num)
end

return module
