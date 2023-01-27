-- statusline in lua
return {
  {
    'tapayne88/lualine.nvim',
    branch = 'suppress-winbar-no-room-error',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      local color = require('tap.utils').color
      local lsp_colors = require('tap.utils.lsp').colors
      local lsp_symbols = require('tap.utils.lsp').symbols
      local highlight_group_attrs = require('tap.utils').highlight_group_attrs
      local require_plugin = require('tap.utils').require_plugin
      local get_lsp_clients = require('tap.utils.lsp').get_lsp_clients

      local nord_theme_b = { bg = color 'nord1_gui', fg = color 'nord4_gui' }
      local nord_theme_c = { bg = color 'nord2_gui', fg = color 'nord4_gui' }
      local nord_theme = {
        normal = {
          a = { bg = color 'nord0_gui', fg = color 'nord8_gui' },
          b = nord_theme_b,
          c = nord_theme_c,
        },
        insert = {
          a = { bg = color 'nord0_gui', fg = color 'nord4_gui' },
          b = nord_theme_b,
          c = nord_theme_c,
        },
        visual = {
          a = { bg = color 'nord0_gui', fg = color 'nord7_gui' },
          b = nord_theme_b,
          c = nord_theme_c,
        },
        replace = {
          a = { bg = color 'nord0_gui', fg = color 'nord13_gui' },
          b = nord_theme_b,
          c = nord_theme_c,
        },
        command = {
          a = { bg = color 'nord0_gui', fg = color 'nord8_gui' },
          b = nord_theme_b,
          c = nord_theme_c,
        },
        inactive = {
          a = { bg = color 'nord1_gui', fg = color 'nord4_gui' },
          b = nord_theme_b,
          c = { bg = color 'nord0_gui', fg = color 'nord8_gui' },
        },
      }

      local conditions = {
        has_lsp = function()
          return #get_lsp_clients() > 0
        end,
        is_wide_window = function()
          return vim.fn.winwidth(0) > 80
        end,
      }

      local function literal(str)
        local comp = require('lualine.component'):extend()
        function comp:draw(default_highlight)
          self.status = str or ''
          self.applied_separator = ''
          self:apply_highlights(default_highlight)
          self:apply_section_separators()
          return self.status
        end

        return comp
      end

      local filetype = require('lualine.components.filetype'):extend()
      function filetype:draw(default_highlight, is_focused)
        -- Copied from lualine.component and modified to allow empty status to render
        self.status = ''
        self.applied_separator = ''

        if self.options.cond ~= nil and self.options.cond() ~= true then
          return self.status
        end
        local status = self:update_status(is_focused)
        if self.options.fmt then
          status = self.options.fmt(status or '')
        end
        -- if type(status) == 'string' and #status > 0 then
        self.status = status
        self:apply_icon()
        self:apply_padding()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        self:apply_separator()
        -- end
        return self.status
      end

      local diagnostic_empty =
        require('lualine.components.diagnostics'):extend()
      function diagnostic_empty:draw(default_highlight, is_focused)
        -- Copied from lualine.component and modified to allow empty status to render
        self.status = ''
        self.applied_separator = ''

        if self.options.cond ~= nil and self.options.cond() ~= true then
          return self.status
        end
        local status = self:update_status(is_focused)
        if self.options.fmt then
          status = self.options.fmt(status or '')
        end
        -- if type(status) == 'string' and #status > 0 then
        self.status = status
        self:apply_icon()
        self:apply_padding()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        self:apply_separator()
        -- end
        return self.status
      end

      local function modified()
        if vim.bo.modified then
          return ''
        end
        return ''
      end

      local function tscVersion()
        local tsc_version = require_plugin(
          'tap.plugins.lsp.servers.tsserver',
          function(tsserver)
            return tsserver.get_tsc_version()
          end
        )

        return tsc_version and string.format('v%s', tsc_version) or ''
      end

      local function window_zoom_enabled()
        local ok, is_zoomed = pcall(function()
          return vim.fn['zoom#statusline']() == 'zoomed'
        end)

        if ok then
          return is_zoomed
        end
        return false
      end

      local section_separators = { left = '', right = '' }

      local diagnostic_section = function(cfg)
        local default_cfg = {
          diagnostic_empty,
          source = { 'nvim_diagnostic' },
          separator = {
            left = section_separators.right,
            right = section_separators.left,
          },
          -- no padding so the slanty isn't too wide when no diagnostics
          padding = 0,
          fmt = function(status)
            if tonumber(status, 10) > 0 then
              -- stitch the icon onto the count
              return string.format(
                '%s%s%s',
                cfg.pad_left and ' ' or '',
                cfg.symbol,
                status
              )
            end

            -- Count is 0 so don't return content
            return ''
          end,
          -- supress the symbols, default still shows 'E: 1' etc.
          symbols = { error = '', warn = '', hint = '', info = '' },
          -- don't want any color output adding to the diagnostics
          colored = false,
          -- always show the slanty, it'll be empty if there are none for that type
          always_visible = true,
          -- only show when we have an lsp attached - this may need updating if I
          -- use other sources for diagnostics
          cond = conditions.has_lsp,
        }
        return vim.tbl_extend('force', default_cfg, cfg)
      end

      local sections = {
        lualine_a = {
          {
            'mode',
            fmt = function()
              return ' '
            end,
            color = { gui = 'reverse' },
            padding = 0,
          },
          {
            'mode',
            fmt = string.lower,
          },
        },
        lualine_b = { { 'branch', icon = '' } },
        lualine_c = {
          {
            'filename',
            file_status = false,
            fmt = function(filename)
              local is_zoomed = window_zoom_enabled()
              local zoom_text = is_zoomed and ' ﯫ' or ''
              return filename .. zoom_text
            end,
          },
          modified,
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
          },
          {
            '%r',
            fmt = function()
              return ''
            end,
            cond = function()
              return vim.bo.readonly
            end,
          },
        },
        lualine_x = {
          { tscVersion, cond = conditions.is_wide_window },
          diagnostic_section {
            sections = { 'error' },
            color = 'LualineDiagnosticError',
            symbol = lsp_symbols 'error',
            pad_left = false,
          },
          diagnostic_section {
            sections = { 'warn' },
            color = 'LualineDiagnosticWarn',
            symbol = lsp_symbols 'warning',
            pad_left = true,
          },
          diagnostic_section {
            sections = { 'hint' },
            color = 'LualineDiagnosticHint',
            symbol = lsp_symbols 'hint',
            pad_left = true,
          },
          diagnostic_section {
            sections = { 'info' },
            color = 'LualineDiagnosticInfo',
            symbol = lsp_symbols 'info',
            pad_left = true,
          },
          diagnostic_section {
            sections = { 'error', 'warn', 'hint', 'info' },
            color = 'LualineDiagnosticOk',
            fmt = function(status)
              -- diagnostics will only report numbers so if they are all 0
              -- then we are all ok
              if status == '0 0 0 0' then
                return string.format(' %s ', lsp_symbols 'ok')
              end
              return ''
            end,
          },
          literal ' ',
        },
        lualine_y = {
          literal ' ',
          {
            filetype,
            colored = false,
            padding = 0,
            fmt = function(status)
              return conditions.is_wide_window() and status .. ' ' or ''
            end,
          },
          {
            literal '┃',
            color = function()
              local hi_attrs = highlight_group_attrs 'lualine_c_normal'
              return { fg = hi_attrs.guibg }
            end,
          },
          { '%l:%c', icon = '' },
        },
        lualine_z = { { '%p%%', cond = conditions.is_wide_window } },
      }

      require('tap.utils').apply_user_highlights('Lualine', function(highlight)
        highlight('LualineDiagnosticError', {
          guibg = lsp_colors 'error',
          guifg = color { dark = 'nord3_gui', light = 'fg' },
        })
        highlight('LualineDiagnosticWarn', {
          guibg = lsp_colors 'warning',
          guifg = color { dark = 'nord3_gui', light = 'fg' },
        })
        highlight('LualineDiagnosticHint', {
          guibg = lsp_colors 'hint',
          guifg = color { dark = 'nord3_gui', light = 'fg' },
        })
        highlight('LualineDiagnosticInfo', {
          guibg = lsp_colors 'info',
          guifg = color { dark = 'nord3_gui', light = 'fg' },
        })
        highlight('LualineDiagnosticOk', {
          guibg = lsp_colors 'ok',
          guifg = color { dark = 'nord3_gui', light = 'fg' },
        })
        highlight('NavicSeparator', {
          guifg = color { dark = 'nord3_gui', light = 'fg' },
        })

        local theme_name = vim.g.colors_name
        local theme = theme_name == 'nord' and nord_theme or theme_name
        if theme then
          require('lualine').setup { options = { theme = theme } }
        end
      end)

      local winbar_y = {
        modified,
        { 'filename', file_status = false },
      }
      local filetype_icon_only = {
        filetype,
        padding = 0,
        fmt = function()
          return ''
        end,
      }

      require('lualine').setup {
        options = {
          theme = nord_theme,
          component_separators = { left = '', right = '' },
          section_separators = section_separators,
          globalstatus = true,
          disabled_filetypes = {
            winbar = {
              'alpha',
              'fugitive',
              'gitcommit',
              'packer',
              'qf',
              'neo-tree',
              'Trouble',
            },
          },
        },
        sections = sections,
        inactive_sections = vim.tbl_deep_extend(
          'force',
          sections,
          { lualine_a = {}, lualine_x = {} }
        ),
        winbar = {
          lualine_a = {
            {
              function()
                local breadcrumb = require('nvim-navic').get_location {
                  highlight = true,
                }

                return table.concat {
                  ' ',
                  breadcrumb == '' and '' or ' ',
                  breadcrumb,
                  -- lualine doesn't seem to like it when the content contains
                  -- highlighting patterns so reset back to section highlight so
                  -- separator has correct highlight
                  '%#lualine_a_normal#',
                }
              end,
              cond = function()
                -- navic is lazy and loaded only when an LSP supports the correct capabilities
                return package.loaded['nvim-navic']
                  and require('nvim-navic').is_available()
              end,
              color = { bg = color 'nord0_gui', fg = color 'nord8_gui' },
            },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = winbar_y,
          lualine_z = { filetype_icon_only },
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = winbar_y,
          lualine_z = { filetype_icon_only },
        },
      }
    end,
  },

  {
    'SmiteshP/nvim-navic',
    dependencies = 'neovim/nvim-lspconfig',
    lazy = true,
    init = function()
      require('tap.utils.lsp').on_attach(function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, bufnr)
        end
      end)
    end,
  },
}
