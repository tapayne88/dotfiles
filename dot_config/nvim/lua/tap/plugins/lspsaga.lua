local saga = require('lspsaga')
local utils = require("tap.utils")

local module = {}

local apply_user_highlights = function()
    utils.highlight('LspSagaDiagnosticBorder',
                    {link = 'LspSagaDefPreviewBorder'})
    utils.highlight('LspSagaDiagnosticHeader',
                    {link = 'LspSagaDefPreviewBorder'})
    utils.highlight('LspSagaDiagnosticTruncateLine',
                    {link = 'LspSagaDefPreviewBorder'})
    utils.highlight('LspSagaSignatureHelpBorder',
                    {link = 'LspSagaDefPreviewBorder'})

    utils.highlight("LspDiagnosticsFloatingError",
                    {guifg = utils.lsp_colors("error")})
    utils.highlight("LspDiagnosticsFloatingWarning",
                    {guifg = utils.lsp_colors("warning")})
    utils.highlight("LspDiagnosticsFloatingInfor",
                    {guifg = utils.lsp_colors("info")})
    utils.highlight("LspDiagnosticsFloatingHint",
                    {guifg = utils.lsp_colors("hint")})
end

module.init = function()
    apply_user_highlights()

    saga.init_lsp_saga({
        error_sign = utils.lsp_symbols["error"],
        warn_sign = utils.lsp_symbols["warning"],
        infor_sign = utils.lsp_symbols["info"],
        hint_sign = utils.lsp_symbols["hint"],
        border_style = "round",
        code_action_prompt = {enable = false}
    })
end

module.on_attach = function()
    utils.augroup("LspSagaCursor", {
        {
            events = {"CursorHold"},
            targets = {"<buffer>"},
            command = "lua require('lspsaga.diagnostic').show_cursor_diagnostics()"

        }
    })

    utils.nnoremap("<leader>cc",
                   "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>")
    utils.inoremap("<c-l>",
                   "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>")

end

utils.augroup("LspSagaHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = apply_user_highlights
    }
})

return module
