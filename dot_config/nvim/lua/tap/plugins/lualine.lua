local get_lsp_clients = require("tap.lsp.utils").get_lsp_clients

local colors = {
    red = '#ca1243',
    grey = '#a0a1a7',
    black = '#383a42',
    white = '#f3f3f3',
    light_green = '#83a598',
    orange = '#fe8019',
    green = '#8ec07c'
}

local empty = require('lualine.component'):extend()
function empty:draw(default_highlight)
    self.status = ''
    self.applied_separator = ''
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
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

require('lualine').setup {
    options = {
        theme = 'nord',
        component_separators = vim.env.TERM == "xterm-kitty" and
            {left = '\\', right = '\\'} or {left = "|", right = "|"},
        section_separators = vim.env.TERM == "xterm-kitty" and
            {left = "", right = ""} or {left = "", right = ""}
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
                source = {'nvim'},
                sections = {'error'},
                diagnostics_color = {
                    error = {bg = colors.red, fg = colors.white}
                }
            }, {
                'diagnostics',
                source = {'nvim'},
                sections = {'warn'},
                diagnostics_color = {
                    warn = {bg = colors.orange, fg = colors.white}
                }
            }, {
                'diagnostics',
                source = {'nvim'},
                sections = {'hint'},
                diagnostics_color = {
                    warn = {bg = colors.orange, fg = colors.white}
                }
            }, {
                'diagnostics',
                source = {'nvim'},
                sections = {'info'},
                diagnostics_color = {
                    warn = {bg = colors.orange, fg = colors.white}
                }
            }, {
                'diagnostics',
                source = {'nvim'},
                sections = {'ok'},
                diagnostics_color = {
                    warn = {bg = colors.orange, fg = colors.white}
                }
            }
        },
        lualine_y = {'filetype', {'%l:%c', icon = "  "}},
        lualine_z = {'%p%%', scrollbar}
    },
    inactive_sections = {lualine_c = {'%f %y %m'}, lualine_x = {}}
}
