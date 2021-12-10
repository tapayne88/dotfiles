local color = require("tap.utils").color
local lsp_colors = require("tap.utils").lsp_colors
local lsp_symbols = require("tap.utils").lsp_symbols
local get_lsp_clients = require("tap.lsp.utils").get_lsp_clients

local nord_theme_b = {
    bg = color({dark = "nord1_gui", light = "fg_dark"}),
    fg = color({dark = "nord4_gui", light = "blue7"})
}
local nord_theme_c = {
    bg = color({dark = "nord3_gui", light = "fg"}),
    fg = color({dark = "nord4_gui", light = "blue7"})
}
local nord_theme = {
    normal = {
        a = {
            bg = color({dark = "nord8_gui", light = "blue"}),
            fg = color({dark = "nord0_gui", light = "bg"})
        },
        b = nord_theme_b,
        c = nord_theme_c
    },
    insert = {
        a = {
            bg = color({dark = "nord4_gui", light = "fg"}),
            fg = color({dark = "nord0_gui", light = "bg"})
        },
        b = nord_theme_b,
        c = nord_theme_c
    },
    visual = {
        a = {
            bg = color({dark = "nord7_gui", light = "cyan"}),
            fg = color({dark = "nord0_gui", light = "bg"})
        },
        b = nord_theme_b,
        c = nord_theme_c
    },
    replace = {
        a = {
            bg = color({dark = "nord13_gui", light = "yellow"}),
            fg = color({dark = "nord0_gui", light = "bg"})
        },
        b = nord_theme_b,
        c = nord_theme_c
    },
    command = {
        a = {
            bg = color({dark = "nord8_gui", light = "blue"}),
            fg = color({dark = "nord0_gui", light = "bg"})
        },
        b = nord_theme_b,
        c = nord_theme_c
    },
    inactive = {
        a = {
            bg = color({dark = "nord1_gui", light = "gray"}),
            fg = color({dark = "nord0_gui", light = "bg"})
        },
        b = nord_theme_b,
        c = nord_theme_c
    }
}

local function literal(str)
    local comp = require('lualine.component'):extend()
    function comp:draw(default_highlight)
        self.status = str or ''
        self.applied_separator = ''
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        return self.status
    end

    return comp
end

local function modified()
    if vim.bo.modified then return '' end
    return ''
end

local function tscVersion()
    if vim.g.tsc_version ~= nil then
        local client_version = vim.tbl_map(function(client)
            return vim.g.tsc_version["client_" .. client.id]
        end, get_lsp_clients())

        local file_versions = vim.tbl_filter(function(version)
            return version ~= nil
        end, client_version)

        if #file_versions > 0 then
            return string.format("v%s ", file_versions[1])

        end
    end
    return ""
end

local function scrollbar()
    local current_line = vim.fn.line('.')
    local total_lines = vim.fn.line('$')
    local chars = {
        '██', '▇▇', '▆▆', '▅▅', '▄▄', '▃▃', '▂▂',
        '▁▁', '__'
    }
    local index = 1

    if current_line == 1 then
        index = 1
    elseif current_line == total_lines then
        index = #chars
    else
        local line_no_fraction = vim.fn.floor(current_line) /
                                     vim.fn.floor(total_lines)
        index = vim.fn.float2nr(line_no_fraction * #chars)
        if index == 0 then index = 1 end
    end
    return chars[index]
end

local section_separators = vim.env.TERM == "xterm-kitty" and
                               {left = "", right = ""} or
                               {left = "", right = ""}
local diagnostic_separators = vim.env.TERM == "xterm-kitty" and
                                  {left = "", right = ""} or
                                  {left = "", right = ""}

require('lualine').setup {
    options = {
        theme = nord_theme,
        component_separators = {left = "", right = ""},
        section_separators = section_separators
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {{'branch', icon = ''}},
        lualine_c = {
            {'filename', file_status = false}, modified,
            {'%r', cond = function() return vim.bo.readonly end}
        },
        lualine_x = {
            tscVersion, {
                'diagnostics',
                source = {'nvim_diagnostic'},
                sections = {'error'},
                diagnostics_color = {
                    error = {
                        bg = lsp_colors("error"),
                        fg = color({dark = "nord3_gui", light = "fg"})
                    }
                },
                symbols = {error = lsp_symbols.error},
                separator = diagnostic_separators,
                always_visible = true

            }, {
                'diagnostics',
                source = {'nvim_diagnostic'},
                sections = {'warn'},
                diagnostics_color = {
                    warn = {
                        bg = lsp_colors("warning"),
                        fg = color({dark = "nord3_gui", light = "fg"})
                    }
                },
                symbols = {warn = lsp_symbols.warning},
                separator = diagnostic_separators,
                always_visible = true

            }, {
                'diagnostics',
                source = {'nvim_diagnostic'},
                sections = {'hint'},
                diagnostics_color = {
                    hint = {
                        bg = lsp_colors("hint"),
                        fg = color({dark = "nord3_gui", light = "fg"})
                    }
                },
                symbols = {hint = lsp_symbols.hint},
                separator = diagnostic_separators,
                always_visible = true

            }, {
                'diagnostics',
                source = {'nvim_diagnostic'},
                sections = {'info'},
                diagnostics_color = {
                    info = {
                        bg = lsp_colors("info"),
                        fg = color({dark = "nord3_gui", light = "fg"})
                    }
                },
                symbols = {info = lsp_symbols.info},
                separator = diagnostic_separators,
                always_visible = true
            }, -- TODO: ok diagnotic
            literal(' ')
        },
        lualine_y = {
            {'filetype', colored = false},
            literal(vim.env.TERM == "xterm-kitty" and '\\' or '|'),
            {'%l:%c', icon = "  "}
        },
        lualine_z = {'%p%%', {scrollbar, padding = 0}}
    },
    inactive_sections = {lualine_c = {'%f %y %m'}, lualine_x = {}}
}
