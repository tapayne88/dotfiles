local utils = require 'tap.utils'
local neotest_jest_util = require 'neotest-jest.util'

require('neotest').setup {
  discovery = {
    enabled = false,
  },
  highlights = {
    failed = 'NeotestFailed',
    passed = 'NeotestPassed',
    running = 'NeotestRunning',
    skipped = 'NeotestSkipped',
    unknown = 'NeotestUnknown',
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
      jestConfigFile = function(path)
        local jest_js_config_parent = neotest_jest_util.root_pattern {
          'jest.config.js',
        }(path)
        local jest_ts_config_parent = neotest_jest_util.root_pattern {
          'jest.config.ts',
        }(path)
        local package_json_parent = neotest_jest_util.root_pattern {
          'package.json',
        }(path)

        if package_json_parent == jest_js_config_parent then
          return neotest_jest_util.path.join(
            jest_js_config_parent,
            'jest.config.js'
          )
        end
        if package_json_parent == jest_ts_config_parent then
          return neotest_jest_util.path.join(
            jest_ts_config_parent,
            'jest.config.ts'
          )
        end

        return ''
      end,
      env = { CI = true },
    },
  },
}

utils.apply_user_highlights('Neotest', function()
  utils.highlight('NeotestPassed', { guifg = utils.lsp_colors 'ok' })
  utils.highlight('NeotestFailed', { link = 'DiagnosticError' })
  utils.highlight('NeotestRunning', { link = 'DiagnosticInfo' })
  utils.highlight('NeotestSkipped', { link = 'DiagnosticInfo' })
  utils.highlight('NeotestUnknown', { link = 'DiagnosticInfo' })
end)

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
utils.nnoremap(
  't<C-s>',
  require('neotest').summary.toggle,
  { description = '[Neotest] Attach running test output' }
)
