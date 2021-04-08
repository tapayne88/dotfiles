local lspconfig_util = require('lspconfig.util')
local lspsaga = require("tap.plugins.lspsaga")
local lsp_status = require('tap.plugins.lsp-status')
local utils = require("tap.utils")
local nnoremap = require('tap.utils').nnoremap

lspsaga.init()
lsp_status.init()

_G.lspconfig = {}

function _G.lspconfig.toggle_format()
  if (vim.b.disable_format == nil) then
    vim.b.disable_format = 1
    print("disabled formatting for buffer")
  else
    vim.b.disable_format = nil
    print("enabled formatting for buffer")
  end
end

function _G.lspconfig.format()
  return vim.b.disable_format == nil and vim.lsp.buf.formatting_sync({}, 5000)
end

local on_attach = function(client, bufnr)

  lspsaga.on_attach(client, bufnr)
  lsp_status.on_attach(client, bufnr)

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.api.nvim_command('highlight LspDiagnosticsDefaultError guifg=#BF616A')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultWarning guifg=#EBCB8B')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultInformation guifg=none')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultHint guifg=none')

  vim.api.nvim_command('highlight LspDiagnosticsUnderlineError guifg=#BF616A gui=underline')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineWarning guifg=#EBCB8B gui=underline')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineInformation guifg=none gui=underline')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineHint guifg=none gui=underline')

  vim.fn.sign_define("LspDiagnosticsSignError", { text = utils.lsp_symbols["error"], texthl = "LspDiagnosticsSignError" })
  vim.fn.sign_define("LspDiagnosticsSignWarning", { text = utils.lsp_symbols["warning"], texthl = "LspDiagnosticsSignWarning" })
  vim.fn.sign_define("LspDiagnosticsSignInformation", { text = utils.lsp_symbols["info"], texthl = "LspDiagnosticsSignInformation" })
  vim.fn.sign_define("LspDiagnosticsSignHint", { text = utils.lsp_symbols["hint"], texthl = "LspDiagnosticsSignHint" })

  -- Mappings.
  local opts = { bufnr = bufnr }
  nnoremap('gD',         '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  nnoremap('gd',         '<cmd>Lspsaga preview_definition<CR>', opts)
  nnoremap('gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  nnoremap('gr',         '<cmd>Telescope lsp_references<CR>', opts)
  nnoremap('K',          '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>', opts)
  nnoremap('<leader>ac', '<cmd>Telescope lsp_code_actions<CR>', opts)
  nnoremap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  -- other mappings, not sure about these
  nnoremap('<space>wa',  '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  nnoremap('<space>wr',  '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  nnoremap('<space>wl',  '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  nnoremap('<space>D',   '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  nnoremap('<space>e',   '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  nnoremap('[d',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  nnoremap(']d',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  nnoremap('<space>q',   '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    vim.api.nvim_exec([[
      augroup lsp_formatting
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> :lua lspconfig.format()
      augroup END
    ]], false)

    nnoremap("<leader>tf", "<cmd>lua lspconfig.toggle_format()<CR>", opts)
    nnoremap("<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    nnoremap("<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

local get_bin_path = function(cmd, fn)
  utils.get_os_command_output_async(
    { "yarn", "bin", cmd },
    function(result, code, signal)
      if code ~= 0 then
        print("`yarn bin ".. cmd .."` failed")
        return fn(nil)
      end
      fn(result[1])
    end
  )
end

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
    return get_bin_path("tsserver", fn)
  else
    local file = io.open(coc_settings):read("*a")
    local coc_json = vim.fn.json_decode(file)
    local ts_key = "tsserver.tsdk"
    return fn(coc_json[ts_key] .. "/tsserver.js")
  end
end

local publish_with_priority = function(priority)
  return vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- show underline
      underline = true,
      -- Enable signs
      signs = {
        -- Make priority higher than vim-signify
        priority = 100 - priority
      },
      -- Disable virtual_text
      virtual_text = false,
      -- show diagnostics on exit from insert
      update_in_insert = true
    }
  )
end

local on_publish_diagnostics = function(prefix)
  return function(err, method, params, client_id, bufnr, config)
    -- Clear diagnostics when there are 0 to stop them hanging around
    if (table.getn(params.diagnostics) == 0) then
      publish_with_priority(0)(err, method, params, client_id, bufnr, config)
      return
    end

    local diags = {}
    vim.tbl_map(
      function(value)
        value.message = prefix .. value.message

        local severity_diag = diags[value.severity] or {}
        table.insert(severity_diag, value)
        diags[value.severity] = severity_diag
      end,
      params.diagnostics
    )

    for severity, diagnostics in pairs(diags) do
      params.diagnostics = diagnostics
      publish_with_priority(severity)(err, method, params, client_id, bufnr, config)
    end
  end
end

local get_config_capabilities = function(config)
  return vim.tbl_extend(
    'keep',
    config.capabilities or {},
    lsp_status.capabilities
  )
end

local lspconfig_server_setup = function(server_name, config)
  local server = require("lspconfig")[server_name]

  if (server == nil) then
    return
  end

  server.setup(
    vim.tbl_extend(
      "force",
      {capabilities = get_config_capabilities(server)},
      config
    )
  )
  server.manager.try_add_wrapper()

  return server
end

get_tsserver_exec(
  function(tsserver_bin)
    if (tsserver_bin == nil) then
      return
    end

    lspconfig_server_setup("tsserver", {
      handlers = {
        ["textDocument/publishDiagnostics"] = on_publish_diagnostics("[tsserver] ")
      },
      cmd = {
        "typescript-language-server",
        "--stdio",
        "--tsserver-path",
        tsserver_bin
      },
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        on_attach(client, bufnr)
      end,
    })
  end
)

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

get_bin_path(
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

    lspconfig_server_setup("diagnosticls", {
      handlers = {
        ["textDocument/publishDiagnostics"] = on_publish_diagnostics("")
      },
      filetypes = vim.tbl_keys(diagnosticls_languages),
      on_attach = on_attach,
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
