local servers = require "nvim-lsp-installer.servers"
local installers = require "nvim-lsp-installer.installers"
local npm = require "nvim-lsp-installer.installers.npm"
local shell = require "nvim-lsp-installer.installers.shell"
local utils = require "tap.utils"
local lsp_utils = require "tap.lsp.utils"

local lua_format = [[
  os=$(uname -s | tr "[:upper:]" "[:lower:]")

  case $os in
  linux)
  platform="linux"
  ;;
  darwin)
  platform="darwin"
  ;;
  esac

  curl -L -o lua-format "https://github.com/Koihik/vscode-lua-format/raw/master/bin/$platform/lua-format"
  chmod +x lua-format
]]

local module = {}

function module.patch_install()
    lsp_utils.patch_lsp_installer("diagnosticls", installers.pipe {
        npm.packages {
            "diagnostic-languageserver", "prettier", "markdownlint-cli"
        }, shell.bash(lua_format)
    })
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
    lsp_utils.get_bin_path("prettier", function(prettier_bin)

        lsp_server:setup(lsp_utils.merge_with_default_config({
            filetypes = vim.tbl_keys(diagnosticls_languages),
            init_options = {
                linters = {
                    markdownlint = {
                        command = npm.executable(root_dir, "markdownlint"),
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
                filetypes = utils.map_table_to_key(diagnosticls_languages,
                                                   "linters"),
                formatters = {
                    prettier = {
                        command = prettier_bin or
                            npm.executable(root_dir, "prettier"),
                        args = {"--stdin-filepath", "%filepath"},
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
                formatFiletypes = utils.map_table_to_key(diagnosticls_languages,
                                                         "formatters")
            }
        }))
    end)
end

return module
