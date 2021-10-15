local utils = require("tap.utils")
local lsp_utils = require('tap.lsp.utils')
local install_path = require'lspinstall/util'.install_path

local diagnosticls_languages = {
    html = {formatters = {"prettier"}},
    lua = {formatters = {"lua_format"}},
    javascript = {linters = {}, formatters = {"prettier"}},
    javascriptreact = {linters = {}, formatters = {"prettier"}},
    json = {formatters = {"prettier"}},
    markdown = {linters = {"markdownlint"}, formatters = {"prettier"}},
    typescript = {linters = {}, formatters = {"prettier"}},
    typescriptreact = {linters = {}, formatters = {"prettier"}}
}

local npm_packages = [[
  ! test -f package.json && npm init -y --scope=lspinstall || true
  npm install \
    diagnostic-languageserver@latest \
    prettier@latest \
    markdownlint-cli@latest
]]

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

local server_name = "diagnosticls"
local lspconfig_name = "diagnosticls"

function module.patch_install()
    local config = require"lspinstall/util".extract_config(lspconfig_name)
    config.default_config.cmd[1] =
        "./node_modules/.bin/diagnostic-languageserver"

    require'lspinstall/servers'[server_name] =
        vim.tbl_extend('error', config,
                       {install_script = npm_packages .. lua_format})
end

local function npm_path(bin)
    return install_path(server_name) .. "/node_modules/.bin/" .. bin
end

function module.setup()
    lsp_utils.get_bin_path("prettier", function(prettier_bin)

        lsp_utils.lspconfig_server_setup(server_name, {
            handlers = {
                ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics
            },
            filetypes = vim.tbl_keys(diagnosticls_languages),
            on_attach = lsp_utils.on_attach,
            init_options = {
                linters = {
                    markdownlint = {
                        command = npm_path("markdownlint"),
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
                    }
                },
                filetypes = utils.map_table_to_key(diagnosticls_languages,
                                                   "linters"),
                formatters = {
                    prettier = {
                        command = prettier_bin or npm_path("prettier"),
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
                    lua_format = {
                        command = install_path(server_name) .. "/lua-format"
                    }
                },
                formatFiletypes = utils.map_table_to_key(diagnosticls_languages,
                                                         "formatters")
            }
        })
    end)
end

return module
