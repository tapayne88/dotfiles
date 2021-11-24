local lsp_installer = require("nvim-lsp-installer")
local utils = require("tap.utils")
local lsp_utils = require("tap.lsp.utils")

if vim.env.LSP_DEBUG then
    vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
    print("LSP debug log: " .. vim.lsp.get_log_path())
end

utils.command({
    "LspInstalledServers",
    function() print(vim.inspect(require'lspinstall'.installed_servers())) end
})

local servers = {"diagnosticls", "eslint"}

local function init_servers()
    for _, name in pairs(servers) do
        pcall(function()
            require("tap.lsp.servers." .. name).patch_install()
        end)
    end
end

local function setup_servers(initialise)
    for _, name in pairs(servers) do
        local ok, server = lsp_installer.get_server(name)
        -- Check that the server is supported in nvim-lsp-installer
        if ok then
            if not server:is_installed() then
                print("Installing " .. name)
                server:install()
            end
            server:on_ready(function()
                require("tap.lsp.servers." .. name).setup(server)
            end)
        end
    end

    -- TODO: Implement initialise probably using lsp_installer.on_server_ready
end

local apply_user_highlights = function()
    utils.highlight('FloatBorder', {link = 'LspFloatWinBorder'})
end

utils.augroup("LspSagaHighlights", {
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
