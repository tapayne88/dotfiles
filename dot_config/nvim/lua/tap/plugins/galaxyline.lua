local gl = require('galaxyline')
local vcs = require('galaxyline.provider_vcs')
local diagnostic = require('galaxyline.provider_diagnostic')
local fileinfo = require('galaxyline.provider_fileinfo')
local condition = require('galaxyline.condition')
local nord_colors = require("tap.utils").nord_colors
local lsp_colors = require("tap.utils").lsp_colors
local lsp_symbols = require("tap.utils").lsp_symbols
local highlight = require("tap.utils").highlight
local has_lsp_clients = require("tap.lsp.utils").has_lsp_clients

gl.short_line_list = {'NvimTree', 'vista', 'dbui', 'packer'}

local section_separators = vim.env.TERM_EMU == "kitty" and {"", ""} or
                               {"", ""}
local component_separators = vim.env.TERM_EMU == "kitty" and {'\\', '\\'} or
                                 {"|", "|"}

local colors = {bg = nord_colors.nord3}

local mode_map = {
    ['n'] = {'NORMAL', nord_colors.nord8},
    ['i'] = {'INSERT', nord_colors.nord6},
    ['R'] = {'REPLACE', nord_colors.nord13},
    ['v'] = {'VISUAL', nord_colors.nord7},
    ['V'] = {'V-LINE', nord_colors.nord7},
    ['c'] = {'COMMAND', nord_colors.nord8},
    ['s'] = {'SELECT', nord_colors.nord8},
    ['S'] = {'S-LINE', nord_colors.nord8},
    ['t'] = {'TERMINAL', nord_colors.nord8},
    [''] = {'V-BLOCK', nord_colors.nord7},
    [''] = {'S-BLOCK', nord_colors.nord8},
    ['Rv'] = {'VIRTUAL', nord_colors.nord11},
    ['rm'] = {'--MORE', nord_colors.nord11}
}

gl.section.left = {
    {
        ViMode = {
            provider = function()
                local mode, color = unpack(
                                        mode_map[vim.fn.mode()] or
                                            {"unknown", nord_colors.nord11})

                local next_section_bg = (condition.check_git_workspace() and
                                            nord_colors.nord1) or colors.bg

                highlight("GalaxyViMode",
                          {guifg = nord_colors.nord0, guibg = color})
                highlight("GalaxyViModeInv",
                          {guibg = next_section_bg, guifg = color})

                return string.format("  %s ", mode)
            end,
            separator = section_separators[1] .. " ",
            separator_highlight = "GalaxyViModeInv"
        }
    }, {
        GitBranch = {
            provider = function()
                return string.format(' %s ', vcs.get_git_branch())
            end,
            condition = condition.check_git_workspace,
            separator = section_separators[1] .. " ",
            separator_highlight = {nord_colors.nord1, colors.bg},
            highlight = {'NONE', nord_colors.nord1}
        }
    }, {FileName = {provider = 'FileName', highlight = {'NONE', colors.bg}}}
}

gl.section.right = {
    {
        DiagnosticError = {
            provider = 'DiagnosticError',
            icon = lsp_symbols["error"] .. " ",
            highlight = {lsp_colors.error, colors.bg}
        }
    }, {
        DiagnosticWarn = {
            provider = 'DiagnosticWarn',
            icon = lsp_symbols["warning"] .. " ",
            highlight = {lsp_colors.warning, colors.bg}
        }
    }, {
        DiagnosticHint = {
            provider = 'DiagnosticHint',
            icon = lsp_symbols["hint"] .. " ",
            highlight = {lsp_colors.hint, colors.bg}
        }
    }, {
        DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            icon = lsp_symbols["info"] .. " ",
            highlight = {lsp_colors.info, colors.bg}
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
            highlight = {'NONE', colors.bg}
        }
    }, {
        TscVersion = {
            provider = function()
                if has_lsp_clients() then
                    if vim.b.tsc_version ~= nil then
                        return string.format("v%s ", vim.b.tsc_version)
                    end

                    return ""
                end
            end,
            highlight = {'NONE', colors.bg}
        }
    }, {
        FileInfo = {
            provider = function()
                local filetype = vim.bo.filetype
                local icon = fileinfo.get_file_icon()
                return string.format(" %s%s ", icon, filetype)
            end,
            condition = condition.hide_in_width,
            separator = section_separators[2],
            separator_highlight = {nord_colors.nord1, colors.bg},
            highlight = {'NONE', nord_colors.nord1}
        }
    }, {
        LineInfo = {
            provider = 'LineColumn',
            icon = " ≡",
            separator = component_separators[2],
            separator_highlight = {'NONE', nord_colors.nord1},
            highlight = {'NONE', nord_colors.nord1}
        }
    }, {
        PerCent = {
            provider = 'LinePercent',
            separator = section_separators[2],
            separator_highlight = 'GalaxyViModeInv',
            highlight = 'GalaxyViMode'
        }
    }, {
        ScrollBar = {
            provider = 'ScrollBar',
            highlight = {nord_colors.nord8, colors.bg}
        }
    }
}

gl.section.short_line_left = {
    {
        GitBranchInactive = {
            provider = function()
                return string.format('   %s ', vcs.get_git_branch())
            end,
            condition = condition.check_git_workspace,
            separator = section_separators[1] .. " ",
            separator_highlight = {nord_colors.nord1, colors.bg},
            highlight = {'NONE', nord_colors.nord1}
        }
    },
    {
        FileNameInactive = {
            provider = 'FileName',
            highlight = {'NONE', colors.bg}
        }
    }
}

gl.section.short_line_right = {
    {
        FileInfoInactive = {
            provider = function()
                local filetype = vim.bo.filetype
                local icon = fileinfo.get_file_icon()
                return string.format(" %s%s ", icon, filetype)
            end,
            condition = condition.hide_in_width,
            highlight = {'NONE', colors.bg}
        }
    }, {
        LineInfoInactive = {
            provider = 'LineColumn',
            icon = " ≡",
            separator = component_separators[2],
            separator_highlight = {'NONE', colors.bg},
            highlight = {'NONE', colors.bg}
        }
    }, {
        PerCentInactive = {
            provider = 'LinePercent',
            separator = section_separators[2],
            separator_highlight = {nord_colors.nord1, colors.bg},
            highlight = {'NONE', nord_colors.nord1}
        }
    }, {
        ScrollBarInactive = {
            provider = 'ScrollBar',
            highlight = {'NONE', nord_colors.nord1}
        }
    }
}
