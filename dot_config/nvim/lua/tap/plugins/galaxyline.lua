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

local theme = {
    mode = {
        highlight = function()
            return {color({dark = "nord0_gui", light = "bg"})}
        end
    },
    primary = {
        highlight = function()
            local c = {
                color({dark = "nord4_gui", light = "blue7"}),
                color({dark = "nord1_gui", light = "fg_dark"})
            }
            return c
        end,
        highlight_alt = function()
            return {
                color({dark = "nord1_gui", light = "fg_dark"}),
                color({dark = "nord4_gui", light = "blue7"})
            }
        end,
        separator_highlight = function()
            return {
                color({dark = "nord1_gui", light = "fg_dark"}),
                color({dark = "nord3_gui", light = "fg"})
            }
        end,
        sub_separator_highlight = function()
            return {
                color({dark = "nord4_gui", light = "blue7"}),
                color({dark = "nord1_gui", light = "fg_dark"})
            }
        end
    },
    secondary = {
        highlight = function()
            return {
                color({dark = "nord4_gui", light = "blue7"}),
                color({dark = "nord3_gui", light = "fg"})
            }
        end,
        sub_separator_highlight = function()
            return {
                color({dark = "nord4_gui", light = "blue7"}),
                color({dark = "nord3_gui", light = "fg"})
            }
        end
    }
}

local function mode_map(name)
    local modes = {
        ['n'] = {'NORMAL', color({dark = "nord8_gui", light = "blue"})},
        ['i'] = {'INSERT', color({dark = "nord4_gui", light = "fg"})},
        ['r'] = {'REPLACE', color({dark = "nord13_gui", light = "yellow"})},
        ['R'] = {'REPLACE', color({dark = "nord13_gui", light = "yellow"})},
        ['v'] = {'VISUAL', color({dark = "nord7_gui", light = "cyan"})},
        ['V'] = {'V-LINE', color({dark = "nord7_gui", light = "cyan"})},
        ['c'] = {'COMMAND', color({dark = "nord8_gui", light = "blue"})},
        ['s'] = {'SELECT', color({dark = "nord8_gui", light = "blue"})},
        ['S'] = {'S-LINE', color({dark = "nord8_gui", light = "blue"})},
        ['t'] = {'TERMINAL', color({dark = "nord8_gui", light = "blue"})},
        [''] = {'V-BLOCK', color({dark = "nord7_gui", light = "cyan"})},
        [''] = {'S-BLOCK', color({dark = "nord8_gui", light = "blue"})},
        ['Rv'] = {'VIRTUAL', color({dark = "nord11_gui", light = "red"})},
        ['rm'] = {'--MORE', color({dark = "nord11_gui", light = "red"})}
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
        DiagnosticError = {
            provider = function()
                local diag = diagnostic.get_diagnostic_error()
                local content = diag == nil and "" or
                                    (" " .. lsp_symbols["error"] .. diag)

                return string.format("%s%s", section_separators[1], content)
            end,
            highlight = function()
                return {theme.secondary.highlight()[2], lsp_colors("error")}
            end
        }
    }, {
        DiagnosticWarn = {
            provider = function()
                local diag = diagnostic.get_diagnostic_warn()
                local content = diag == nil and "" or
                                    (" " .. lsp_symbols["warning"] .. diag)

                return content
            end,
            highlight = function()
                return {theme.secondary.highlight()[2], lsp_colors("warning")}
            end,
            separator = section_separators[1],
            separator_highlight = function()
                return {lsp_colors("error"), lsp_colors("warning")}
            end
        }
    }, {
        DiagnosticHint = {
            provider = function()
                local diag = diagnostic.get_diagnostic_hint()
                local content = diag == nil and "" or
                                    (" " .. lsp_symbols["hint"] .. diag)

                return content
            end,
            highlight = function()
                return {theme.secondary.highlight()[2], lsp_colors("hint")}
            end,
            separator = section_separators[1],
            separator_highlight = function()
                return {lsp_colors("warning"), lsp_colors("hint")}
            end
        }
    }, {
        DiagnosticInfo = {
            provider = function()
                local diag = diagnostic.get_diagnostic_info()
                local content = diag == nil and "" or
                                    (" " .. lsp_symbols["info"] .. diag)

                return content
            end,
            highlight = function()
                return {theme.secondary.highlight()[2], lsp_colors("info")}
            end,
            separator = section_separators[1],
            separator_highlight = function()
                return {lsp_colors("hint"), lsp_colors("info")}
            end
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
                    return " " .. lsp_symbols["ok"]
                end
                return ""
            end,
            highlight = function()
                return {theme.secondary.highlight()[2], lsp_colors("ok")}
            end,
            separator = section_separators[1],
            separator_highlight = function()
                return {lsp_colors("info"), lsp_colors("ok")}
            end
        }
    }, {
        DiagnosticClose = {
            provider = function() return " " end,
            highlight = function()
                return {
                    theme.secondary.highlight()[2],
                    theme.secondary.highlight()[2]
                }
            end,
            separator = section_separators[1],
            separator_highlight = function()
                return {lsp_colors("ok"), theme.secondary.highlight()[2]}
            end
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
