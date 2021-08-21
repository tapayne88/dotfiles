local gl = require('galaxyline')
local diagnostic = require('galaxyline.provider_diagnostic')
local fileinfo = require('galaxyline.provider_fileinfo')
local extension = require('galaxyline.provider_extensions')
local condition = require('galaxyline.condition')
local color = require("tap.utils").color
local lsp_colors = require("tap.utils").lsp_colors
local lsp_symbols = require("tap.utils").lsp_symbols
local highlight = require("tap.utils").highlight
local get_lsp_clients = require("tap.lsp.utils").get_lsp_clients

gl.short_line_list = {'NvimTree', 'vista', 'dbui', 'packer'}

local section_separators = vim.env.TERM == "xterm-kitty" and {"", ""} or
                               {"", ""}
local component_separators = vim.env.TERM == "xterm-kitty" and {'\\', '\\'} or
                                 {"|", "|"}

local function theme_wrapper(themes)
    return function()
        local color_names = (vim.g.use_light_theme and themes.light) or
                                themes.dark

        return vim.tbl_map(color, color_names)
    end
end

local theme = {
    mode = {highlight = theme_wrapper({dark = {"bg"}, light = {"bg"}})},
    primary = {
        highlight = theme_wrapper({
            dark = {"fg", "dark1"},
            light = {"blue7", "fg_dark"}
        }),
        highlight_alt = theme_wrapper({
            dark = {"dark1", "fg"},
            light = {"fg_dark", "blue7"}
        }),
        separator_highlight = theme_wrapper({
            dark = {"dark1", "dark3"},
            light = {"fg_dark", "fg"}
        }),
        sub_separator_highlight = theme_wrapper({
            dark = {"fg", "dark1"},
            light = {"blue7", "fg_dark"}
        })
    },
    secondary = {
        highlight = theme_wrapper({
            dark = {"fg", "dark3"},
            light = {"blue7", "fg"}
        }),
        sub_separator_highlight = theme_wrapper({
            dark = {"fg", "dark3"},
            light = {"blue7", "fg"}
        })
    }
}

local function diagnostic_color(color_name)
    return function()
        return {lsp_colors(color_name), theme.secondary.highlight()[2]}
    end
end

local function mode_map(name)
    local modes = {
        ['n'] = {'NORMAL', color("blue1")},
        ['i'] = {'INSERT', color("fg")},
        ['r'] = {'REPLACE', color("yellow")},
        ['R'] = {'REPLACE', color("yellow")},
        ['v'] = {'VISUAL', color("cyan")},
        ['V'] = {'V-LINE', color("cyan")},
        ['c'] = {'COMMAND', color("blue1")},
        ['s'] = {'SELECT', color("blue1")},
        ['S'] = {'S-LINE', color("blue1")},
        ['t'] = {'TERMINAL', color("blue1")},
        [''] = {'V-BLOCK', color("cyan")},
        [''] = {'S-BLOCK', color("blue1")},
        ['Rv'] = {'VIRTUAL', color("red")},
        ['rm'] = {'--MORE', color("red")}
    }
    return modes[name]
end

gl.section.left = {
    {
        ViMode = {
            provider = function()
                local mode, mode_color = unpack(
                                             mode_map(vim.fn.mode()) or
                                                 {"unknown", color("red")})

                local next_section_git = theme.primary.highlight()[2]
                local next_section_no_git = theme.secondary.highlight()[2]

                highlight("GalaxyViMode", {
                    guifg = theme.mode.highlight()[1],
                    guibg = mode_color
                })
                highlight("GalaxyViModeSepGit",
                          {guibg = next_section_git, guifg = mode_color})
                highlight("GalaxyViModeSepNoGit",
                          {guibg = next_section_no_git, guifg = mode_color})

                return string.format("  %s ", mode)
            end,
            separator = section_separators[1] .. " ",
            separator_highlight = function()
                return
                    condition.check_git_workspace() and "GalaxyViModeSepGit" or
                        "GalaxyViModeSepNoGit"
            end
        }
    }, {
        GitBranch = {
            provider = 'GitBranch',
            icon = ' ',
            condition = condition.check_git_workspace,
            highlight = theme.primary.highlight
        }
    }, {
        ASpace = {
            provider = function() return " " end,
            condition = condition.check_git_workspace,
            highlight = theme.primary.highlight,
            separator = section_separators[1] .. " ",
            separator_highlight = theme.primary.separator_highlight
        }
    },
    {FileName = {provider = 'FileName', highlight = theme.secondary.highlight}}
}

