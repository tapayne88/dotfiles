local nvim_lsp = require('lspconfig')
local util = require('lspconfig/util')
local lsp_status = require('lsp-status')

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

local on_attach = function(client, bufnr)

  lsp_status.on_attach(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()')

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
  buf_set_keymap('n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr',         '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)

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
    vim.cmd [[autocmd BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync({}, 1000)]]
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

local prefix_message = function(prefix, message)
  return "[".. prefix .."] ".. message
end

local on_publish_diagnostics = function(prefix)
  return function(err, method, params, client_id, bufnr, config)
    vim.tbl_map(
      function(value)
        value.message = prefix_message(prefix, value.message)
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
    ["textDocument/publishDiagnostics"] = on_publish_diagnostics("tsserver")
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

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  rootMarkers = { ".eslintrc.js", "package.json" }
}

local prettier  = {
  formatCommand = "./node_modules/.bin/prettier --stdin --stdin-filepath ${INPUT}",
  formatStdin = true,
  rootMarkers = { ".prettierrc.js", "package.json" }
}

local get_line_content_position = function(line)
  local line_len = string.len(line)
  local line_ltrim = string.match(line, '^%s*(.*)$')

  return {
    ["start"] = line_len - string.len(line_ltrim),
    ["end"] = line_len
  }
end

local efmLanguages = {
  javascript = { eslint, prettier },
  javascriptreact = { eslint, prettier },
  typescript = { eslint, prettier },
  typescriptreact = { eslint, prettier }
}

-- Need to install efm via `go get`
-- https://github.com/mattn/efm-langserver#installation
nvim_lsp.efm.setup {
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, method, params, client_id, bufnr, config)
      vim.tbl_map(
        function(value)
          local line_num = value.range["end"].line + 1
          local line = vim.api.nvim_eval("getline(".. line_num ..")")

          local line_content_pos = get_line_content_position(line)

          value.range["start"].character = line_content_pos["start"]
          value.range["end"].character = line_content_pos["end"]
        end,
        params.diagnostics
      )

      return on_publish_diagnostics("eslint")(err, method, params, client_id, bufnr, config)
    end
  },
  init_options = {
    documentFormatting = true,
  },
  filetypes = vim.tbl_keys(efmLanguages),
  settings = {
    lintDebounce = 500,
    languages = efmLanguages
  },
  on_attach = on_attach,
  capabilities = lsp_status.capabilities
}
