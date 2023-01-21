return {
  'rcarriga/nvim-notify',
  config = function()
    local lsp_symbols = require('tap.utils').lsp_symbols
    local highlight = require('tap.utils').highlight
    local color = require('tap.utils').color
    local nnoremap = require('tap.utils').nnoremap
    local apply_user_highlights = require('tap.utils').apply_user_highlights
    local isLspDebug = require('tap.utils.lsp').isLspDebug

    vim.notify = require 'notify'

    require('notify').setup {
      icons = {
        ERROR = lsp_symbols.error,
        WARN = lsp_symbols.warning,
        INFO = lsp_symbols.info,
        DEBUG = '',
        TRACE = '✎',
      },
      level = isLspDebug() and vim.log.levels.DEBUG or vim.log.levels.INFO,
    }

    require('telescope').load_extension 'notify'

    nnoremap(
      '<leader>nc',
      ":lua require('notify').dismiss()<CR>",
      { description = 'Clear notifications' }
    )

    apply_user_highlights('NvimNotify', function()
      -- stylua: ignore start
      highlight("NotifyERRORBorder", {guifg = color({dark = "nord11_gui", light = "red"})})
      highlight("NotifyWARNBorder", {guifg = color({dark = "nord13_gui", light = "yellow"})})
      highlight("NotifyINFOBorder", {guifg = color({dark = "nord10_gui", light = "blue2"})})
      highlight("NotifyDEBUGBorder", {guifg = color({dark = "nord7_gui", light = "cyan"})})
      highlight("NotifyTRACEBorder", {guifg = color({dark="nord15_gui", light="purple"})})

      highlight("NotifyERRORIcon", {guifg = color({dark = "nord11_gui", light = "red"})})
      highlight("NotifyWARNIcon", {guifg = color({dark = "nord13_gui", light = "yellow"})})
      highlight("NotifyINFOIcon", {guifg = color({dark = "nord10_gui", light = "blue2"})})
      highlight("NotifyDEBUGIcon", {guifg = color({dark = "nord7_gui", light = "cyan"})})
      highlight("NotifyTRACEIcon", {guifg = color({dark="nord15_gui", light="purple"})})

      highlight("NotifyERRORTitle", {guifg = color({dark = "nord11_gui", light = "red"})})
      highlight("NotifyWARNTitle", {guifg = color({dark = "nord13_gui", light = "yellow"})})
      highlight("NotifyINFOTitle", {guifg = color({dark = "nord10_gui", light = "blue2"})})
      highlight("NotifyDEBUGTitle", {guifg = color({dark = "nord7_gui", light = "cyan"})})
      highlight("NotifyTRACETitle", {guifg = color({dark="nord15_gui", light="purple"})})
      -- stylua: ignore end

      highlight('NotifyERRORBody', { link = 'Normal' })
      highlight('NotifyWARNBody', { link = 'Normal' })
      highlight('NotifyINFOBody', { link = 'Normal' })
      highlight('NotifyDEBUGBody', { link = 'Normal' })
      highlight('NotifyTRACEBody', { link = 'Normal' })
    end)
  end,
}
