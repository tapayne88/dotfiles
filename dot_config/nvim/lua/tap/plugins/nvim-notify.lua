local lsp_symbols = require("tap.utils").lsp_symbols

vim.notify = require("notify")

require("notify").setup {
    icons = {
        ERROR = lsp_symbols.error,
        WARN = lsp_symbols.warning,
        INFO = lsp_symbols.info,
        DEBUG = "",
        TRACE = "✎"
    }
}
