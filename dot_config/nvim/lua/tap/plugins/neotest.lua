require('neotest').setup {
  adapters = {
    require 'neotest-jest' {
      jestCommand = 'npm test --',
      jestConfigFile = function()
        return ''
      end,
    },
  },
}
