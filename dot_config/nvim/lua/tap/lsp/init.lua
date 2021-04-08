local lspsaga = require("tap.plugins.lspsaga")
local lsp_status = require('tap.plugins.lsp-status')

lspsaga.init()
lsp_status.init()

local servers = { "typescript", "diagnosticls" }

local setup_servers = function()
  for _, server in pairs(servers) do
    require("tap.lsp.servers." .. server).setup{}
  end
end

setup_servers()
