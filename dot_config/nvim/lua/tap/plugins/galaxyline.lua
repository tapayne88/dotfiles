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

local section_separators = vim.env.TERM_EMU == "kitty" and {"", ""} or
                               {"", ""}
local component_separators = vim.env.TERM_EMU == "kitty" and {'\\', '\\'} or
                                 {"|", "|"}

local themes = {
    dark = {
        primary = {
            highlight = function()
                return {color("fg"), color("dark2")}
            end,
            separator_highlight = function()
                return {color("dark2"), color("dark4")}
            end,
            sub_separator_highlight = function()
                return {color("fg"), color("dark2")}
            end
        },
        secondary = {
            highlight = function()
                return {color("fg"), color("dark4")}
            end,
            sub_separator_highlight = function()
                return {color("fg"), color("dark4")}
            end
        }
    },
    light = {
        primary = {
            highlight = function()
                return {color("bg"), color("fg_gutter")}
            end,
            separator_highlight = function()
                return {color("fg_gutter"), color("fg_dark")}
            end,
            sub_separator_highlight = function()
                return {color("bg"), color("fg_gutter")}
            end
        },
        secondary = {
            highlight = function()
                return {color("bg"), color("fg_dark")}
            end,
            sub_separator_highlight = function()
                return {color("bg"), color("fg_dark")}
            end
        }
    }
}

local function get_theme()
    if vim.g.use_light_theme then return themes.light end

    return themes.dark
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

                local next_section_bg = (condition.check_git_workspace() and
                                            color("dark2")) or color("dark4")

                highlight("GalaxyViMode",
                          {guifg = color("bg"), guibg = mode_color})
                highlight("GalaxyViModeInv",
                          {guibg = next_section_bg, guifg = mode_color})

                return string.format("  %s ", mode)
            end,
            separator = section_separators[1] .. " ",
            separator_highlight = "GalaxyViModeInv"
        }
    }, {
        GitBranch = {
            provider = 'GitBranch',
            icon = ' ',
            condition = condition.check_git_workspace,
            highlight = {color("fg"), color("dark2")}
        }
    }, {
        ASpace = {
            provider = function() return " " end,
            condition = condition.check_git_workspace,
            highlight = get_theme().primary.highlight,
            separator = section_separators[1] .. " ",
            separator_highlight = get_theme().primary.separator_highlight
        }
    }, {
        FileName = {
            provider = 'FileName',
            highlight = get_theme().secondary.highlight
        }
    }
}

gl.section.right = {
    {
        DiagnosticError = {
            provider = 'DiagnosticError',
            icon = lsp_symbols["error"] .. " ",
            highlight = {lsp_colors.error, color("dark4")}
        }
    }, {
        DiagnosticWarn = {
            provider = 'DiagnosticWarn',
            icon = lsp_symbols["warning"] .. " ",
            highlight = {lsp_colors.warning, color("dark4")}
        }
    }, {
        DiagnosticHint = {
            provider = 'DiagnosticHint',
            icon = lsp_symbols["hint"] .. " ",
            highlight = {lsp_colors.hint, color("dark4")}
        }
    }, {
        DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            icon = lsp_symbols["info"] .. " ",
            highlight = {lsp_colors.info, color("dark4")}
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
            highlight = get_theme().secondary.highlight
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
            highlight = get_theme().secondary.highlight
        }
    }, {
        FileInfo = {
            provider = function()
                local filetype =
                    condition.hide_in_width() and vim.bo.filetype or ""
                local icon = fileinfo.get_file_icon()
                return string.format(" %s%s ", icon, filetype)
            end,
            highlight = get_theme().primary.highlight,
            separator = section_separators[2],
            separator_highlight = get_theme().primary.separator_highlight
        }
    }, {
        LineInfo = {
            provider = 'LineColumn',
            icon = " ≡ ",
            condition = condition.hide_in_width,
            highlight = get_theme().primary.highlight,
            separator = component_separators[2],
            separator_highlight = get_theme().primary.sub_separator_highlight
        }
    }, {
        NotASpace = {
            provider = function() return "" end,
            separator = section_separators[2],
            separator_highlight = 'GalaxyViModeInv'
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
            highlight = 'GalaxyViModeInv'
        }
    }
}

gl.section.short_line_left = {
    {
        GitBranchInactive = {
            provider = 'GitBranch',
            icon = ' ',
            condition = condition.check_git_workspace,
            highlight = get_theme().primary.highlight
        }
    }, {
        ASpaceInactive = {
            provider = function() return " " end,
            highlight = get_theme().primary.highlight,
            separator = section_separators[1] .. " ",
            separator_highlight = get_theme().primary.separator_highlight
        }
    }, {
        FileNameInactive = {
            provider = 'FileName',
            highlight = get_theme().secondary.highlight
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
            highlight = get_theme().secondary.highlight
        }
    }, {
        LineInfoInactive = {
            provider = 'LineColumn',
            icon = " ≡ ",
            condition = condition.hide_in_width,
            highlight = get_theme().secondary.highlight,
            separator = component_separators[2],
            separator_highlight = get_theme().secondary.sub_separator_highlight
        }
    }, {
        NotASpaceInactive = {
            provider = function() return "" end,
            separator = section_separators[2],
            separator_highlight = get_theme().secondary.sub_separator_highlight
        }
    }, {
        PerCentInactive = {
            provider = 'LinePercent',
            condition = condition.hide_in_width,
            highlight = {color("dark2"), color("fg")}
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
            highlight = get_theme().primary.highlight
        }
    }
}
