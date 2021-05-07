local utils = require("tap.utils")
local lsp_utils = require('tap.lsp.utils')

local diagnosticls_languages = {
    lua = {formatters = {"lua_format"}},
    javascript = {linters = {"eslint"}, formatters = {"eslint", "prettier"}},
    javascriptreact = {
        linters = {"eslint"},
        formatters = {"eslint", "prettier"}
    },
    json = {formatters = {"prettier"}},
    markdown = {linters = {"markdownlint"}, formatters = {"prettier"}},
    typescript = {linters = {"eslint"}, formatters = {"eslint", "prettier"}},
    typescriptreact = {
        linters = {"eslint"},
        formatters = {"eslint", "prettier"}
    }
}

local npm_packages = [[
  ! test -f package.json && npm init -y --scope=lspinstall || true
  npm install \
    diagnostic-languageserver@latest \
    eslint_d@latest \
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

function module.patch_install()
    local config = require"lspinstall/util".extract_config("diagnosticls")
    config.default_config.cmd[1] =
        "./node_modules/.bin/diagnostic-languageserver"

    return vim.tbl_extend('error', config,
                          {install_script = npm_packages .. lua_format})
end

local function npm_path(bin)
    return lsp_utils.install_path("diagnosticls") .. "/node_modules/.bin/" ..
               bin
end

function module.setup()
    lsp_utils.get_bin_path("prettier", function(prettier_bin)

        lsp_utils.lspconfig_server_setup("diagnosticls", {
            handlers = {
                ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                    "")
            },
            filetypes = vim.tbl_keys(diagnosticls_languages),
            on_attach = lsp_utils.on_attach,
            init_options = {
                linters = {
                    eslint = {
                        command = npm_path("eslint_d"),
                        rootPatterns = {"package.json", ".eslintrc.js"},
                        debounce = 100,
                        args = {
                            "--stdin", "--stdin-filename", "%filepath",
                            "--format", "json"
                        },
                        sourceName = "eslint",
                        parseJson = {
                            errorsRoot = "[0].messages",
                            line = "line",
                            column = "column",
                            endLine = "endLine",
                            endColumn = "endColumn",
                            message = "[eslint] ${message} [${ruleId}]",
                            security = "severity"
                        },
                        securities = {[2] = "error", [1] = "warning"}
                    },
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
                    eslint = {
                        command = npm_path("eslint_d"),
                        rootPatterns = {"package.json", ".eslintrc.js"},
                        debounce = 100,
                        args = {
                            "--fix-to-stdout", "--stdin", "--stdin-filename",
                            "%filepath"
                        }
                    },
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
                        command = lsp_utils.install_path("diagnosticls") ..
                            "/lua-format"
                    }
                },
                formatFiletypes = utils.map_table_to_key(diagnosticls_languages,
                                                         "formatters")
            }
        })
    end)
end

return module
