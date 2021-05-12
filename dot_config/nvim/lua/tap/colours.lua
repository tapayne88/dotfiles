local highlight = require("tap.utils").highlight
local augroup = require("tap.utils").augroup
local nord_colors = require("tap.utils").nord_colors

vim.g.nvcode_termcolors = 256

-- Nord config if/when they merge treesitter support
vim.g.nord_italic = 1
vim.g.nord_italic_comments = 1
vim.g.nord_underline = 1
vim.g.nord_uniform_diff_background = 1
vim.g.nord_cursor_line_number_background = 1

vim.cmd [[colorscheme nord]]

local module = {}

function module.apply_user_highlights()
    highlight('Search', {guibg = nord_colors.nord9, guifg = nord_colors.nord0})
    highlight('IncSearch',
              {guibg = nord_colors.nord9, guifg = nord_colors.nord0})

    -- Treesitter overrides
    highlight('TSInclude', {gui = 'italic', cterm = 'italic'})
    highlight('TSOperator', {gui = 'italic', cterm = 'italic'})
    highlight('TSKeyword', {gui = 'italic', cterm = 'italic'})

    highlight('gitmessengerHeader', {link = 'Identifier'})
    highlight('gitmessengerHash', {link = 'Comment'})
    highlight('gitmessengerHistory', {link = 'Constant'})
    highlight('gitmessengerPopupNormal', {link = 'CursorLine'})
end

augroup("ExplorerHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = "lua require('tap.colours').apply_user_highlights()"
    }
})

return module

-- vim.cmd [[
-- " Patch CursorLine highlighting bug in NeoVim
-- " Messes with highlighting of current line in weird ways
-- " https://github.com/neovim/neovim/issues/9019#issuecomment-714806259
-- function! s:CustomizeColors()
--     if has('gui_running') || &termguicolors || exists('g:gonvim_running')
--         hi CursorLine ctermfg=white
--     else
--         hi CursorLine guifg=white
--     endif
-- endfunction

-- augroup OnColorScheme
--     autocmd!
--     autocmd ColorScheme,BufEnter,BufWinEnter * call s:CustomizeColors()
-- augroup END
-- ]]
