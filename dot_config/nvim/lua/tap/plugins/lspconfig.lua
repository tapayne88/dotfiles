local command = require("tap.utils").command
local lspsaga = require("tap.plugins.lspsaga")

if vim.env.LSP_DEBUG then vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG) end

command({
    "LspInstalledServers",
    function() print(vim.inspect(require'lspinstall'.installed_servers())) end
})

local servers = {"typescript", "diagnosticls", "lua", "json", "eslint"}

local function init_plugins() lspsaga.init() end

local function init_servers()
    for _, server_name in pairs(servers) do
        pcall(function()
            require("tap.lsp.servers." .. server_name).patch_install()
        end)
    end
end

local function setup_servers(initialise)
    require'lspinstall'.setup()
    local installed_servers = require'lspinstall'.installed_servers()

    -- if we have servers, init dependencies
    if #installed_servers > 0 then initialise() end

    for _, server_name in pairs(installed_servers) do
        require("tap.lsp.servers." .. server_name).setup {}
    end
end

init_servers()
setup_servers(init_plugins)
