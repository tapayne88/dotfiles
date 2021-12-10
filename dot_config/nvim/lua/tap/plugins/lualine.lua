local color = require("tap.utils").color
local lsp_colors = require("tap.utils").lsp_colors
local lsp_symbols = require("tap.utils").lsp_symbols
local get_lsp_clients = require("tap.lsp.utils").get_lsp_clients

local nord_theme_b = {bg = color("nord1_gui"), fg = color("nord4_gui")}
local nord_theme_c = {bg = color("nord3_gui"), fg = color("nord4_gui")}
local nord_theme = {
    normal = {
        a = {bg = color("nord8_gui"), fg = color("nord0_gui")},
        b = nord_theme_b,
        c = nord_theme_c
    },
    insert = {
        a = {bg = color("nord4_gui"), fg = color("nord0_gui")},
        b = nord_theme_b,
        c = nord_theme_c
    },
    visual = {
        a = {bg = color("nord7_gui"), fg = color("nord0_gui")},
        b = nord_theme_b,
        c = nord_theme_c
    },
    replace = {
        a = {bg = color("nord13_gui"), fg = color("nord0_gui")},
        b = nord_theme_b,
        c = nord_theme_c
    },
    command = {
        a = {bg = color("nord8_gui"), fg = color("nord0_gui")},
        b = nord_theme_b,
        c = nord_theme_c
    },
    inactive = {
        a = {bg = color("nord4_gui"), fg = color("nord1_gui")},
        b = nord_theme_b,
        c = nord_theme_c,
        y = nord_theme_c
    }
}

local conditions = {
    hide_in_width = function() return vim.fn.winwidth(0) > 80 end
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

local diagnotic_ok = require('lualine.components.diagnostics'):extend()
function diagnotic_ok:draw(default_highlight, is_focused)
    -- Copied from lualine.component and modified to allow empty status to render
    self.status = ''
    self.applied_separator = ''

    if self.options.cond ~= nil and self.options.cond() ~= true then
        return self.status
    end
    local status = self:update_status(is_focused)
    if self.options.fmt then status = self.options.fmt(status or '') end
    -- if type(status) == 'string' and #status > 0 then
    self.status = status
    self:apply_icon()
    self:apply_padding()
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    self:apply_separator()
    -- end
    return self.status
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

local diagnostic_section = function(cfg)
    local default_cfg = {
        'diagnostics',
        source = {'nvim_diagnostic'},
        separator = vim.env.TERM == "xterm-kitty" and
            {left = "", right = ""} or {left = "", right = ""},
        padding = 0,
        render = function(icon, count)
            if count > 0 then
                return string.format(" %s%s ", icon, count)
            else
                return ''
            end
        end,
        always_visible = true

    }
    return vim.tbl_extend("force", default_cfg, cfg)
end

local sections = {
    lualine_a = {'mode'},
    lualine_b = {{'branch', icon = ''}},
    lualine_c = {
        {'filename', file_status = false}, modified, {
            '%r',
            fmt = function() return '' end,
            cond = function() return vim.bo.readonly end
        }
    },
    lualine_x = {
        {tscVersion, cond = conditions.hide_in_width}, diagnostic_section {
            sections = {'error'},
            diagnostics_color = {
                error = {
                    bg = lsp_colors("error"),
                    fg = color({dark = "nord3_gui", light = "fg"})
                }
            },
            symbols = {error = lsp_symbols.error}
        }, diagnostic_section {
            sections = {'warn'},
            diagnostics_color = {
                warn = {
                    bg = lsp_colors("warning"),
                    fg = color({dark = "nord3_gui", light = "fg"})
                }
            },
            symbols = {warn = lsp_symbols.warning}
        }, diagnostic_section {
            sections = {'hint'},
            diagnostics_color = {
                hint = {
                    bg = lsp_colors("hint"),
                    fg = color({dark = "nord3_gui", light = "fg"})
                }
            },
            symbols = {hint = lsp_symbols.hint}
        }, diagnostic_section {
            sections = {'info'},
            diagnostics_color = {
                info = {
                    bg = lsp_colors("info"),
                    fg = color({dark = "nord3_gui", light = "fg"})
                }
            },
            symbols = {info = lsp_symbols.info}
        }, diagnostic_section {
            diagnotic_ok,
            sections = {'error', 'warn', 'hint', 'info'},
            color = {
                bg = lsp_colors("ok"),
                fg = color({dark = "nord3_gui", light = "fg"})
            },
            colored = false,
            render = function(_, count) return count end,
            fmt = function(status)
                if status == "0 0 0 0" then
                    return string.format(" %s ", lsp_symbols.ok)
                end
                return ''
            end
        }, literal(' ')
    },
    lualine_y = {
        {'filetype', colored = false, icon_only = true}, {
            'filetype',
            colored = false,
            icons_enabled = false,
            padding = 0,
            cond = conditions.hide_in_width,
            fmt = function(status) return status .. " " end
        }, literal(vim.env.TERM == "xterm-kitty" and '\\' or '|'),
        {'%l:%c', icon = "  "}
    },
    lualine_z = {
        {'%p%%', cond = conditions.hide_in_width},
        {scrollbar, padding = 0, color = {gui = "inverse"}}
    }
}

require('lualine').setup {
    options = {
        theme = nord_theme,
        component_separators = {left = "", right = ""},
        section_separators = section_separators
    },
    sections = sections,
    inactive_sections = vim.tbl_deep_extend("force", sections,
                                            {lualine_a = {}, lualine_x = {}})
}

local M = {}

function M.set_theme(theme_name)
    local theme = theme_name == 'nord_custom' and nord_theme or 'tokyonight'
    require('lualine').setup {options = {theme = theme}}
end

return M
