local util = require('lspconfig.util')
local lsp_status = require('lsp-status')
local saga = require('lspsaga')
local completion = require('completion')
local utils = require("tap.utils")

local lsp_symbols = {
  error = "⨯",
  warning = "◆",
  info = "ⓘ ",
  hint = "",
  ok = " "
}

lsp_status.register_progress()
lsp_status.config({
  current_function = false,
  status_symbol = "",
  indicator_errors = lsp_symbols["error"],
  indicator_warnings = lsp_symbols["warning"],
  indicator_info = lsp_symbols["info"],
  indicator_hint = lsp_symbols["hint"],
  indicator_ok = lsp_symbols["ok"]
})
saga.init_lsp_saga({
  error_sign = lsp_symbols["error"],
  warn_sign = lsp_symbols["warning"],
  infor_sign = lsp_symbols["info"],
  hint_sign = lsp_symbols["hint"],
  border_style = 2,
  code_action_prompt = {
    enable = false
  }
})

local on_attach = function(client, bufnr)

  lsp_status.on_attach(client, bufnr)
  completion.on_attach(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_command('autocmd CursorHold <buffer> lua require("lspsaga.diagnostic").show_cursor_diagnostics()')

  vim.api.nvim_command('highlight LspDiagnosticsDefaultError guifg=#BF616A')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultWarning guifg=#EBCB8B')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultInformation guifg=none')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultHint guifg=none')

  vim.api.nvim_command('highlight LspDiagnosticsUnderlineError guifg=#BF616A gui=underline')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineWarning guifg=#EBCB8B gui=underline')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineInformation guifg=none gui=underline')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineHint guifg=none gui=underline')

  vim.fn.sign_define("LspDiagnosticsSignError", { text = lsp_symbols["error"], texthl = "LspDiagnosticsSignError" })
  vim.fn.sign_define("LspDiagnosticsSignWarning", { text = lsp_symbols["warning"], texthl = "LspDiagnosticsSignWarning" })
  vim.fn.sign_define("LspDiagnosticsSignInformation", { text = lsp_symbols["info"], texthl = "LspDiagnosticsSignInformation" })
  vim.fn.sign_define("LspDiagnosticsSignHint", { text = "…", texthl = "LspDiagnosticsSignHint" })

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD',         '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gd',         '<cmd>Lspsaga preview_definition<CR>', opts)
  buf_set_keymap('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr',         '<cmd>Telescope lsp_references<CR>', opts)
  buf_set_keymap('n', 'K',          '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>', opts)
  buf_set_keymap('n', '<leader>ac', '<cmd>Telescope lsp_code_actions<CR>', opts)

  -- other mappings, not sure about these
  buf_set_keymap('n', '<space>wa',  '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr',  '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl',  '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D',   '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn',  '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>e',   '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q',   '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    vim.cmd [[augroup lsp_formatting]]
    vim.cmd [[autocmd!]]
    vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync({}, 5000)]]
    vim.cmd [[augroup END]]

    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

local get_bin_path = function(cmd, fn)
  utils.get_os_command_output_async(
    { "yarn", "bin", cmd },
    function(result, code, signal)
      if code ~= 0 then
        print("`yarn bin ".. cmd .."` failed")
        return
      end
      fn(result[1])
    end
  )
end

-- Stolen from lspconfig/tsserver, would have been nice to be able to import
local get_ts_root_dir = function(fname)
  return util.root_pattern("tsconfig.json")(fname) or
  util.root_pattern("package.json", "jsconfig.json", ".git")(fname);
end

-- Make tsserver work with yarn v2
local get_tsserver_exec = function(fn)
  local ts_root_dir = get_ts_root_dir(vim.fn.getcwd())
  local coc_settings = ts_root_dir .. "/.vim/coc-settings.json"

  -- not yarn v2 project
  if util.path.exists(coc_settings) == false then
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

get_tsserver_exec(
  function(tsserver_bin)
    local tsserver = require("lspconfig").tsserver

    tsserver.setup {
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
      capabilities = get_config_capabilities(tsserver)
    }
    tsserver.manager.try_add_wrapper()
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
    local diagnosticls = require('lspconfig').diagnosticls

    diagnosticls.setup {
      handlers = {
        ["textDocument/publishDiagnostics"] = on_publish_diagnostics("")
      },
      filetypes = vim.tbl_keys(diagnosticls_languages),
      on_attach = on_attach,
      capabilities = get_config_capabilities(diagnosticls),
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
        formatters = {
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
          },
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
        },
        formatFiletypes = utils.map_table_to_key(diagnosticls_languages, "formatters"),
      }
    }
    diagnosticls.manager.try_add_wrapper()
  end
)
