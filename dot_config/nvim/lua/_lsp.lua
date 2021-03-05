local nvim_lsp = require('lspconfig')
local util = require('lspconfig/util')
local lsp_status = require('lsp-status')
local saga = require('lspsaga')

lsp_status.register_progress()
lsp_status.config({
  current_function = false,
  status_symbol = "",
  indicator_errors = "⨯",
  indicator_warnings = "◆",
  indicator_info = "ⓘ ",
  indicator_hint = "…",
  indicator_ok = " "
})
saga.init_lsp_saga({
  error_sign = "⨯",
  warn_sign = "◆",
  infor_sign = "ⓘ ",
  hint_sign = "…",
  border_style = 2
})

local on_attach = function(client, bufnr)

  lsp_status.on_attach(client, bufnr)

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

  vim.fn.sign_define("LspDiagnosticsSignError", { text = "⨯", texthl = "LspDiagnosticsSignError" })
  vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "◆", texthl = "LspDiagnosticsSignWarning" })
  vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "ⓘ ", texthl = "LspDiagnosticsSignInformation" })
  vim.fn.sign_define("LspDiagnosticsSignHint", { text = "…", texthl = "LspDiagnosticsSignHint" })

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD',         '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gd',         '<cmd>Lspsaga preview_definition<CR>', opts)
  buf_set_keymap('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr',         '<cmd>Telescope lsp_references<CR>', opts)
  buf_set_keymap('n', 'K',          '<cmd>Lspsaga hover_doc<CR>', opts)
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

-- Stolen from lspconfig/tsserver, would have been nice to be able to import
local get_ts_root_dir = function(fname)
  return util.root_pattern("tsconfig.json")(fname) or
  util.root_pattern("package.json", "jsconfig.json", ".git")(fname);
end

-- Make tsserver work with yarn v2
local get_tsserver_exec = function()
  local ts_root_dir = get_ts_root_dir(vim.fn.getcwd())
  local coc_settings = ts_root_dir .. "/.vim/coc-settings.json"

  -- not yarn v2 project
  if util.path.exists(coc_settings) == false then
    return "node_modules/.bin/tsserver"
  else
    local file = io.open(coc_settings):read("*a")
    local coc_json = vim.fn.json_decode(file)
    local ts_key = "tsserver.tsdk"
    return coc_json[ts_key] .. "/tsserver.js"
  end
end

local on_publish_diagnostics = function(prefix)
  return function(err, method, params, client_id, bufnr, config)
    vim.tbl_map(
      function(value)
        value.message = prefix .. value.message
      end,
      params.diagnostics
    )

    return vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        -- show underline
        underline = true,
        -- Enable signs
        signs = {
          -- Make priority higher than vim-signify
          priority = 100
        },
        -- Disable virtual_text
        virtual_text = false,
        -- show diagnostics on exit from insert
        update_in_insert = true
      }
    )(err, method, params, client_id, bufnr, config)
  end
end

local tsserver_exec = get_tsserver_exec()
nvim_lsp.tsserver.setup {
  handlers = {
    ["textDocument/publishDiagnostics"] = on_publish_diagnostics("[tsserver] ")
  },
  cmd = {
    "typescript-language-server",
    "--stdio",
    "--tsserver-path",
    tsserver_exec
  },
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    on_attach(client, bufnr)
  end,
  capabilities = lsp_status.capabilities
}

local map_table_to_key = function(tbl, key)
  return vim.tbl_map(function(value)
    return value[key]
  end, tbl)
end

local diagnosticls_languages = {
  javascript = {
    linters = { "eslint" },
    formatters = { "prettier" }
  },
  javascriptreact = {
    linters = { "eslint" },
    formatters = { "prettier" }
  },
  typescript = {
    linters = { "eslint" },
    formatters = { "prettier" }
  },
  typescriptreact = {
    linters = { "eslint" },
    formatters = { "eslint", "prettier" }
  },
}
require'lspconfig'.diagnosticls.setup{
  handlers = {
    ["textDocument/publishDiagnostics"] = on_publish_diagnostics("")
  },
  filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact"},
  on_attach = on_attach,
  capabilities = lsp_status.capabilities,
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
    filetypes = map_table_to_key(diagnosticls_languages, "linters"),
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
        command = "./node_modules/.bin/prettier",
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
    formatFiletypes = map_table_to_key(diagnosticls_languages, "formatters"),
  }
}
