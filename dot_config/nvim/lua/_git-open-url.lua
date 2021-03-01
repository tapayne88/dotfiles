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

local function get_git_remote()
  output = get_os_command_output({ "git", "remote", "get-url", "origin" })
  return output[1]
end

local function url_is_http(url)
  return string.find(url, "^https?://") ~= nil
end

local function parse_remote_ssh(url)
  _, _, remote, path = string.find(url, "^[^@]+@([^:]+):%d*/?(.+)%.git$")
  return remote .. "/" .. path
end

local function parse_remote_url(url)
  if url_is_http(url) then
    -- do something different
  end

  print("ssh", parse_remote_ssh(url))
end

local git_provider_map = {
  github = {
    test = "github",
    lines = "#L"
  },
  gitlab = {
    test = "gitlab",
    lines = "#L"
  },
  bitbucket = {
    test = "bitbucket",
    lines = "#lines-"
  },
  stash = {
    test = "stash",
    lines = "#"
  },
}

module.open = function(opts)
  opts = opts or {}
  file = opts.file or vim.fn.expand("%")

  git_file_path = get_git_filepath(file)
  git_remote = get_git_remote()

  print("file", git_file_path)
  print("remote", git_remote)

  parse_remote_url(git_remote)
end

return module
