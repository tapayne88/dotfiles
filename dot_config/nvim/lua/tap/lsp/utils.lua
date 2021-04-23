local lspconfig = require("lspconfig")
local lspsaga = require("tap.plugins.lspsaga")
local lsp_status = require('tap.plugins.lsp-status')
local utils = require("tap.utils")
local nnoremap = require('tap.utils').nnoremap

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

local module = {}

function module.on_attach(client, bufnr)

  lspsaga.on_attach(client, bufnr)
  lsp_status.on_attach(client, bufnr)

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.api.nvim_command('highlight LspDiagnosticsDefaultError        guifg=none')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultWarning      guifg=none')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultInformation  guifg=none')
  vim.api.nvim_command('highlight LspDiagnosticsDefaultHint         guifg=none')

  vim.api.nvim_command('highlight LspDiagnosticsUnderlineError        guifg=none gui=undercurl guisp=#BF616A')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineWarning      guifg=none gui=undercurl guisp=#EBCB8B')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineInformation  guifg=none gui=undercurl guisp=#D8DEE9')
  vim.api.nvim_command('highlight LspDiagnosticsUnderlineHint         guifg=none gui=undercurl guisp=#5E81AC')

  vim.api.nvim_command('highlight LspDiagnosticsSignError        guifg=#BF616A')
  vim.api.nvim_command('highlight LspDiagnosticsSignWarning      guifg=#EBCB8B')
  vim.api.nvim_command('highlight LspDiagnosticsSignInformation  guifg=#D8DEE9')
  vim.api.nvim_command('highlight LspDiagnosticsSignHint         guifg=#5E81AC')

  vim.fn.sign_define("LspDiagnosticsSignError",       { text = utils.lsp_symbols["error"],    texthl = "LspDiagnosticsSignError" })
  vim.fn.sign_define("LspDiagnosticsSignWarning",     { text = utils.lsp_symbols["warning"],  texthl = "LspDiagnosticsSignWarning" })
  vim.fn.sign_define("LspDiagnosticsSignInformation", { text = utils.lsp_symbols["info"],     texthl = "LspDiagnosticsSignInformation" })
  vim.fn.sign_define("LspDiagnosticsSignHint",        { text = utils.lsp_symbols["hint"],     texthl = "LspDiagnosticsSignHint" })

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

function module.get_bin_path(cmd, fn)
  return utils.get_os_command_output_async(
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

local publish_diagnostics = vim.lsp.with(
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
)

function module.on_publish_diagnostics(prefix)
  return function(err, method, params, client_id, bufnr, config)
    vim.tbl_map(
      function(value)
        value.message = prefix .. value.message
      end,
      params.diagnostics
    )

    publish_diagnostics(err, method, params, client_id, bufnr, config)
  end
end

local get_config_capabilities = function(config)
  return vim.tbl_extend(
    'keep',
    config.capabilities or {},
    lsp_status.capabilities
  )
end

function module.lspconfig_server_setup(server_name, config)
  local server = lspconfig[server_name]

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

function module.install_path(lang)
  return vim.fn.stdpath("data") .. "/lspinstall/" .. lang
end

return module
