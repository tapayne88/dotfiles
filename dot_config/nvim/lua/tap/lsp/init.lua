local lspsaga = require("tap.plugins.lspsaga")
local lsp_status = require('tap.plugins.lsp-status')

lspsaga.init()
lsp_status.init()


local function patch_install(server, config)
  require'lspinstall/servers'[server] = config
end

local function init_servers()
  local servers = {
    typescript = "typescript",
    diagnosticls = "diagnosticls"
  }

  local patched_servers = vim.tbl_map(function(server)
    return require("tap.lsp.servers." .. server).patch_install{}
  end, servers)

  for server_name, config in pairs(patched_servers) do
    patch_install(server_name, config)
  end
end

local function setup_servers()
  require'lspinstall'.setup()
  local servers = require'lspinstall'.installed_servers()
  for _, server in pairs(servers) do
    require("tap.lsp.servers." .. server).setup{}
  end
end

init_servers()
setup_servers()
