local servers = require "nvim-lsp-installer.servers"
local npm = require "nvim-lsp-installer.core.managers.npm"
local cargo = require "nvim-lsp-installer.core.managers.cargo"
local utils = require "tap.utils"
local lsp_utils = require "tap.utils.lsp"

local install_lua_format = function(ctx)
    local platform = vim.loop.os_uname().sysname == "Darwin" and "darwin" or
                         "linux"

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
        cargo.install("stylua")
    end)
end

local diagnosticls_languages = {
    html = {formatters = {"prettier"}},
    lua = {formatters = {"stylua"}},
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
            filetypes = utils.map_table_to_key(diagnosticls_languages, "linters"),
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
                lua_format = {command = root_dir .. "/lua-format"},
                stylua = {
                    sourceName = "stylua",
                    command = root_dir .. "/bin/stylua",
                    args = {"--color", "Never", "-"}
                }
            },
            formatFiletypes = utils.map_table_to_key(diagnosticls_languages,
                                                     "formatters")
        }
    }))
end

return module
