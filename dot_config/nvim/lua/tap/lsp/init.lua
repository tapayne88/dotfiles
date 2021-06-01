local command = require("tap.utils").command
local lspsaga = require("tap.plugins.lspsaga")

command({
    "LspInstalledServers",
    function() print(vim.inspect(require'lspinstall'.installed_servers())) end
})

lspsaga.init()

local servers = {"typescript", "diagnosticls", "lua", "json"}

local function init_servers()
    for _, server_name in pairs(servers) do
        pcall(function()
            require("tap.lsp.servers." .. server_name).patch_install()
        end)
    end
end

local function setup_servers()
    require'lspinstall'.setup()
    local installed_servers = require'lspinstall'.installed_servers()
    for _, server_name in pairs(installed_servers) do
        require("tap.lsp.servers." .. server_name).setup {}
    end
end

init_servers()
setup_servers()