gl.section.right = {
    {
        DiagnosticError = {
            provider = 'DiagnosticError',
            icon = lsp_symbols["error"] .. " ",
            highlight = diagnostic_color("error")
        }
    }, {
        DiagnosticWarn = {
            provider = 'DiagnosticWarn',
            icon = lsp_symbols["warning"] .. " ",
            highlight = diagnostic_color("warning")
        }
    }, {
        DiagnosticHint = {
            provider = 'DiagnosticHint',
            icon = lsp_symbols["hint"] .. " ",
            highlight = diagnostic_color("hint")
        }
    }, {
        DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            icon = lsp_symbols["info"] .. " ",
            highlight = diagnostic_color("info")
        }
    }, {
        DiagnosticOk = {
            provider = function()
                local diags = {
                    diagnostic.get_diagnostic_error(),
                    diagnostic.get_diagnostic_warn(),
                    diagnostic.get_diagnostic_hint(),
                    diagnostic.get_diagnostic_info()
                }

                local diag_string = table.concat(vim.tbl_values(diags))
                if diag_string == "" then
                    return lsp_symbols["ok"] .. " "
                end
                return ""
            end,
            highlight = theme.secondary.highlight
        }
    }, {
        TscVersion = {
            provider = function()
                if vim.g.tsc_version ~= nil then
                    local client_version =
                        vim.tbl_map(function(client)
                            return vim.g.tsc_version["client_" .. client.id]
                        end, get_lsp_clients())

                    local file_versions =
                        vim.tbl_filter(function(version)
                            return version ~= nil
                        end, client_version)

                    if #file_versions > 0 then
                        return string.format("v%s ", file_versions[1])

                    end
                end
                return ""
            end,
            condition = condition.hide_in_width,
            highlight = theme.secondary.highlight
        }
    }, {
        FileInfo = {
            provider = function()
                local filetype =
                    condition.hide_in_width() and vim.bo.filetype or ""
                local icon = fileinfo.get_file_icon()
                return string.format(" %s%s ", icon, filetype)
            end,
            highlight = theme.primary.highlight,
            separator = section_separators[2],
            separator_highlight = theme.primary.separator_highlight
        }
    }, {
        LineInfo = {
            provider = 'LineColumn',
            icon = "  ",
            condition = condition.hide_in_width,
            highlight = theme.primary.highlight,
            separator = component_separators[2],
            separator_highlight = theme.primary.sub_separator_highlight
        }
    }, {
        NotASpace = {
            provider = function() return "" end,
            separator = section_separators[2],
            separator_highlight = 'GalaxyViModeSepGit'
        }
    }, {
        PerCent = {
            provider = 'LinePercent',
            condition = condition.hide_in_width,
            highlight = 'GalaxyViMode'
        }
    }, {
        ScrollBar = {
            provider = function()
                local scrollbars = {
                    '██', '▇▇', '▆▆', '▅▅', '▄▄', '▃▃',
                    '▂▂', '▁▁', '__'
                }
                return extension.scrollbar_instance(scrollbars)
            end,
            highlight = 'GalaxyViModeSepGit'
        }
    }
}

gl.section.short_line_left = {
    {
        GitBranchInactive = {
            provider = 'GitBranch',
            icon = ' ',
            condition = condition.check_git_workspace,
            highlight = theme.primary.highlight
        }
    }, {
        ASpaceInactive = {
            provider = function() return " " end,
            highlight = theme.primary.highlight,
            separator = section_separators[1] .. " ",
            separator_highlight = theme.primary.separator_highlight
        }
    }, {
        FileNameInactive = {
            provider = 'FileName',
            highlight = theme.secondary.highlight
        }
    }
}

gl.section.short_line_right = {
    {
        FileInfoInactive = {
            provider = function()
                local filetype =
                    condition.hide_in_width() and vim.bo.filetype or ""
                local icon = fileinfo.get_file_icon()
                return string.format(" %s%s ", icon, filetype)
            end,
            highlight = theme.secondary.highlight
        }
    }, {
        LineInfoInactive = {
            provider = 'LineColumn',
            icon = "  ",
            condition = condition.hide_in_width,
            highlight = theme.secondary.highlight,
            separator = component_separators[2],
            separator_highlight = theme.secondary.sub_separator_highlight
        }
    }, {
        NotASpaceInactive = {
            provider = function() return "" end,
            separator = section_separators[2],
            separator_highlight = theme.secondary.sub_separator_highlight
        }
    }, {
        PerCentInactive = {
            provider = 'LinePercent',
            condition = condition.hide_in_width,
            highlight = theme.primary.highlight_alt
        }
    }, {
        ScrollBarInactive = {
            provider = function()
                local scrollbars = {
                    '██', '▇▇', '▆▆', '▅▅', '▄▄', '▃▃',
                    '▂▂', '▁▁', '__'
                }
                return extension.scrollbar_instance(scrollbars)
            end,
            highlight = theme.primary.highlight
        }
    }
}
