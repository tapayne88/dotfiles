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

local theme = {
    normal = {
        a = {fg = colors.white, bg = colors.black},
        b = {fg = colors.white, bg = colors.grey},
        c = {fg = colors.black, bg = colors.white},
        z = {fg = colors.white, bg = colors.black}
    },
    insert = {a = {fg = colors.black, bg = colors.light_green}},
    visual = {a = {fg = colors.black, bg = colors.orange}},
    replace = {a = {fg = colors.black, bg = colors.green}}
}

local empty = require('lualine.component'):extend()
function empty:draw(default_highlight)
    self.status = ''
    self.applied_separator = ''
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    return self.status
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
    for name, section in pairs(sections) do
        local left = name:sub(9, 10) < 'x'
        for pos = 1, name ~= 'lualine_z' and #section or #section - 1 do
            table.insert(section, pos * 2, {
                empty,
                color = {fg = colors.white, bg = colors.white}
            })
        end
        for id, comp in ipairs(section) do
            if type(comp) ~= 'table' then
                comp = {comp}
                section[id] = comp
            end
            comp.separator = left and {right = ''} or {left = ''}
        end
    end
    return sections
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
        theme = theme,
        component_separators = '',
        section_separators = {left = '', right = ''}
    },
    sections = process_sections {
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
