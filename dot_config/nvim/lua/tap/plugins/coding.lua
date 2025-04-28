return {
  -- Validate jenkinsfiles against server
  {
    'ckipp01/nvim-jenkinsfile-linter',
    ft = 'groovy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('tap.utils').augroup('JenkinsfileLinter', {
        {
          events = { 'BufWritePost' },
          pattern = { 'Jenkinsfile', 'Jenkinsfile.*' },
          callback = function()
            if require('jenkinsfile_linter').check_creds() then
              require('jenkinsfile_linter').validate()
            end
          end,
        },
      })
    end,
  },

  -- Auto completion plugin for nvim
  {
    'hrsh7th/nvim-cmp',
    version = false,
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'onsails/lspkind-nvim',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'f3fora/cmp-spell',
    },
    config = function()
      local cmp = require 'cmp'

      local WIDE_HEIGHT = 40

      -- Avoid showing extra message when using completion
      vim.opt.shortmess:append 'c'

      cmp.setup {
        completion = {
          -- Set completeopt to have a better completion experience
          completeopt = 'menuone,noselect',
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          -- needed to select snippets and copilot
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          },
        },

        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'luasnip' },
          { name = 'spell' },
        }, {
          { name = 'buffer' },
        }),

        formatting = {
          expandable_indicator = true,
          fields = { 'abbr', 'kind', 'menu' },
          format = require('lspkind').cmp_format {
            mode = 'symbol_text',
            symbol_map = {
              -- Additional icons
              Copilot = '',
            },
          },
        },

        window = {
          documentation = {
            border = {
              '',
              '',
              '',
              ' ',
              ' ',
              ' ',
              ' ',
              ' ',
            },
            max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
            max_width = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
            winhighlight = 'Normal:ColorColumn,FloatBorder:ColorColumn,CursorLine:PmenuSel,Search:None',
          },
        },

        experimental = { ghost_text = { hl_group = 'Comment' } },
      }

      require('tap.utils').apply_user_highlights('NvimCmp', function(highlight)
        highlight('CmpItemAbbrDeprecated', { link = 'Error' })
        highlight('CmpItemKind', { link = 'Special' })
        highlight('CmpItemMenu', { link = 'Comment' })
      end)
    end,
  },

  -- even better % navigation
  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    config = function()
      vim.g.matchup_surround_enabled = 1
    end,
  },

  -- Add/change/delete surrounding delimiter pairs with ease
  {
    'kylechui/nvim-surround',
    event = 'BufReadPost',
    opts = true,
  },
}
