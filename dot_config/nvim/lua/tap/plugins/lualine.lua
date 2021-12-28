local color = require("tap.utils").color
local lsp_colors = require("tap.utils").lsp_colors
local lsp_symbols = require("tap.utils").lsp_symbols
local highlight = require("tap.utils").highlight
local augroup = require("tap.utils").augroup
local get_lsp_clients = require("tap.lsp.utils").get_lsp_clients
local get_tsc_version = require("tap.lsp.servers.tsserver").get_tsc_version

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
    has_lsp = function() return #get_lsp_clients() > 0 end,
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

local filetype = require('lualine.components.filetype'):extend()
function filetype:draw(default_highlight, is_focused)
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

local diagnostic_empty = require('lualine.components.diagnostics'):extend()
function diagnostic_empty:draw(default_highlight, is_focused)
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
    local tsc_version = get_tsc_version()

    return tsc_version and string.format("v%s", tsc_version) or ""
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

local supports_slanted_blocks = vim.env.TERM == "xterm-kitty"
local section_separators = supports_slanted_blocks and
                               {left = "", right = ""} or
                               {left = "", right = ""}

local diagnostic_section = function(cfg)
    local default_cfg = {
        diagnostic_empty,
        source = {'nvim_diagnostic'},
        separator = {
            left = section_separators.right,
            right = section_separators.left
        },
        -- no padding so the slanty isn't too wide when no diagnostics
        padding = 0,
        fmt = function(status)
            if tonumber(status, 10) > 0 then
                -- stitch the icon onto the count
                return string.format(' %s%s ', cfg.symbol, status)
            end

            -- Count is 0 so don't return content
            return supports_slanted_blocks and '' or ' '
        end,
        -- supress the symbols, default still shows 'E: 1' etc.
        symbols = {error = '', warn = '', hint = '', info = ''},
        -- don't want any color output adding to the diagnostics
        colored = false,
        -- always show the slanty, it'll be empty if there are none for that type
        always_visible = true,
        -- only show when we have an lsp attached - this may need updating if I
        -- use other sources for diagnostics
        cond = conditions.has_lsp
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
            color = 'LualineDiagnosticError',
            symbol = lsp_symbols.error
        }, diagnostic_section {
            sections = {'warn'},
            color = 'LualineDiagnosticWarn',
            symbol = lsp_symbols.warning
        }, diagnostic_section {
            sections = {'hint'},
            color = 'LualineDiagnosticHint',
            symbol = lsp_symbols.hint
        }, diagnostic_section {
            sections = {'info'},
            color = 'LualineDiagnosticInfo',
            symbol = lsp_symbols.info
        }, diagnostic_section {
            sections = {'error', 'warn', 'hint', 'info'},
            color = 'LualineDiagnosticOk',
            fmt = function(status)
                -- diagnostics will only report numbers so if they are all 0
                -- then we are all ok
                if status == "0 0 0 0" then
                    return string.format(" %s ", lsp_symbols.ok)
                end
                return ''
            end
        }, literal(' ')
    },
    lualine_y = {
        literal(' '), {
            filetype,
            colored = false,
            padding = 0,
            fmt = function(status)
                return conditions.hide_in_width() and status .. " " or ""
            end
        }, literal(vim.env.TERM == "xterm-kitty" and '\\' or '|'),
        {'%l:%c', icon = ""}
    },
    lualine_z = {
        {'%p%%', cond = conditions.hide_in_width},
        {scrollbar, padding = 0, color = {gui = "inverse"}}
    }
}

local function apply_user_highlights()
    highlight('LualineDiagnosticError', {
        guibg = lsp_colors("error"),
        guifg = color({dark = "nord3_gui", light = "fg"})
    })
    highlight('LualineDiagnosticWarn', {
        guibg = lsp_colors("warning"),
        guifg = color({dark = "nord3_gui", light = "fg"})
    })
    highlight('LualineDiagnosticHint', {
        guibg = lsp_colors("hint"),
        guifg = color({dark = "nord3_gui", light = "fg"})
    })
    highlight('LualineDiagnosticInfo', {
        guibg = lsp_colors("info"),
        guifg = color({dark = "nord3_gui", light = "fg"})
    })
    highlight('LualineDiagnosticOk', {
        guibg = lsp_colors("ok"),
        guifg = color({dark = "nord3_gui", light = "fg"})
    })
end

augroup("LualineHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = apply_user_highlights
    }
})

apply_user_highlights()

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
    local theme = theme_name == 'nord_custom' and nord_theme or theme_name
    require('lualine').setup {options = {theme = theme}}
end

return M
