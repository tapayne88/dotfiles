local servers = require "nvim-lsp-installer.servers"
local npm = require "nvim-lsp-installer.core.managers.npm"
local spawn = require "nvim-lsp-installer.core.spawn"
local utils = require "tap.utils"
local lsp_utils = require "tap.utils.lsp"

local platform_map = {linux = "linux", darwin = "darwin"}
local install_lua_format = function(ctx)
    local res = spawn.sh({
        '-c', 'uname -s | tr "[:upper:]" "[:lower:]" | tr -d "[:space:]"'
    })
    local platform = platform_map[res:get_or_throw().stdout]

    ctx.spawn.curl({
        "-L", "-o", "lua-format",
        "https://github.com/Koihik/vscode-lua-format/raw/master/bin/" ..
            platform .. "/lua-format"
    })
    ctx.spawn.chmod({"+x", "lua-format"})
end

local module = {}

function module.patch_install()
    lsp_utils.patch_lsp_installer("diagnosticls", function(ctx)
        npm.packages({
            "diagnostic-languageserver", "@fsouza/prettierd", "markdownlint-cli"
        })()
        install_lua_format(ctx)
    end)
end

-- Check service mappings for chezmoi template filetypes of all supported
---@param tbl table<string, table<string, any>>
---@param tbl_key string
---@return table<string, any>
local map_language_to_filetype = function(tbl, tbl_key)
    local serviceTemplateFiletypes = {}
    local mappedTbl = utils.map_table_to_key(tbl, tbl_key)

    for key, value in pairs(mappedTbl) do
        serviceTemplateFiletypes[key .. '.chezmoitmpl'] = value
    end

    return vim.tbl_extend("error", mappedTbl, serviceTemplateFiletypes)
end

local diagnosticls_languages = {
    html = {formatters = {"prettier"}},
    lua = {formatters = {"lua_format"}},
    javascript = {linters = {}, formatters = {"prettier"}},
    javascriptreact = {linters = {}, formatters = {"prettier"}},
    json = {formatters = {"prettier"}},
    markdown = {linters = {"markdownlint"}, formatters = {"prettier"}},
    sh = {linters = {"shellcheck"}},
    typescript = {linters = {}, formatters = {"prettier"}},
    typescriptreact = {linters = {}, formatters = {"prettier"}}
}

function module.setup(lsp_server)
    local root_dir = servers.get_server_install_path(lsp_server.name)

    lsp_server:setup(lsp_utils.merge_with_default_config({
        filetypes = vim.tbl_keys(diagnosticls_languages),
        init_options = {
            linters = {
                markdownlint = {
                    command = "markdownlint",
                    isStderr = true,
                    debounce = 100,
                    args = {
                        "--config",
                        vim.fn.stdpath("config") .. "/markdownlint.json",
                        "--stdin"
                    },
                    offsetLine = 0,
                    offsetColumn = 0,
                    sourceName = "markdownlint",
                    formatLines = 1,
                    formatPattern = {
                        "^.*?:\\s?(\\d+)(:(\\d+)?)?\\s(MD\\d{3}\\/[A-Za-z0-9-/]+)\\s(.*)$",
                        {line = 1, column = 3, message = {4}}
                    }
                },
                shellcheck = {
                    command = "shellcheck",
                    debounce = 100,
                    args = {"--format", "json", "-"},
                    sourceName = "shellcheck",
                    parseJson = {
                        line = "line",
                        column = "column",
                        endLine = "endLine",
                        endColumn = "endColumn",
                        message = "${message} [${code}]",
                        security = "level"
                    },
                    securities = {
                        error = "error",
                        warning = "warning",
                        info = "info",
                        style = "hint"
                    }
                }
            },
            filetypes = map_language_to_filetype(diagnosticls_languages,
                                                 "linters"),
            formatters = {
                prettier = {
                    command = "prettierd",
                    args = {"%filepath"},
                    rootPatterns = {
                        "package.json", ".prettierrc", ".prettierrc.json",
                        ".prettierrc.toml", ".prettierrc.json",
                        ".prettierrc.yml", ".prettierrc.yaml",
                        ".prettierrc.json5", ".prettierrc.js",
                        ".prettierrc.cjs", "prettier.config.js",
                        "prettier.config.cjs"
                    }
                },
                lua_format = {command = root_dir .. "/lua-format"}
            },
            formatFiletypes = map_language_to_filetype(diagnosticls_languages,
                                                       "formatters")
        }
    }))
end

return module
