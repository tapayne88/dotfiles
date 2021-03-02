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
    return output[2] .. output[3]
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
  _, _, remote, project, repo = string.find(url, "^[^@]+@([^:]+):%d*/?([^/]+)/([^/]+)%.git$")
  return remote, project, repo
end

local git_provider_map = {
  github = {
    domain_test = "github",
    project_prefix = "",
    repo_prefix = "",
    filename_prefix = "tree/master",
    lines_prefix = "#L"
  },
  gitlab = {
    domain_test = "gitlab",
    project_prefix = "",
    repo_prefix = "",
    filename_prefix = "-/tree/master",
    lines_prefix = "#L"
  },
  bitbucket = {
    domain_test = "bitbucket",
    project_prefix = "",
    repo_prefix = "",
    filename_prefix = "src/master",
    lines_prefix = "#lines-"
  },
  stash = {
    domain_test = "stash",
    project_prefix = "projects",
    repo_prefix = "repos",
    filename_prefix = "browse",
    lines_prefix = "#"
  },
}

local function join(tbl)
  table_without_empty_strings = vim.tbl_filter(function(param)
    return param ~= ""
  end, tbl)

  return table.concat(table_without_empty_strings, "/")
end

local function parse_remote_url(url)
  if url_is_http(url) then
    error("http git remotes are currently not supported")
  end

  remote, project, repo = parse_remote_ssh(url)

  matched_providers = vim.tbl_filter(function(provider)
    return string.match(remote, provider["domain_test"]) ~= nil
  end, git_provider_map)

  -- TODO: if count(matched_providers) > 1 do something
  
  provider = matched_providers[1]

  path = join({
    provider["project_prefix"],
    project,
    provider["repo_prefix"],
    repo,
    provider["filename_prefix"]
  })

  return remote, path, provider["lines_prefix"]
end

local function build_url(remote, path, filename, lines_prefix, line_num)
  print(
    "https://" ..  join({ remote, path, filename .. lines_prefix .. line_num })
  )
end

module.open = function(opts)
  opts = opts or {}
  file = opts.file or vim.fn.expand("%")

  git_file_path = get_git_filepath(file)
  git_remote = get_git_remote()

  host, path, lines_prefix = parse_remote_url(git_remote)
  line_num = get_current_line_number()

  build_url(host, path, git_file_path, lines_prefix, line_num)
end

return module
