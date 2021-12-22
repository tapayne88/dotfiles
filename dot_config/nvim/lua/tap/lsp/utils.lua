local server = require "nvim-lsp-installer.server"
local servers = require "nvim-lsp-installer.servers"
local lsp_settings = require "nvim-lsp-installer.settings"
local utils = require "tap.utils"
local nnoremap = require"tap.utils".nnoremap

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

-- LSP format wrapper which detects if formatting has been disabled for the buffer
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

local show_cursor_diagnositcs = function()
    vim.diagnostic.open_float({scope = "cursor"})
end
local show_line_diagnositcs = function()
    vim.diagnostic.open_float({scope = "line"})
end

-- on_attach function for lsp.setup calls
---@param client Client
---@param bufnr number
---@return nil
function module.on_attach(client, bufnr)

    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    apply_user_highlights()

    utils.augroup("LspHighlights", {
        {
            events = {"VimEnter", "ColorScheme"},
            targets = {"*"},
            command = apply_user_highlights
        }
    })

    utils.augroup("LspDiagnosticsCursor", {
        {
            events = {"CursorHold"},
            targets = {"<buffer>"},
            command = show_cursor_diagnositcs

        }
    })

    -- Mappings.
    local opts = {bufnr = bufnr}
    nnoremap('gD', '<cmd>Telescope lsp_definitions<CR>', opts)
    nnoremap('gd',
             '<cmd>lua require("goto-preview").goto_preview_definition()<CR>',
             opts)
    nnoremap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    nnoremap('gr', '<cmd>Telescope lsp_references<CR>', opts)
    nnoremap('K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    nnoremap('<leader>ac', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    nnoremap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    nnoremap("<leader>cc", show_cursor_diagnositcs)

    -- other mappings, not sure about these
    nnoremap('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
             opts)
    nnoremap('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
             opts)
    nnoremap('<space>wl',
             '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
             opts)
    nnoremap('<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    nnoremap('<space>e', show_line_diagnositcs, opts)
    nnoremap('<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

    -- float = false, CursorHold will show diagnostic
    nnoremap('[d', function() vim.diagnostic.goto_prev({float = false}) end,
             opts)
    nnoremap(']d', function() vim.diagnostic.goto_next({float = false}) end,
             opts)

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

-- Find npm executable path
---@param cmd string
---@param fn fun(result: string|nil)
---@return nil
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

local border_window_style = 'rounded'

-- Init vim.diagnostic with appropriate config
function module.init_diagnositcs()
    vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        virtual_text = false,
        signs = {
            -- Make priority higher than vim-signify
            priority = 100
        },
        severity_sort = true,
        float = {
            show_header = false,
            source = 'always',
            border = border_window_style
        }
    })
end

-- Merge passed config with default config for consistent lsp.setup calls, preserve
-- passed config
---@param config Config
---@return Config
function module.merge_with_default_config(config)
    local base_config = {
        autostart = true,
        on_attach = module.on_attach,
        -- set cmd_cwd to nvim-lsp-installer dir to ensure node version consistency
        cmd_cwd = lsp_settings.current.install_root_dir,
        handlers = {
            ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers
                                                              .signature_help, {
                border = border_window_style
            }),
            ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
                border = border_window_style
            })
        },
        capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
                                                                       .protocol
                                                                       .make_client_capabilities())
    }
    return vim.tbl_deep_extend("force", base_config, config or {})
end

-- Get active LSP clients
---@return table[]
function module.get_lsp_clients()
    if next(vim.lsp.buf_get_clients(0)) == nil then return {} end
    local active_clients = vim.lsp.get_active_clients()

    return active_clients
end

-- Patch nvim-lsp-installer for existing lsp server, copying the config and
-- overriding installer step
---@param server_name string
---@param installer fun()
---@return nil
function module.patch_lsp_installer(server_name, installer)
    local _, og_server = servers.get_server(server_name)

    local patched_server = server.Server:new(
                               vim.tbl_extend("force", og_server, {
            installer = installer,
            default_options = og_server:get_default_options()
        }))

    servers.register(patched_server)
end

return module
