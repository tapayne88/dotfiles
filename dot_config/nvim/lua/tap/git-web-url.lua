-- Module to open the current file and line in git web interface
--
-- TODO:
--    - open in default browser or just use clipboard?
--    - support http git remotes
--    - allow remote name to be configurable (currently hard coded to origin)
--    - expand support for matching (uses name of config to match)
--
local utils = require("tap.utils")

local module = {}

local function get_git_branch()
    output, ret = utils.get_os_command_output(
                      {"git", "branch", "--show-current"})

    if ret ~= 0 then error('not git repo') end

    return output[1]
end

local function get_git_filepath(filename)
    output, ret = utils.get_os_command_output(
                      {
            "git", "rev-parse", "--show-toplevel", "--show-prefix", filename
        })

    if ret ~= 0 then error('not git repo') end

    if output[2] ~= "" then return output[2] .. output[3] end
    return output[3]
end

local function get_current_line_number() return vim.fn.line('.') end

local function get_visual_selection_lines()
    return vim.fn.line("'<"), vim.fn.line("'>")
end

local function get_git_remote()
    output, ret = utils.get_os_command_output(
                      {"git", "remote", "get-url", "origin"})

    if ret ~= 0 then error("not git repo or origin remote doesn't exist") end

    return output[1]
end

local function url_is_http(url) return string.find(url, "^https?://") ~= nil end

local function parse_remote_ssh(url)
    _, _, remote, project, repo = string.find(url,
                                              "^[^@]+@([^:]+):%d*/?([^/]+)/([^/]+)%.git$")
    return remote, project, repo
end

local git_provider_map = {
    github = {
        domain_test = "github",
        path = "$project/$repo/tree/$branch/$filename",
        query_string = "",
        fragment = {normal = "L$lines", visual = "L$start_line-L$end_line"}
    },
    gitlab = {
        domain_test = "gitlab",
        path = "$project/$repo/-/tree/$branch/$filename",
        query_string = "",
        fragment = {normal = "L$lines", visual = "L$start_line-$end_line"}
    },
    bitbucket = {
        domain_test = "bitbucket",
        path = "$project/$repo/src/$branch/$filename",
        query_string = "",
        fragment = {
            normal = "lines-$lines",
            visual = "lines-$start_line:$end_line"
        }
    },
    stash = {
        domain_test = "stash",
        path = "projects/$project/repos/$repo/browse/$filename",
        query_string = "at=$branch",
        fragment = {normal = "$lines", visual = "$start_line-$end_line"}
    }
}

local function join(tbl)
    table_without_empty_strings = vim.tbl_filter(
                                      function(param) return param ~= "" end,
                                      tbl)

    return table.concat(table_without_empty_strings, "/")
end

local function parse_remote_url(url, provider_prop)
    if url_is_http(url) then
        error("http git remotes are currently not supported")
    end

    return parse_remote_ssh(url)
end

local function apply_provider(provider_prop, subkey)
    matched_providers = vim.tbl_filter(function(provider)
        return string.match(remote, provider_prop(provider, "domain_test")) ~=
                   nil
    end, git_provider_map)

    -- TODO: if count(matched_providers) > 1 plenary log something

    provider = matched_providers[1]

    return provider_prop(provider, "path"),
           provider_prop(provider, "query_string"),
           provider_prop(provider, "fragment", subkey)
end

local function build_url(remote, path, query_string, fragment)
    query_string = query_string ~= "" and "?" .. query_string or ""
    fragment = fragment ~= "" and "#" .. fragment or ""
    print("https://" .. join({remote, path .. query_string .. fragment}))
end

local function get_provider_prop(project, repo, branch, file_path, lines,
                                 start_num, end_num)
    return function(provider, prop, sub_prop)
        property = sub_prop == nil and provider[prop] or
                       provider[prop][sub_prop]
        interp_prop = string.gsub(property, "%$([%w_]+)", {
            project = project,
            repo = repo,
            branch = branch,
            filename = file_path,
            lines = lines,
            start_line = start_num,
            end_line = end_num
        })
        return interp_prop
    end
end

local function print_url(opts, key)
    opts = opts or {}
    file = opts.file or vim.fn.expand("%")

    git_branch = get_git_branch()
    git_file_path = get_git_filepath(file)
    git_remote = get_git_remote()

    host, project, repo = parse_remote_url(git_remote)
    line_num = get_current_line_number()
    start_num, end_num = get_visual_selection_lines()
    provider_prop = get_provider_prop(project, repo, git_branch, git_file_path,
                                      line_num, start_num, end_num)

    path, query_string, fragment = apply_provider(provider_prop, key)

    build_url(host, path, query_string, fragment)
end

module.get_line_url = function(opts) print_url(opts, "normal") end

module.get_block_url = function(opts) print_url(opts, "visual") end

return module
