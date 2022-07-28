local utils = require 'tap.utils'

require('neotest').setup {
  discovery = {
    enabled = false,
  },
  icons = {
    failed = utils.lsp_symbols.error,
    passed = utils.lsp_symbols.ok,
    running = '',
    skipped = 'ﰸ',
    unknown = '',
  },
  adapters = {
    require 'neotest-jest' {
      jestCommand = 'npm test --',
      jestConfigFile = function()
        return ''
      end,
    },
  },
}

utils.nnoremap('t<C-f>', function()
  require('neotest').run.run(vim.fn.expand '%')
end, { description = '[Neotest] Test file' })
utils.nnoremap(
  't<C-n>',
  require('neotest').run.run,
  { description = '[Neotest] Test nearest' }
)
utils.nnoremap(
  't<C-a>',
  require('neotest').run.attach,
  { description = '[Neotest] Attach running test output' }
)
