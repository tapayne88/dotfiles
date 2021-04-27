local lsp_colors = require("tap.utils").lsp_colors

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
        left_padding = 0,
        right_padding = 1
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
        lualine_x = {
            lsp_status("error"), lsp_status("warning"), lsp_status("info"),
            lsp_status("hint")
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
