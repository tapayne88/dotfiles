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
