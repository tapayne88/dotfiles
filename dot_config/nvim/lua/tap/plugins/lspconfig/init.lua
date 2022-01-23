local lsp_installer = require "nvim-lsp-installer"
local lsp_installer_servers = require "nvim-lsp-installer.servers"
local utils = require "tap.utils"
local lsp_utils = require "tap.lsp.utils"

if vim.env.LSP_DEBUG then
    vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
    print("LSP debug log: " .. vim.lsp.get_log_path())
end

local servers = {
    -- servers installed with williamboman/nvim-lsp-installer
    ["nvim-lsp-installer"] = {
        "bashls", "diagnosticls", "eslint", "jsonls", "sumneko_lua@v2.5.6",
        "tsserver"
    },
    -- globally installed servers likely through nix
    ["global-servers"] = {"rnix"}
}

local function init_servers()
    for _, name in pairs(servers["nvim-lsp-installer"]) do
        pcall(function()
            require("tap.lsp.servers." .. name).patch_install()
        end)
    end
end

local function setup_servers(initialise)
    for _, server_identifier in pairs(servers["nvim-lsp-installer"]) do
        -- parse server identifier, could be something like 'sumneko_lua@2.5.6'
        local name, version = lsp_installer_servers.parse_server_identifier(
                                  server_identifier)
        local ok, server = lsp_installer.get_server(name)

        -- Check that the server is supported in nvim-lsp-installer
        if ok then
            if not server:is_installed() then
                vim.notify("Installing " .. server_identifier, "info",
                           {title = "LSPInstall"})
                server:install(version)
            end
            server:on_ready(function()
                require("tap.lsp.servers." .. name).setup(server)
            end)
        else
            vim.notify("Attempted to setup server " .. server_identifier ..
                           " with nvim-lsp-installer but not supported", "warn",
                       {title = "LSPInstall"})
        end
    end

    -- non-nvim-lsp-installer servers like rnix
    for _, name in pairs(servers["global-servers"]) do
        require("tap.lsp.servers." .. name).setup()
    end

    initialise()
end

local apply_user_highlights = function()
    utils.highlight('FloatBorder', {link = 'LspFloatWinBorder'})
end

utils.augroup("LspUserHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = apply_user_highlights
    }
})

init_servers()
setup_servers(function()
    apply_user_highlights()
    lsp_utils.init_diagnositcs()
end)