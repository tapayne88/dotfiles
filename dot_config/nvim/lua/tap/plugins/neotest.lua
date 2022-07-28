require('neotest').setup {
  discovery = {
    enabled = false,
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
