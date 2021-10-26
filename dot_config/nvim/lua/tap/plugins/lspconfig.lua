local utils = require("tap.utils")

if vim.env.LSP_DEBUG then vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG) end

utils.command({
    "LspInstalledServers",
    function() print(vim.inspect(require'lspinstall'.installed_servers())) end
})

local servers = {"typescript", "diagnosticls", "lua", "json", "eslint"}

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
setup_servers(apply_user_highlights)
