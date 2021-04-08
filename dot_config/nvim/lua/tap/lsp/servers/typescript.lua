local lspconfig_util = require('lspconfig.util')
local lsp_utils = require('tap.lsp.utils')

local module = {}

-- Stolen from lspconfig/tsserver, would have been nice to be able to import
local get_ts_root_dir = function(fname)
  return lspconfig_util.root_pattern("tsconfig.json")(fname) or
  lspconfig_util.root_pattern("package.json", "jsconfig.json", ".git")(fname);
end

-- Make tsserver work with yarn v2
local get_tsserver_exec = function(fn)
  local ts_root_dir = get_ts_root_dir(vim.fn.getcwd())
  local coc_settings = ts_root_dir and ts_root_dir .. "/.vim/coc-settings.json" or ""

  -- not yarn v2 project
  if lspconfig_util.path.exists(coc_settings) == false then
    return lsp_utils.get_bin_path("tsserver", fn)
  else
    local file = io.open(coc_settings):read("*a")
    local coc_json = vim.fn.json_decode(file)
    local ts_key = "tsserver.tsdk"
    return fn(coc_json[ts_key] .. "/tsserver.js")
  end
end

function module.setup()
  get_tsserver_exec(
    function(tsserver_bin)
      if (tsserver_bin == nil) then
        return
      end

      lsp_utils.lspconfig_server_setup("tsserver", {
        handlers = {
          ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics("[tsserver] ")
        },
        cmd = {
          "typescript-language-server",
          "--stdio",
          "--tsserver-path",
          tsserver_bin
        },
        on_attach = function(client, bufnr)
          client.resolved_capabilities.document_formatting = false
          lsp_utils.on_attach(client, bufnr)
        end,
      })
    end
  )
end

return module
