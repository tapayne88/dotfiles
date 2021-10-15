local lspconfig = require("lspconfig")
local lspsaga = require("tap.plugins.lspsaga")
local utils = require("tap.utils")
local nnoremap = require('tap.utils').nnoremap

local function toggle_format()
    if (vim.b.disable_format == nil) then
        vim.b.disable_format = 1
        print("disabled formatting for buffer")
    else
        vim.b.disable_format = nil
        print("enabled formatting for buffer")
    end
end

local module = {}

function module.format()
    return vim.b.disable_format == nil and vim.lsp.buf.formatting_sync({}, 2000)
end

local apply_user_highlights = function()
    utils.highlight("DiagnosticUnderlineError", {
        guifg = "none",
        gui = "undercurl",
        guisp = utils.lsp_colors("error")
    })
    utils.highlight("DiagnosticUnderlineWarn", {
        guifg = "none",
        gui = "undercurl",
        guisp = utils.lsp_colors("warning")
    })
    utils.highlight("DiagnosticUnderlineInfo", {
        guifg = "none",
        gui = "undercurl",
        guisp = utils.lsp_colors("info")
    })
    utils.highlight("DiagnosticUnderlineHint", {
        guifg = "none",
        gui = "undercurl",
        guisp = utils.lsp_colors("hint")
    })

    local signs = {
        Error = {
            guifg = utils.lsp_colors("error"),
            icon = utils.lsp_symbols["error"]
        },
        Warn = {
            guifg = utils.lsp_colors("warning"),
            icon = utils.lsp_symbols["warning"]
        },
        Hint = {
            guifg = utils.lsp_colors("hint"),
            icon = utils.lsp_symbols["hint"]
        },
        Info = {
            guifg = utils.lsp_colors("info"),
            icon = utils.lsp_symbols["info"]
        }
    }

    for type, config in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        utils.highlight(hl, {guifg = config.guifg})
        vim.fn.sign_define(hl, {text = config.icon, texthl = hl, numhl = ""})
    end

end

function module.on_attach(client, bufnr)

    lspsaga.on_attach(client, bufnr)

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    apply_user_highlights()

    utils.augroup("LspHighlights", {
        {
            events = {"VimEnter", "ColorScheme"},
            targets = {"*"},
            command = apply_user_highlights
        }
    })

    -- Mappings.
    local opts = {bufnr = bufnr}
    nnoremap('gD', '<cmd>Telescope lsp_definitions<CR>', opts)
    nnoremap('gd', '<cmd>Lspsaga preview_definition<CR>', opts)
    nnoremap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    nnoremap('gr', '<cmd>Telescope lsp_references<CR>', opts)
    nnoremap('K', '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>',
             opts)
    nnoremap('<leader>ac', '<cmd>Telescope lsp_code_actions<CR>', opts)
    nnoremap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    -- other mappings, not sure about these
    nnoremap('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
             opts)
    nnoremap('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
             opts)
    nnoremap('<space>wl',
             '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
             opts)
    nnoremap('<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    nnoremap('<space>e',
             '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    nnoremap('[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    nnoremap(']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    nnoremap('<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        utils.augroup("LspFormatting", {
            {
                events = {"BufWritePre"},
                targets = {"<buffer>"},
                command = "lua require'tap.lsp.utils'.format()"

            }
        })

        nnoremap("<leader>tf", toggle_format, opts)
        nnoremap("<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    elseif client.resolved_capabilities.document_range_formatting then
        nnoremap("<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end
end

function module.get_bin_path(cmd, fn)
    return utils.get_os_command_output_async({"yarn", "bin", cmd}, nil,
                                             function(result, code, signal)
        if code ~= 0 then
            print("`yarn bin " .. cmd .. "` failed")
            return fn(nil)
        end
        fn(result[1])
    end)
end

module.on_publish_diagnostics = vim.lsp.with(vim.lsp.diagnostic
                                                 .on_publish_diagnostics, {
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
})

local function get_config(config)
    local base_config = {
        capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
                                                                       .protocol
                                                                       .make_client_capabilities())
    }
    return vim.tbl_deep_extend("error", base_config, config)
end

function module.lspconfig_server_setup(server_name, config)
    local server = lspconfig[server_name]

    if (server == nil) then return end

    server.setup(get_config(config))
    server.manager.try_add_wrapper()

    return server
end

function module.get_lsp_clients()
    if next(vim.lsp.buf_get_clients(0)) == nil then return {} end
    local active_clients = vim.lsp.get_active_clients()

    return active_clients
end

return module
