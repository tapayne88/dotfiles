local lsp_colors = require("tap.utils").lsp_colors
local lsp_symbols = require("tap.utils").lsp_symbols

local section_separators = vim.env.TERM_EMU == "kitty" and {"", " "} or {}
local component_separators = vim.env.TERM_EMU == "kitty" and {'\\', '\\'} or {}

local lsp_status_function_map = {
    error = "status_errors",
    warning = "status_warnings",
    info = "status_info",
    hint = "status_hints"
}

local function lsp_status(type)
    return {
        function()
            if #vim.lsp.buf_get_clients() > 0 then
                return require('lsp-status')[lsp_status_function_map[type]]()
            end
        end,
        color = {fg = lsp_colors[type]},
        separator = "",
        left_padding = 1,
        right_padding = 0
    }
end

local function lsp_ok()
    return {
        function()
            if #vim.lsp.buf_get_clients() > 0 then
                local diags = vim.tbl_map(function(fn)
                    return require('lsp-status')[fn]()
                end, lsp_status_function_map)

                local diag_string = table.concat(vim.tbl_values(diags))
                if diag_string == "" then
                    return lsp_symbols["ok"]
                end
                return ""
            end
        end,
        separator = "",
        left_padding = 1,
        right_padding = 0
    }
end

require('lualine').setup {
    options = {
        theme = 'nord',
        section_separators = section_separators,
        component_separators = component_separators,
        icons_enabled = true
    },
    sections = {
        lualine_a = {{'mode', upper = true}},
        lualine_b = {{'branch', icon = ''}},
        lualine_c = {{'filename', file_status = true}},
        -- Default 'diagnostics' doesn't include hints... so the below
        -- TODO:
        --  - Show spinner?
        lualine_x = {
            lsp_status("error"), lsp_status("warning"), lsp_status("info"),
            lsp_status("hint"), lsp_ok()
        },
        lualine_y = {'filetype', {'progress', icon = "≡"}},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {'filename'},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {'progress'},
        lualine_y = {'location'},
        lualine_z = {}
    }
}
