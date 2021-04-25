local section_separators = vim.env.TERM_EMU == "kitty" and { "", " " } or {}
local component_separators = vim.env.TERM_EMU == "kitty" and { '\\', '\\' } or {}

require('lualine').setup{
  options = {
    theme = 'nord',
    section_separators = section_separators,
    component_separators = component_separators,
    icons_enabled = true,
  },
  sections = {
    lualine_a = { {'mode', upper = true} },
    lualine_b = { {'branch', icon = ''} },
    lualine_c = { {'filename', file_status = true} },
    lualine_x = { {'diagnostics', sources = {'nvim_lsp'}} },
    lualine_y = { 'filetype', {'progress', icon = "≡"} },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = { 'progress' },
    lualine_y = { 'location' },
    lualine_z = {},
  }
}
