local utils = require("tap.utils")
local lsp_utils = require('tap.lsp.utils')

local module = {}

local diagnosticls_languages = {
  javascript = {
    linters = { "eslint" },
    formatters = { "eslint", "prettier" }
  },
  javascriptreact = {
    linters = { "eslint" },
    formatters = { "eslint", "prettier" }
  },
  markdown = {
    formatters = { "prettier" }
  },
  typescript = {
    linters = { "eslint" },
    formatters = { "eslint", "prettier" }
  },
  typescriptreact = {
    linters = { "eslint" },
    formatters = { "eslint", "prettier" }
  },
}

function module.setup()
  lsp_utils.get_bin_path(
    "prettier",
    function(prettier_bin)
      local eslint_formatter = {
        eslint = {
          command = "eslint_d",
          rootPatterns = {
            "package.json",
            ".eslintrc.js"
          },
          debounce = 100,
          args = {
            "--fix-to-stdout",
            "--stdin",
            "--stdin-filename",
            "%filepath"
          },
        }
      }
      local prettier_formatter = prettier_bin ~= nil and {
        prettier = {
          command = prettier_bin,
          args = {"--stdin-filepath", "%filepath"},
          rootPatterns = {
            "package.json",
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.toml",
            ".prettierrc.json",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.json5",
            ".prettierrc.js",
            ".prettierrc.cjs",
            "prettier.config.js",
            "prettier.config.cjs"
          }
        }
      } or {}

      lsp_utils.lspconfig_server_setup("diagnosticls", {
        handlers = {
          ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics("")
        },
        filetypes = vim.tbl_keys(diagnosticls_languages),
        on_attach = lsp_utils.on_attach,
        init_options = {
          linters = {
            eslint = {
              command = "eslint_d",
              rootPatterns = {
                "package.json",
                ".eslintrc.js"
              },
              debounce = 100,
              args = {
                "--stdin",
                "--stdin-filename",
                "%filepath",
                "--format",
                "json"
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
              securities = {
                [2] = "error",
                [1] = "warning"
              }
            },
          },
          filetypes = utils.map_table_to_key(diagnosticls_languages, "linters"),
          formatters = vim.tbl_extend('keep', eslint_formatter, prettier_formatter),
          formatFiletypes = utils.map_table_to_key(diagnosticls_languages, "formatters"),
        }
      })
    end
  )
end

return module
